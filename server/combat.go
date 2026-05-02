package main

import (
	"fmt"
	"time"
)

// Phase 3 — Sistema de combate.
//
// The cast/attack pipelines used to live inline in handleAttack and
// handleCast, each with its own copy of "find targets, deal damage,
// respawn dead players, broadcast HIT/PHIT/EDIE/PDIE". This file owns
// the shared primitives so the three entry points (melee attack,
// per-player Spell, data-driven Skill) all converge on the same damage
// resolution path.
//
// Caller convention: builders run under g.mu; broadcasts happen after
// the lock is released. The `combatOutcome` type carries the network
// intentions across the lock boundary so we never write to a player's
// channel while holding g.mu (deadlock risk if the channel is full and
// the writer is also stalled).

// combatOutcome accumulates the broadcast intentions produced by a
// damage pass. Hits are de-duplicated by callers when needed (the
// melee/cast loops touch each entity at most once, so we don't pay for
// a set in the hot path).
type combatOutcome struct {
	enemyHits    []int
	playerHits   []int
	enemyKilled  []*Enemy
	playerKilled []int
}

func (o *combatOutcome) addEnemyHit(e *Enemy) {
	o.enemyHits = append(o.enemyHits, e.ID)
	if e.HP <= 0 {
		o.enemyKilled = append(o.enemyKilled, e)
	}
}

func (o *combatOutcome) addPlayerHit(p *Player, killed bool) {
	o.playerHits = append(o.playerHits, p.ID)
	if killed {
		o.playerKilled = append(o.playerKilled, p.ID)
	}
}

// damageEnemy applies raw damage to an enemy and records the hit.
// Caller must hold g.mu.
func (g *Game) damageEnemy(e *Enemy, amount int, out *combatOutcome) {
	if amount <= 0 {
		return
	}
	e.HP -= amount
	out.addEnemyHit(e)
}

// damagePlayer applies raw damage to a player; lethal damage triggers
// respawn. Caller must hold g.mu.
func (g *Game) damagePlayer(p *Player, amount int, out *combatOutcome) {
	if amount <= 0 || p.HP <= 0 {
		return
	}
	p.HP -= amount
	killed := p.HP <= 0
	if killed {
		g.respawnPlayer(p)
	}
	out.addPlayerHit(p, killed)
}

// respawnPlayer resets HP, clears movement state, and teleports a
// downed player to a free spawn tile. Caller must hold g.mu.
func (g *Game) respawnPlayer(p *Player) {
	p.HP = p.MaxHP
	p.Stepping = false
	p.DirX, p.DirY = 0, 0
	sx, sy := g.findSpawn(p.ID)
	p.TileX, p.TileY = sx, sy
	p.FromX, p.FromY = sx, sy
}

// runMeleeAttack resolves a basic attack — short-circuit version of
// the cast pipeline used by ATTACK. The attacker swings at the tile in
// front of them and damages every enemy / non-caster player whose
// Chebyshev-1 footprint intersects the attack disc. Returns false if
// the attack could not be performed (dead, on cooldown, unbound).
//
// Caller must hold g.mu.
func (g *Game) runMeleeAttack(p *Player, now time.Time) (out combatOutcome, atkMsg string, ok bool) {
	if p.Name == "" || p.HP <= 0 || now.Before(p.NextAttack) {
		return out, "", false
	}
	p.AttackUntil = now.Add(attackDur)
	p.NextAttack = now.Add(attackCD)

	// Attack origin is the tile in front of the attacker. Using a
	// squared range avoids the Hypot/sqrt in the inner loop.
	tx := float64(p.TileX) + float64(p.FaceX)
	ty := float64(p.TileY) + float64(p.FaceY)
	rangeSq := attackRange * attackRange

	for _, e := range g.enemies {
		dx := float64(e.X) - tx
		dy := float64(e.Y) - ty
		if dx*dx+dy*dy <= rangeSq {
			g.damageEnemy(e, attackDamage, &out)
		}
	}
	for _, op := range g.players {
		if op.ID == p.ID || op.Name == "" || op.HP <= 0 {
			continue
		}
		dx := float64(op.TileX) - tx
		dy := float64(op.TileY) - ty
		if dx*dx+dy*dy <= rangeSq {
			g.damagePlayer(op, attackDamage, &out)
		}
	}

	for _, e := range out.enemyKilled {
		delete(g.enemies, e.ID)
		p.Kills++
	}

	atkMsg = fmt.Sprintf("ATK %d %d %d\n", p.ID, p.FaceX, p.FaceY)
	return out, atkMsg, true
}

// broadcastCombat ships every HIT/PHIT/PDIE/EDIE message implied by an
// outcome to the supplied output set. Cache kill credit (recorded for
// EDIE only) is attributed to playerName. Caller must NOT hold g.mu.
func (g *Game) broadcastCombat(outs []chan<- string, prefix string, out combatOutcome, playerName string) {
	if prefix != "" {
		g.broadcast(outs, prefix)
	}
	for _, id := range out.enemyHits {
		g.broadcast(outs, fmt.Sprintf("HIT %d\n", id))
	}
	for _, id := range out.playerHits {
		g.broadcast(outs, fmt.Sprintf("PHIT %d\n", id))
	}
	for _, id := range out.playerKilled {
		g.broadcast(outs, fmt.Sprintf("PDIE %d\n", id))
	}
	for _, e := range out.enemyKilled {
		g.broadcast(outs, fmt.Sprintf("EDIE %d\n", e.ID))
		if g.cache != nil && playerName != "" {
			g.cache.RecordKill(playerName)
		}
	}
}
