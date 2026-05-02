package main

import (
	"encoding/json"
	"strings"
	"testing"
	"time"
)

func TestECSWorldAddRemove(t *testing.T) {
	w := NewECSWorld()
	a := w.Add(&Entity{Kind: KindEnemy, Health: &CHealth{HP: 10, MaxHP: 10}})
	b := w.Add(&Entity{Kind: KindPlayer, Position: &CPosition{X: 1, Y: 2}})
	if a.ID == 0 || b.ID == 0 || a.ID == b.ID {
		t.Fatalf("expected unique non-zero ids, got %d / %d", a.ID, b.ID)
	}
	if got := w.Count(); got != 2 {
		t.Fatalf("count=%d", got)
	}
	if w.Get(a.ID) != a {
		t.Fatal("get returned a different pointer")
	}
	if !w.Remove(a.ID) {
		t.Fatal("Remove(existing) returned false")
	}
	if w.Remove(a.ID) {
		t.Fatal("Remove(missing) returned true")
	}
	if w.Get(a.ID) != nil {
		t.Fatal("Get after Remove should be nil")
	}

	enemies := w.ByKind(KindEnemy)
	if len(enemies) != 0 {
		t.Fatalf("ByKind(enemy)=%d", len(enemies))
	}
	players := w.ByKind(KindPlayer)
	if len(players) != 1 || players[0].ID != b.ID {
		t.Fatalf("ByKind(player)=%v", players)
	}
}

func TestSystemPipelineSettlesMovement(t *testing.T) {
	w := NewECSWorld()
	now := time.Unix(0, 0)
	e := w.Add(&Entity{
		Kind: KindPlayer,
		Position: &CPosition{
			X: 5, Y: 5, FromX: 4, FromY: 5,
			Stepping: true, StepStart: now,
			StepDur: 200 * time.Millisecond,
		},
		Health: &CHealth{HP: 999, MaxHP: 100},
	})
	pipe := NewDefaultPipeline()

	pipe.Tick(w, now.Add(100*time.Millisecond), 33*time.Millisecond)
	if !e.Position.Stepping {
		t.Fatal("step ended early")
	}

	pipe.Tick(w, now.Add(250*time.Millisecond), 33*time.Millisecond)
	if e.Position.Stepping {
		t.Fatal("MovementSystem did not clear Stepping after StepDur")
	}
	if e.Position.FromX != e.Position.X || e.Position.FromY != e.Position.Y {
		t.Fatalf("FromX/Y not caught up: %+v", e.Position)
	}
	if e.Health.HP != e.Health.MaxHP {
		t.Fatalf("HealthSystem did not clamp HP: hp=%d max=%d",
			e.Health.HP, e.Health.MaxHP)
	}
}

func TestSnapshotOmitsMissingComponents(t *testing.T) {
	w := NewECSWorld()
	w.Add(&Entity{
		Kind: KindEnemy,
		Name: "orc",
		Position: &CPosition{X: 3, Y: 4, FaceX: 1, FaceY: 0},
		Health:   &CHealth{HP: 7, MaxHP: 30},
		AI:       &CAI{Kind: "orc", State: "idle"},
	})

	snap := w.SnapshotAt(42)
	if snap.Tick != 42 {
		t.Fatalf("tick=%d", snap.Tick)
	}
	if len(snap.Entities) != 1 {
		t.Fatalf("entities=%d", len(snap.Entities))
	}
	es := snap.Entities[0]
	if es.Position == nil || es.Health == nil || es.AI == nil {
		t.Fatalf("missing component on snapshot: %+v", es)
	}
	if es.Combat != nil || es.Inventory != nil {
		t.Fatalf("absent components leaked: %+v", es)
	}

	raw, err := json.Marshal(snap)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	s := string(raw)
	if !strings.Contains(s, `"kind":"enemy"`) ||
		!strings.Contains(s, `"hp":7`) ||
		!strings.Contains(s, `"x":3`) {
		t.Fatalf("unexpected wire shape: %s", s)
	}
	if strings.Contains(s, `"combat"`) || strings.Contains(s, `"inv"`) {
		t.Fatalf("nil components should be omitted: %s", s)
	}
}
