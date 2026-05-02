package main

import (
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
