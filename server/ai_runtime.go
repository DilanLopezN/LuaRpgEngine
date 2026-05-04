package main

import (
	"fmt"
	"time"
)

// Phase 3 — host wiring for the ECS AI.
//
// The AISystem itself is data-only (sees Entity / Position / AI). The
// gameplay-aware mutations — pick a player, take a step, deal contact
// damage — live here so the system stays trivially testable.
//
// Locking convention: pipeline.Tick is invoked while the caller holds
// g.mu (today: Game.tick). All callbacks below run under that lock and
// must not re-acquire it. Side-effects that need to broadcast (EATK,
// PHIT) buffer messages in g.aiOutbox and are flushed by the host
// after the lock is released.

const (
	enemyStepCooldown = 600 * time.Millisecond
	enemyAttackTick   = 1100 * time.Millisecond
	enemyContactDmg   = 5
	aiSightRange      = 8
	aiAttackRange     = 1
)

// buildPipeline wires the live AISystem into the default pipeline.
func (g *Game) buildPipeline() *SystemPipeline {
	ai := AISystem{
		SightRange:  aiSightRange,
		AttackRange: aiAttackRange,
		Targets:     g.aiTargetsLocked,
		Step:        g.aiStepLocked,
		Attack:      g.aiAttackLocked,
	}
	return &SystemPipeline{
		Systems: []System{
			MovementSystem{},
			HealthSystem{},
			ai,
		},
	}
}

// aiTargetsLocked must be called with g.mu held.
func (g *Game) aiTargetsLocked() []*Entity {
	out := make([]*Entity, 0, len(g.players))
	for _, p := range g.players {
		if p.Name == "" || p.HP <= 0 || p.Entity == nil {
			continue
		}
		out = append(out, p.Entity)
	}
	return out
}

// aiHostileToPlayers returns true when the enemy entity should treat
// players as legitimate targets. Ally-faction NPCs (e.g. a "guardian"
// spawned for the player's village) keep their HP and can be killed by
// other hostiles, but never aggro the player themselves. Stock enemy
// kinds (orc, troll, …) defined under data/scripts/enemies/ are not
// in the npc registry and default to hostile so existing gameplay is
// unaffected.
func (g *Game) aiHostileToPlayers(kind string) bool {
	if g.scripts == nil {
		return true
	}
	def, ok := g.scripts.NPC(kind)
	if !ok {
		return true
	}
	return def.Faction != NPCFactionAlly
}

// aiStepLocked nudges an enemy one tile toward (tx, ty). Caller must
// hold g.mu.
func (g *Game) aiStepLocked(self *Entity, tx, ty int) {
	if self.Position == nil {
		return
	}
	enemy := g.enemyByEntityLocked(self)
	if enemy == nil {
		return
	}
	now := time.Now()
	if now.Sub(enemy.LastStep) < enemyStepCooldown {
		return
	}
	dx := signOf(tx - self.Position.X)
	dy := signOf(ty - self.Position.Y)
	if dx == 0 && dy == 0 {
		return
	}
	nx, ny := self.Position.X+dx, self.Position.Y+dy
	mp := g.mapByName(self.MapName)
	if mp == nil {
		mp = g.world
	}
	step := func(x, y int) bool {
		if !mp.InBounds(x, y) || !mp.IsWalkable(x, y) {
			return false
		}
		if g.tileOccupiedOn(mp.Name, x, y, 0) {
			return false
		}
		self.Position.X, self.Position.Y = x, y
		enemy.X, enemy.Y = x, y
		enemy.LastStep = now
		return true
	}
	if step(nx, ny) {
		return
	}
	if dx != 0 && step(self.Position.X+dx, self.Position.Y) {
		return
	}
	if dy != 0 {
		step(self.Position.X, self.Position.Y+dy)
	}
}

// aiAttackLocked deals one tick of contact damage from an enemy to its
// target player. Caller must hold g.mu. The wire effects are buffered
// so the host can flush them after releasing the lock.
func (g *Game) aiAttackLocked(self, target *Entity) {
	if self == nil || target == nil {
		return
	}
	enemy := g.enemyByEntityLocked(self)
	if enemy == nil {
		return
	}
	// Faction gate: a guardian whose NPC def declares ally faction
	// will not attack players. The AI still targets and steps toward
	// the player (so the encounter feels alive — they walk over to
	// greet), but the contact damage is skipped.
	if !g.aiHostileToPlayers(enemy.Kind) {
		return
	}
	now := time.Now()
	if now.Sub(enemy.LastAttack) < enemyAttackTick {
		return
	}
	enemy.LastAttack = now

	var victim *Player
	for _, p := range g.players {
		if p.Entity == target {
			victim = p
			break
		}
	}
	if victim == nil || victim.HP <= 0 {
		return
	}
	dmg := enemyContactDmg
	if g.scripts != nil {
		if def, ok := g.scripts.Enemy(enemy.Kind); ok && def.Damage > 0 {
			dmg = def.Damage
		}
	}
	var out combatOutcome
	g.damagePlayer(victim, dmg, &out)
	g.aiOutbox = append(g.aiOutbox, fmt.Sprintf("EATK %d %d %d\n", enemy.ID, enemy.X, enemy.Y))
	for _, id := range out.playerHits {
		g.aiOutbox = append(g.aiOutbox, fmt.Sprintf("PHIT %d\n", id))
	}
	for _, id := range out.playerKilled {
		g.aiOutbox = append(g.aiOutbox, fmt.Sprintf("PDIE %d\n", id))
	}
}

// enemyByEntityLocked walks the enemy registry for a matching ECS
// entity. Caller must hold g.mu.
func (g *Game) enemyByEntityLocked(e *Entity) *Enemy {
	for _, en := range g.enemies {
		if en.Entity == e {
			return en
		}
	}
	return nil
}

func signOf(v int) int {
	switch {
	case v > 0:
		return 1
	case v < 0:
		return -1
	}
	return 0
}
