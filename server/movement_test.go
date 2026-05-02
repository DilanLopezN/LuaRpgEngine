package main

import (
	"testing"
	"time"
)

// newTestGame builds the smallest Game wrapper that exercises the
// movement and combat helpers without touching DB / cache / scripts.
func newTestGame(t *testing.T) *Game {
	t.Helper()
	g := &Game{
		players: make(map[int]*Player),
		enemies: make(map[int]*Enemy),
		ecs:     NewECSWorld(),
	}
	g.world = DefaultMap("test")
	return g
}

// addNamedPlayerAt seeds a player without going through addPlayer/
// bindName so tests stay independent of the connection lifecycle.
func addNamedPlayerAt(g *Game, name string, x, y int) *Player {
	g.nextID++
	p := &Player{
		ID:   g.nextID,
		Name: name,
		TileX: x, TileY: y,
		FromX: x, FromY: y,
		FaceX: 0, FaceY: 1,
		HP: 100, MaxHP: 100,
		MP: maxManaDefault, MaxMP: maxManaDefault,
		LastManaTick: time.Now(),
		SpellCDs:     make(map[string]time.Time),
		Spells:       make(map[string]*Spell),
		Learned:      make(map[string]bool),
		SkillCDs:     make(map[string]time.Time),
		Out:          make(chan string, 16),
	}
	g.players[p.ID] = p
	return p
}

func TestRunMovementStartsStep(t *testing.T) {
	g := newTestGame(t)
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.DirX, p.DirY = 1, 0

	g.runMovement(time.Now())

	if !p.Stepping {
		t.Fatalf("expected Stepping=true after step")
	}
	if p.TileX != 6 || p.TileY != 5 {
		t.Fatalf("expected (6,5), got (%d,%d)", p.TileX, p.TileY)
	}
	if p.FromX != 5 || p.FromY != 5 {
		t.Fatalf("FromX/Y should hold previous tile, got (%d,%d)", p.FromX, p.FromY)
	}
	if p.FaceX != 1 || p.FaceY != 0 {
		t.Fatalf("facing should follow direction, got (%d,%d)", p.FaceX, p.FaceY)
	}
	if p.StepDur != stepDuration {
		t.Fatalf("orthogonal step should use base duration, got %v", p.StepDur)
	}
}

func TestRunMovementDiagonalUsesLongerDuration(t *testing.T) {
	g := newTestGame(t)
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.DirX, p.DirY = 1, 1

	g.runMovement(time.Now())

	if !p.Stepping || p.TileX != 6 || p.TileY != 6 {
		t.Fatalf("diagonal step failed: stepping=%v at (%d,%d)", p.Stepping, p.TileX, p.TileY)
	}
	want := time.Duration(float64(stepDuration) * diagFactor)
	if p.StepDur != want {
		t.Fatalf("diagonal step duration: want %v, got %v", want, p.StepDur)
	}
}

func TestRunMovementBlockedStillFaces(t *testing.T) {
	g := newTestGame(t)
	// Wall the tile to the east of the spawn so the step is denied
	// but facing should still rotate.
	g.world.Layers.Collision[5][6] = 1
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.DirX, p.DirY = 1, 0

	g.runMovement(time.Now())

	if p.Stepping {
		t.Fatalf("should not have stepped into blocked tile")
	}
	if p.TileX != 5 {
		t.Fatalf("position must not move, got x=%d", p.TileX)
	}
	if p.FaceX != 1 || p.FaceY != 0 {
		t.Fatalf("facing should still update on block, got (%d,%d)", p.FaceX, p.FaceY)
	}
}

func TestRunMovementSettlesFinishedStep(t *testing.T) {
	g := newTestGame(t)
	p := addNamedPlayerAt(g, "tester", 5, 5)

	start := time.Now()
	p.DirX, p.DirY = 1, 0
	g.runMovement(start)
	if !p.Stepping {
		t.Fatalf("setup: expected first step to start")
	}

	// Advance past StepDur with the same direction held — the player
	// should land, then immediately start the next step.
	later := start.Add(p.StepDur + 10*time.Millisecond)
	g.runMovement(later)

	if !p.Stepping {
		t.Fatalf("expected continuous walk, got idle")
	}
	if p.TileX != 7 {
		t.Fatalf("expected to be on tile 7, got %d", p.TileX)
	}
	if p.FromX != 6 {
		t.Fatalf("FromX should reflect previous tile, got %d", p.FromX)
	}
}

func TestRunMeleeAttackHitsEnemy(t *testing.T) {
	g := newTestGame(t)
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.FaceX, p.FaceY = 1, 0
	g.nextEnemyID++
	e := &Enemy{ID: g.nextEnemyID, Kind: "orc", X: 6, Y: 5, HP: attackDamage, MaxHP: attackDamage}
	g.enemies[e.ID] = e

	out, msg, ok := g.runMeleeAttack(p, time.Now())
	if !ok {
		t.Fatalf("attack should resolve")
	}
	if msg == "" {
		t.Fatalf("ATK wire message must be non-empty")
	}
	if len(out.enemyHits) != 1 || out.enemyHits[0] != e.ID {
		t.Fatalf("expected one enemy hit, got %+v", out.enemyHits)
	}
	if len(out.enemyKilled) != 1 {
		t.Fatalf("enemy should die in one hit at exact HP, got %d", len(out.enemyKilled))
	}
	if _, alive := g.enemies[e.ID]; alive {
		t.Fatalf("dead enemy must be removed from the registry")
	}
	if p.Kills != 1 {
		t.Fatalf("kill credit not awarded, kills=%d", p.Kills)
	}
}

func TestRunMeleeAttackRespectsCooldown(t *testing.T) {
	g := newTestGame(t)
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.FaceX = 1
	now := time.Now()
	if _, _, ok := g.runMeleeAttack(p, now); !ok {
		t.Fatalf("first attack should succeed")
	}
	if _, _, ok := g.runMeleeAttack(p, now.Add(10*time.Millisecond)); ok {
		t.Fatalf("second attack within cooldown must be rejected")
	}
	if _, _, ok := g.runMeleeAttack(p, now.Add(attackCD+time.Millisecond)); !ok {
		t.Fatalf("attack after cooldown should succeed")
	}
}

func TestDamagePlayerRespawnsOnLethal(t *testing.T) {
	g := newTestGame(t)
	victim := addNamedPlayerAt(g, "victim", 5, 5)
	victim.HP = 5
	var out combatOutcome

	g.damagePlayer(victim, 100, &out)

	if len(out.playerKilled) != 1 || out.playerKilled[0] != victim.ID {
		t.Fatalf("expected playerKilled to include victim, got %+v", out.playerKilled)
	}
	if victim.HP != victim.MaxHP {
		t.Fatalf("HP must be restored to max after respawn, got %d/%d", victim.HP, victim.MaxHP)
	}
	if victim.Stepping {
		t.Fatalf("respawn must clear Stepping flag")
	}
	if victim.DirX != 0 || victim.DirY != 0 {
		t.Fatalf("respawn must clear movement intent")
	}
}
