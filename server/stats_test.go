package main

import "testing"

func TestAwardXPRollsSingleLevel(t *testing.T) {
	g := newTestGame(t)
	g.progression = defaultProgression()
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.Stats = &CStats{Level: 1, NextX: g.progression.xpForLevel(1)}

	gained := g.awardXP(p, p.Stats.NextX+10)
	if gained != 1 {
		t.Fatalf("expected one level, got %d", gained)
	}
	if p.Stats.Level != 2 {
		t.Fatalf("level=%d, want 2", p.Stats.Level)
	}
	if p.Stats.XP != 10 {
		t.Fatalf("residual xp=%d, want 10", p.Stats.XP)
	}
	if p.Stats.NextX != g.progression.xpForLevel(2) {
		t.Fatalf("NextX not updated for level 2")
	}
	if p.HP != p.MaxHP {
		t.Fatalf("level-up should refill HP: %d/%d", p.HP, p.MaxHP)
	}
}

func TestAwardXPCascadesLevels(t *testing.T) {
	g := newTestGame(t)
	g.progression = defaultProgression()
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.Stats = &CStats{Level: 1, NextX: g.progression.xpForLevel(1)}

	huge := 0
	for i := 1; i <= 5; i++ {
		huge += g.progression.xpForLevel(i)
	}
	gained := g.awardXP(p, huge+1)
	if gained < 5 {
		t.Fatalf("expected at least 5 levels from cascading XP, got %d", gained)
	}
}

func TestApplyStatScaling(t *testing.T) {
	st := &CStats{Str: 10, Int: 5}
	got := applyStatScaling(20, map[string]float64{"int": 1.2}, st)
	if got != 26 {
		t.Fatalf("int scaling: want 26 (20 + 5*1.2), got %d", got)
	}
	got = applyStatScaling(10, map[string]float64{"str": 0.5}, st)
	if got != 15 {
		t.Fatalf("str scaling: want 15, got %d", got)
	}
	if applyStatScaling(0, map[string]float64{"str": 1}, st) != 0 {
		t.Fatal("scaling on 0 base must stay 0")
	}
}
