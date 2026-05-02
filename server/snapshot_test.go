package main

import (
	"strings"
	"testing"
	"time"
)

// addPlayerWithEntity is a helper that builds a Player with a fully
// populated ECS Entity so the snapshot pipeline has something to read.
func addPlayerWithEntity(g *Game, name string, x, y int) *Player {
	p := addNamedPlayerAt(g, name, x, y)
	p.LastSeen = make(map[snapKey]snapState)
	p.Entity = g.ecs.Add(&Entity{
		Kind: KindPlayer,
		Position: &CPosition{
			X: x, Y: y, FromX: x, FromY: y,
			FaceX: 0, FaceY: 1,
		},
		Health: &CHealth{HP: p.HP, MaxHP: p.MaxHP, MP: p.MP, MaxMP: p.MaxMP},
		Combat: &CCombat{Damage: attackDamage, Range: attackRange, Cooldown: attackCD},
	})
	return p
}

func TestPlayerSnapshotEmitsAndDiffs(t *testing.T) {
	g := newTestGame(t)
	viewer := addPlayerWithEntity(g, "viewer", 5, 5)
	other := addPlayerWithEntity(g, "other", 6, 5)

	now := time.Now()
	first := g.buildPlayerSnapshot(viewer, now)
	if !strings.Contains(first, "P "+itoa(viewer.ID)) {
		t.Fatalf("first snapshot should include viewer: %q", first)
	}
	if !strings.Contains(first, "P "+itoa(other.ID)) {
		t.Fatalf("first snapshot should include other player: %q", first)
	}

	second := g.buildPlayerSnapshot(viewer, now)
	if second != "" {
		t.Fatalf("unchanged second snapshot must be empty, got %q", second)
	}

	// Move the other player; the diff should now contain only that one.
	other.Entity.Position.X = 7
	third := g.buildPlayerSnapshot(viewer, now)
	if !strings.Contains(third, "P "+itoa(other.ID)) {
		t.Fatalf("expected mover to re-emit: %q", third)
	}
	if strings.Contains(third, "P "+itoa(viewer.ID)) {
		t.Fatalf("viewer did not move; should not re-emit: %q", third)
	}
}

func TestPlayerSnapshotDropsEntitiesLeavingAoI(t *testing.T) {
	g := newTestGame(t)
	viewer := addPlayerWithEntity(g, "viewer", 5, 5)
	other := addPlayerWithEntity(g, "stranger", 8, 8)

	now := time.Now()
	if frame := g.buildPlayerSnapshot(viewer, now); !strings.Contains(frame, "stranger") {
		t.Fatalf("setup: stranger should be visible inside AoI: %q", frame)
	}

	// Teleport stranger far outside the AoI — they should appear in
	// the next frame as an "X" drop line.
	other.Entity.Position.X = 5 + aoiRadius*2
	other.Entity.Position.Y = 5 + aoiRadius*2
	other.TileX, other.TileY = other.Entity.Position.X, other.Entity.Position.Y

	frame := g.buildPlayerSnapshot(viewer, now)
	if !strings.Contains(frame, "X P "+itoa(other.ID)) {
		t.Fatalf("expected drop line for departed player, got %q", frame)
	}
	if strings.Contains(frame, "stranger") {
		t.Fatalf("stranger must not re-emit after leaving AoI: %q", frame)
	}
}

func TestTokenBucketAllowsBurstThenThrottles(t *testing.T) {
	bk := newBucket(3, 50*time.Millisecond)
	now := time.Now()
	for i := 0; i < 3; i++ {
		if !bk.allow(now) {
			t.Fatalf("burst %d should pass", i)
		}
	}
	if bk.allow(now) {
		t.Fatalf("post-burst call must be denied without time advance")
	}
	if !bk.allow(now.Add(60 * time.Millisecond)) {
		t.Fatalf("after refill window the bucket should re-allow")
	}
}

// itoa avoids pulling strconv into the test file for a single call.
func itoa(i int) string {
	if i == 0 {
		return "0"
	}
	neg := i < 0
	if neg {
		i = -i
	}
	var buf [20]byte
	pos := len(buf)
	for i > 0 {
		pos--
		buf[pos] = byte('0' + i%10)
		i /= 10
	}
	if neg {
		pos--
		buf[pos] = '-'
	}
	return string(buf[pos:])
}
