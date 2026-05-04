package main

import (
	"fmt"
	"time"
)

// Phase 3 — Sistema de movimentação.
//
// Goal: keep the per-tick movement loop in one well-named place so
// Game.tick stays focused on orchestration. The legacy Player struct
// remains the source of truth for position (HP/XY/etc. are read across
// db.go, scripting.go, skills_runtime.go); the ECS mirror gets the new
// state via syncECSLocked after this runs.
//
// Movement is a two-phase pass per tick:
//
//  1. Settle finished steps so a player who just landed on a tile is
//     immediately eligible to start the next step in the same tick.
//     Without this the perceived input rate drops to half whenever the
//     network MOVE arrives mid-step.
//  2. For idle, alive, named players whose desired direction is
//     non-zero, attempt the step. Blocked attempts still update facing
//     (the avatar should turn toward what it bumped into).
//
// Caller must hold g.mu.

// runMovement advances every player by at most one tile this tick.
// Enemies do not move yet — Phase 4 (AI) wires that path through the
// AISystem.
func (g *Game) runMovement(now time.Time) {
	// pendingWarps collects (player, warp) pairs that should fire AFTER
	// the step has fully settled. We never trigger a warp inside the
	// step that lands a player on the tile because the snapshot pipeline
	// would observe the player teleport mid-interpolation, breaking the
	// visual. Phase 2 §"Trigger warp dispara após settle do step".
	type pendingWarp struct {
		p    *Player
		warp MapEntity
	}
	var warps []pendingWarp

	for _, p := range g.players {
		if p.Stepping && now.Sub(p.StepStart) >= p.StepDur {
			p.FromX, p.FromY = p.TileX, p.TileY
			p.Stepping = false
			// Step just settled — check for a warp on the new tile.
			if w, ok := g.warpAt(p.MapName, p.TileX, p.TileY); ok {
				warps = append(warps, pendingWarp{p: p, warp: w})
			}
		}
	}

	for _, p := range g.players {
		if p.Name == "" {
			continue
		}
		// log do estado atual sempre que tem intenção
		if p.DirX != 0 || p.DirY != 0 {
			fmt.Printf(">>> tick player=%d name=%s tile=(%d,%d) dir=(%d,%d) stepping=%v hp=%d\n",
				p.ID, p.Name, p.TileX, p.TileY, p.DirX, p.DirY, p.Stepping, p.HP)
		}
		if p.Stepping || p.HP <= 0 {
			continue
		}
		dx, dy := p.DirX, p.DirY
		if dx == 0 && dy == 0 {
			continue
		}
		p.FaceX, p.FaceY = dx, dy

		nx, ny := p.TileX+dx, p.TileY+dy
		pm := g.playerMap(p)
		if !pm.InBounds(nx, ny) {
			fmt.Printf(">>> blocked: out of bounds nx=%d ny=%d\n", nx, ny)
			continue
		}
		if !pm.IsWalkable(nx, ny) {
			fmt.Printf(">>> blocked: not walkable nx=%d ny=%d\n", nx, ny)
			continue
		}
		if g.tileOccupiedOn(pm.Name, nx, ny, p.ID) {
			fmt.Printf(">>> blocked: tile occupied nx=%d ny=%d\n", nx, ny)
			continue
		}

		p.FromX, p.FromY = p.TileX, p.TileY
		p.TileX, p.TileY = nx, ny
		p.Stepping = true
		p.StepStart = now
		if dx != 0 && dy != 0 {
			p.StepDur = time.Duration(float64(stepDuration) * diagFactor)
		} else {
			p.StepDur = stepDuration
		}
		fmt.Printf(">>> step OK player=%d to=(%d,%d) dur=%v\n", p.ID, nx, ny, p.StepDur)
		// Visit-objective hook fires on every successful step. The
		// quest tracker only does work for players carrying a visit
		// quest, so the cost stays near zero in the common case.
		// Wire frames are buffered into aiOutbox so the host can flush
		// them after dropping g.mu — keeps roadmap §🔒 clean.
		if updates := g.trackVisitForQuests(p, nx, ny); len(updates) > 0 {
			for _, w := range updates {
				select {
				case p.Out <- w:
				default:
				}
			}
		}
	}

	// Fire any warps queued from settled steps. transitionPlayerLocked
	// rewrites MapName / position and queues a MAP_CHANGE wire frame
	// onto aiOutbox so the host flushes it after dropping g.mu.
	for _, pw := range warps {
		g.transitionPlayerLocked(pw.p, pw.warp.TargetMap, pw.warp.TargetX, pw.warp.TargetY)
	}
}
// runManaRegen ticks the per-player mana regeneration. Lives next to
// movement because both belong to the "passive per-tick player update"
// bucket and share the same iteration shape. Caller must hold g.mu.
func (g *Game) runManaRegen(now time.Time) {
	for _, p := range g.players {
		if p.MaxMP <= 0 || p.MP >= p.MaxMP {
			continue
		}
		if now.Sub(p.LastManaTick) < manaRegenInterval {
			continue
		}
		p.MP += manaRegenAmount
		if p.MP > p.MaxMP {
			p.MP = p.MaxMP
		}
		p.LastManaTick = now
	}
}
