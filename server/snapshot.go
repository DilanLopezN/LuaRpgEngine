package main

import (
	"fmt"
	"strings"
	"time"
)

// Phase 5 — Performance e Rede.
//
// Per-player snapshot pipeline. Two complementary techniques live here:
//
//   1. Area-of-Interest filter. Each player only receives entity frames
//      for things within `aoiRadius` Chebyshev tiles of their current
//      position. A 50×50 dungeon with twenty players therefore stops
//      scaling like O(N²) on the wire.
//
//   2. Snapshot diff. The host remembers what state each connection has
//      already seen (snapKey → snapState). On each tick we only emit
//      P/E/N lines for entities that actually changed since last frame,
//      plus an explicit "X" (drop) line for entities that left the AoI
//      or were destroyed. Every `fullSnapshotEvery` ticks we resync the
//      entire visible set so a dropped frame eventually corrects.

const (
	// aoiRadius is the half-extent of the visible square. With 16-pixel
	// tiles and a 1280×720 client window the player can see ~40×22 in
	// the worst case; 24 covers it with margin for camera lead.
	aoiRadius = 24
	// fullSnapshotEvery forces a fresh full broadcast at this cadence
	// to cap the lifetime of any per-client desync. 30 Hz tick × 30 =
	// once per second.
	fullSnapshotEvery = 30 * time.Millisecond * 30
)

// snapKey identifies a tracked entity inside a player's seen-set. We
// can't reuse the raw EntityID because Player IDs and Enemy IDs come
// from independent sequences; a (kind, id) pair is unique across all
// three sources.
type snapKey struct {
	kind byte // 'P', 'E', 'N'
	id   int
}

// snapState is the abridged state we track per visible entity. The
// fields are everything the wire frame carries that can change inside
// a single tick. If two consecutive ticks produce the same snapState
// the entity is omitted.
type snapState struct {
	x, y        int     // integer tile coords for E / N
	fx, fy      float64 // interpolated coords for P
	face        int     // packed FaceX, FaceY (player only)
	hp, maxHP   int
	mp, maxMP   int
	atk         bool   // player attack flag
	name        string // player name / npc kind
	kind        string // enemy kind (sprite hint)
	sprite      string // npc sprite id (Sprites.npcSprites key)
	missingKey  bool   // sentinel: never written, used as zero-value check
}

// equal returns true when two states render to the same wire frame.
func (a snapState) equal(b snapState) bool {
	return a == b
}

// buildPlayerSnapshot builds the wire payload destined for a single
// player. Uses the AoI radius around the player's tile to filter, and
// diffs against p.LastSeen to skip unchanged entities. Caller must
// hold g.mu.
func (g *Game) buildPlayerSnapshot(viewer *Player, now time.Time) string {
	if viewer == nil || viewer.Entity == nil || viewer.Entity.Position == nil {
		return ""
	}
	if viewer.LastSeen == nil {
		viewer.LastSeen = make(map[snapKey]snapState)
	}
	full := false
	if viewer.LastFull.IsZero() || now.Sub(viewer.LastFull) >= fullSnapshotEvery {
		full = true
		viewer.LastFull = now
		// On a full pass we forget what we know so every visible entity
		// re-emits its state line. The drop pass below will not run
		// because seenThisTick covers the same set.
		viewer.LastSeen = make(map[snapKey]snapState)
	}

	cx, cy := viewer.Entity.Position.X, viewer.Entity.Position.Y
	var b strings.Builder
	seenThisTick := make(map[snapKey]struct{}, len(viewer.LastSeen))

	emit := func(key snapKey, st snapState, line string) {
		seenThisTick[key] = struct{}{}
		prev, had := viewer.LastSeen[key]
		if had && prev.equal(st) {
			return
		}
		b.WriteString(line)
		viewer.LastSeen[key] = st
	}

	for _, p := range g.players {
		if p.Name == "" || p.Entity == nil || p.Entity.Position == nil || p.Entity.Health == nil {
			continue
		}
		pos := p.Entity.Position
		if !inAoI(cx, cy, pos.X, pos.Y) && p.ID != viewer.ID {
			continue
		}
		hp := p.Entity.Health
		x, y := positionInterpolated(pos, now)
		atk := false
		if p.Entity.Combat != nil && now.Before(p.Entity.Combat.AttackUntil) {
			atk = true
		}
		st := snapState{
			fx: round3(x), fy: round3(y),
			face:  pos.FaceX*8 + pos.FaceY,
			hp:    hp.HP, maxHP: hp.MaxHP,
			mp: hp.MP, maxMP: hp.MaxMP,
			atk:  atk,
			name: p.Name,
		}
		atkInt := 0
		if atk {
			atkInt = 1
		}
		line := fmt.Sprintf("P %d %.3f %.3f %d %d %d %d %d %d %d %s\n",
			p.ID, x, y, pos.FaceX, pos.FaceY,
			hp.HP, hp.MaxHP, hp.MP, hp.MaxMP, atkInt, p.Name)
		emit(snapKey{'P', p.ID}, st, line)
	}

	for _, e := range g.enemies {
		if e.Entity == nil || e.Entity.Position == nil || e.Entity.Health == nil {
			continue
		}
		pos := e.Entity.Position
		if !inAoI(cx, cy, pos.X, pos.Y) {
			continue
		}
		hp := e.Entity.Health
		st := snapState{
			x: pos.X, y: pos.Y,
			hp: hp.HP, maxHP: hp.MaxHP,
			kind: e.Kind,
		}
		line := fmt.Sprintf("E %d %s %d %d %d %d\n",
			e.ID, e.Kind, pos.X, pos.Y, hp.HP, hp.MaxHP)
		emit(snapKey{'E', e.ID}, st, line)
	}

	if g.ecs != nil {
		g.ecs.Each(func(en *Entity) {
			if en.Kind != KindNPC || en.Position == nil {
				return
			}
			if !inAoI(cx, cy, en.Position.X, en.Position.Y) {
				return
			}
			sprite := en.Sprite
			if sprite == "" {
				sprite = "-"
			}
			st := snapState{
				x: en.Position.X, y: en.Position.Y,
				name:   en.Name,
				sprite: en.Sprite,
			}
			// Wire format: `N <id> <name> <x> <y> <sprite>`. The trailing
			// sprite token is "-" when no artwork is assigned so older
			// clients (which stop parsing at y) keep working unchanged.
			line := fmt.Sprintf("N %d %s %d %d %s\n",
				en.ID, en.Name, en.Position.X, en.Position.Y, sprite)
			emit(snapKey{'N', int(en.ID)}, st, line)
		})
	}

	if !full {
		// Anything previously visible but absent from this tick has
		// either left the AoI or been destroyed. Tell the client to
		// drop it; LEAVE/EDIE already handle disconnects/kills, but the
		// AoI departure case isn't covered by those events.
		for key := range viewer.LastSeen {
			if _, still := seenThisTick[key]; still {
				continue
			}
			fmt.Fprintf(&b, "X %c %d\n", key.kind, key.id)
			delete(viewer.LastSeen, key)
		}
	}

	return b.String()
}

// round3 quantises a float to the nearest 1/1000 so jitter below the
// rendered pixel doesn't trigger snapshot rewrites every tick.
func round3(v float64) float64 {
	if v >= 0 {
		return float64(int(v*1000+0.5)) / 1000
	}
	return float64(int(v*1000-0.5)) / 1000
}

// inAoI is a Chebyshev-distance check around (cx, cy).
func inAoI(cx, cy, x, y int) bool {
	dx := x - cx
	if dx < 0 {
		dx = -dx
	}
	dy := y - cy
	if dy < 0 {
		dy = -dy
	}
	if dx > dy {
		return dx <= aoiRadius
	}
	return dy <= aoiRadius
}

// resetSeenForRespawn clears a player's seen set so a teleport to a
// fresh AoI region does not leave stale "X" drop lines for entities
// that simply moved out of view by virtue of the player relocating.
// Caller must hold g.mu.
func resetSeenForRespawn(p *Player) {
	if p == nil {
		return
	}
	p.LastSeen = nil
	p.LastFull = time.Time{}
}
