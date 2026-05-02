package main

import (
	"testing"
)

// TestScriptEngineLoadsAllDomains verifies the bundled data/ tree
// parses without warnings — items, npcs, quests, progression.
func TestScriptEngineLoadsAllDomains(t *testing.T) {
	e := NewScriptEngine("data/scripts")
	e.LoadAll()

	if len(e.Items()) == 0 {
		t.Fatal("expected items to load from data/scripts/items")
	}
	if len(e.NPCs()) == 0 {
		t.Fatal("expected npcs to load from data/scripts/npcs")
	}
	if len(e.Quests()) == 0 {
		t.Fatal("expected quests to load from data/scripts/quests")
	}
	pd := e.Progression()
	if pd.XPBase <= 0 {
		t.Fatalf("progression should be loaded, got %+v", pd)
	}

	// Spot-check shapes the rest of the engine relies on.
	if it, ok := e.Item("orc_tooth"); !ok || !it.Bound {
		t.Fatalf("orc_tooth should load and be bound: %+v", it)
	}
	if it, ok := e.Item("rusty_sword"); !ok || it.Slot != "weapon" {
		t.Fatalf("rusty_sword should equip in weapon slot: %+v", it)
	}
	if q, ok := e.Quest("orc_hunt"); !ok || q.KillTarget != "orc" || q.KillCount != 3 {
		t.Fatalf("orc_hunt malformed: %+v", q)
	}
	if def, ok := e.NPC("elder"); !ok || def.Nodes["start"] == nil {
		t.Fatalf("elder npc missing start node: %+v", def)
	}
}

func TestParseNPCDefRequiresStart(t *testing.T) {
	bad := map[string]interface{}{
		"id": "x",
		"dialog": map[string]interface{}{
			"hi": map[string]interface{}{"text": "hello"},
		},
	}
	if _, err := parseNPCDef(bad, "x"); err == nil {
		t.Fatal("expected error when start node is missing")
	}
	good := map[string]interface{}{
		"id": "x",
		"dialog": map[string]interface{}{
			"start": map[string]interface{}{
				"text": "hi",
				"options": []interface{}{
					map[string]interface{}{"text": "bye", "next_node": "end"},
				},
			},
		},
	}
	def, err := parseNPCDef(good, "x")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(def.Nodes["start"].Options) != 1 {
		t.Fatalf("options not parsed: %+v", def.Nodes["start"])
	}
}
