package main

import (
	"sync"
	"testing"
	"time"
)

// Phase 3 — AISystem must drive an enemy to chase and attack.

func TestAISystemEnemyChasesPlayer(t *testing.T) {
	g := newTestGame(t)
	g.pipeline = g.buildPipeline()

	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.Entity = g.ecs.Add(&Entity{
		Kind:     KindPlayer,
		Position: &CPosition{X: 5, Y: 5, FromX: 5, FromY: 5},
		Health:   &CHealth{HP: 100, MaxHP: 100},
	})

	g.nextEnemyID++
	enemy := &Enemy{
		ID: g.nextEnemyID, Kind: "orc",
		X: 9, Y: 5,
		HP: 30, MaxHP: 30,
	}
	enemy.Entity = g.ecs.Add(&Entity{
		Kind:     KindEnemy,
		Name:     enemy.Kind,
		Position: &CPosition{X: 9, Y: 5},
		Health:   &CHealth{HP: 30, MaxHP: 30},
		AI:       &CAI{Kind: enemy.Kind, State: "idle"},
	})
	g.enemies[enemy.ID] = enemy

	// Force the cooldown to be elapsed so the very first tick steps.
	enemy.LastStep = time.Now().Add(-time.Hour)

	g.mu.Lock()
	g.pipeline.Tick(g.ecs, time.Now(), 33*time.Millisecond)
	g.mu.Unlock()

	if enemy.X >= 9 {
		t.Fatalf("orc should have stepped toward player, x=%d", enemy.X)
	}
	if enemy.Entity.AI.Target != p.Entity.ID {
		t.Fatalf("orc should target the player; target=%d, want %d",
			enemy.Entity.AI.Target, p.Entity.ID)
	}
	if enemy.Entity.AI.State != "chase" {
		t.Fatalf("expected chase state, got %q", enemy.Entity.AI.State)
	}
}

func TestAISystemAttacksAdjacentPlayer(t *testing.T) {
	g := newTestGame(t)
	g.pipeline = g.buildPipeline()

	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.Entity = g.ecs.Add(&Entity{
		Kind:     KindPlayer,
		Position: &CPosition{X: 5, Y: 5, FromX: 5, FromY: 5},
		Health:   &CHealth{HP: 100, MaxHP: 100},
	})
	startHP := p.HP

	g.nextEnemyID++
	enemy := &Enemy{
		ID: g.nextEnemyID, Kind: "orc",
		X: 6, Y: 5,
		HP: 30, MaxHP: 30,
	}
	enemy.Entity = g.ecs.Add(&Entity{
		Kind:     KindEnemy,
		Name:     enemy.Kind,
		Position: &CPosition{X: 6, Y: 5},
		Health:   &CHealth{HP: 30, MaxHP: 30},
		AI:       &CAI{Kind: enemy.Kind, State: "idle"},
	})
	g.enemies[enemy.ID] = enemy
	enemy.LastAttack = time.Now().Add(-time.Hour)

	g.mu.Lock()
	g.pipeline.Tick(g.ecs, time.Now(), 33*time.Millisecond)
	g.mu.Unlock()

	if p.HP >= startHP {
		t.Fatalf("expected player HP to drop, got %d (was %d)", p.HP, startHP)
	}
	if enemy.Entity.AI.State != "attack" {
		t.Fatalf("expected attack state, got %q", enemy.Entity.AI.State)
	}
	if len(g.aiOutbox) == 0 {
		t.Fatalf("AI attack should buffer a wire frame")
	}
}

// Phase 3 hardening — the roadmap calls out a `-race` test with 50+
// entities ticking the pipeline. The test exercises the AISystem
// callbacks (which read other entities' positions/HP) under contention
// to surface any reentrant Each() or unprotected mutation.
//
// We run two goroutines: one drives ticks, the other reads the snapshot.
// Either path going wrong (e.g. AI callback calling Each from inside
// Each) trips the race detector immediately.
func TestAISystemTicksManyEntitiesUnderRace(t *testing.T) {
	g := newTestGame(t)
	g.pipeline = g.buildPipeline()

	// Use a bigger map so 50 enemies + 5 players fit without collision
	// noise drowning the AI signal we care about.
	g.world = DefaultMap("race")
	g.world.Width, g.world.Height = 80, 80
	g.world.Layers.Ground = emptyLayer(80, 80)
	g.world.Layers.Collision = emptyLayer(80, 80)
	g.world.Layers.Decoration = emptyLayer(80, 80)
	g.world.Layers.Logic = emptyLayer(80, 80)

	for i := 0; i < 5; i++ {
		p := addNamedPlayerAt(g, "p", 10+i, 10)
		p.Entity = g.ecs.Add(&Entity{
			Kind:     KindPlayer,
			Position: &CPosition{X: 10 + i, Y: 10, FromX: 10 + i, FromY: 10},
			Health:   &CHealth{HP: 100, MaxHP: 100},
		})
	}

	for i := 0; i < 50; i++ {
		g.nextEnemyID++
		x := 30 + (i % 10)
		y := 30 + (i / 10)
		enemy := &Enemy{
			ID: g.nextEnemyID, Kind: "orc",
			X: x, Y: y, HP: 30, MaxHP: 30,
		}
		enemy.Entity = g.ecs.Add(&Entity{
			Kind:     KindEnemy,
			Name:     enemy.Kind,
			Position: &CPosition{X: x, Y: y},
			Health:   &CHealth{HP: 30, MaxHP: 30},
			AI:       &CAI{Kind: enemy.Kind, State: "idle"},
		})
		g.enemies[enemy.ID] = enemy
		enemy.LastStep = time.Now().Add(-time.Hour)
	}

	const ticks = 30
	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		for i := 0; i < ticks; i++ {
			g.mu.Lock()
			g.aiOutbox = g.aiOutbox[:0]
			g.pipeline.Tick(g.ecs, time.Now(), 33*time.Millisecond)
			g.mu.Unlock()
		}
	}()

	// Reader goroutine — snapshot via the public API. Acquires its own
	// short-lived locks; must never deadlock against the tick.
	go func() {
		defer wg.Done()
		for i := 0; i < ticks; i++ {
			snap := g.SnapshotECS()
			_ = snap
			time.Sleep(time.Millisecond)
		}
	}()

	wg.Wait()
}

