package main

import (
	"fmt"
	"log"
	"time"
)

// Phase 2 — Warps & multi-map transitions.
//
// A warp trigger is a MapEntity with Type=="trigger" and Kind=="warp"
// whose TargetMap/TargetX/TargetY name a destination tile. When a
// player's step settles on a warp tile, the movement system queues a
// transitionPlayerLocked call which: loads the destination map (if
// not already cached), rewrites the player's MapName/Position,
// invalidates AoI bookkeeping, and emits MAP / MAP_CHANGE wire frames
// so the client redraws.
//
// Reference: reference_engine/Server/src/modPlayer.bas PlayerWarp.

// warpAt returns the warp entity whose footprint covers (x, y) on the
// named map, if any. Caller must hold g.mu.
func (g *Game) warpAt(mapName string, x, y int) (MapEntity, bool) {
	m := g.mapByName(mapName)
	if m == nil {
		return MapEntity{}, false
	}
	for _, e := range m.Entities {
		if !e.IsWarp() {
			continue
		}
		if e.X == x && e.Y == y {
			return e, true
		}
	}
	return MapEntity{}, false
}

// transitionPlayerLocked moves p onto a fresh map at (tx, ty). The
// destination map is loaded on demand. Caller MUST hold g.mu. Wire
// frames (MAP, MAP_CHANGE) are queued onto g.aiOutbox so the host
// flushes them once it has dropped g.mu — re-entering the network
// layer while holding the world lock would deadlock against
// snapshot-time sends that already block on the player's Out channel.
func (g *Game) transitionPlayerLocked(p *Player, targetMap string, tx, ty int) {
	if p == nil || targetMap == "" {
		return
	}
	dest := g.mapByName(targetMap)
	if dest == nil {
		log.Printf("warp: target map %q not loadable; staying on %q",
			targetMap, p.MapName)
		return
	}
	// Clamp the destination tile so a typo in the editor cannot fling
	// the player out of bounds. If the explicit target is unwalkable
	// or occupied we fall back to findSpawnOn so the warp never
	// silently soft-locks the player.
	if !dest.InBounds(tx, ty) || !dest.IsWalkable(tx, ty) ||
		g.tileOccupiedOn(dest.Name, tx, ty, p.ID) {
		tx, ty = g.findSpawnOn(dest.Name, p.ID)
	}

	prevMap := playerMapName(p.MapName)
	p.MapName = dest.Name
	p.TileX, p.TileY = tx, ty
	p.FromX, p.FromY = tx, ty
	p.Stepping = false
	p.StepStart = time.Time{}
	p.DirX, p.DirY = 0, 0
	if p.Entity != nil {
		p.Entity.MapName = dest.Name
		if p.Entity.Position != nil {
			p.Entity.Position.X = tx
			p.Entity.Position.Y = ty
			p.Entity.Position.FromX = tx
			p.Entity.Position.FromY = ty
			p.Entity.Position.Stepping = false
		}
	}

	// Reset AoI bookkeeping so the next snapshot is a full one. Without
	// this the diff path would still believe the player can see
	// entities from the old map and skip emitting the destination
	// world's NPCs.
	resetSeenForRespawn(p)

	// Tell every viewer on the OLD map that this player just dropped
	// off their AoI window. Without an explicit "X" line their client
	// would keep the now-vanished player rendered at the last seen
	// tile.
	leave := fmt.Sprintf("X P %d\n", p.ID)
	for _, op := range g.players {
		if op.ID == p.ID {
			continue
		}
		if playerMapName(op.MapName) != prevMap {
			continue
		}
		select {
		case op.Out <- leave:
		default:
		}
	}

	// MAP serialises the destination so the client can rebuild its
	// renderer cache before the next snapshot lands. MAP_CHANGE is a
	// lightweight follow-up that gives the client an explicit "you
	// are now on X" hook (audio change, minimap rebuild, etc.). Both
	// are addressed to *this player only* — pushed via a non-blocking
	// send so a slow consumer cannot wedge the world tick.
	if data, err := dest.Marshal(); err == nil {
		select {
		case p.Out <- "MAP " + string(data) + "\n":
		default:
		}
	}
	select {
	case p.Out <- fmt.Sprintf("MAP_CHANGE %s %d %d %d %d\n",
		dest.Name, dest.Width, dest.Height, tx, ty):
	default:
	}

	log.Printf("warp: player=%d %q -> %q@(%d,%d)",
		p.ID, prevMap, dest.Name, tx, ty)
}
