package main

import (
	"os"
	"path/filepath"
	"testing"
)

// TestParseItemDefRichSchema verifies the editor-driven schema (type
// drives slot, damage/defense/level_req/value parse, on_use captures
// heal payload) and that legacy items (slot + attrs.hp) still load
// with sensible Type / OnUse defaults.
func TestParseItemDefRichSchema(t *testing.T) {
	rich := map[string]interface{}{
		"id":          "broadsword",
		"name":        "Broadsword",
		"type":        "weapon",
		"rarity":      "rare",
		"sprite":      "icon_sword_steel",
		"description": "Pesada e equilibrada.",
		"damage":      8,
		"level_req":   5,
		"value":       120,
		"two_handed":  true,
		"attrs":       map[string]interface{}{"str": 2},
	}
	def, err := parseItemDef(rich, "broadsword")
	if err != nil {
		t.Fatalf("parse rich item: %v", err)
	}
	if def.Type != ItemTypeWeapon {
		t.Fatalf("Type=%q want weapon", def.Type)
	}
	if def.Slot != "weapon" {
		t.Fatalf("Slot=%q want weapon (derived from Type)", def.Slot)
	}
	if def.Damage != 8 || def.LevelReq != 5 || def.Value != 120 {
		t.Fatalf("damage/level/value mismatch: %+v", def)
	}
	if !def.TwoHanded {
		t.Fatal("expected two-handed flag")
	}
	if !def.IsEquippable() {
		t.Fatal("weapon should be equippable")
	}
	if def.IsConsumable() {
		t.Fatal("weapon must not be consumable")
	}

	// Legacy: slot + attrs.hp on a "consumable-like" item — Type missing.
	legacy := map[string]interface{}{
		"id":     "potion",
		"name":   "Potion",
		"slot":   "none",
		"stack":  99,
		"rarity": "common",
		"attrs":  map[string]interface{}{"hp": 25},
	}
	pdef, err := parseItemDef(legacy, "potion")
	if err != nil {
		t.Fatalf("parse legacy item: %v", err)
	}
	// Inferred type should land on material (slot=none → material).
	if pdef.Type == "" {
		t.Fatal("legacy parse must assign a type")
	}
	// Legacy attrs.hp on a real consumable would promote to OnUse.HealHP
	// only when Type==consumable. Verify the dedicated path explicitly.
	consum := map[string]interface{}{
		"id":    "lifedraft",
		"name":  "Lifedraft",
		"type":  "consumable",
		"stack": 10,
		"attrs": map[string]interface{}{"hp": 40},
	}
	cdef, err := parseItemDef(consum, "lifedraft")
	if err != nil {
		t.Fatalf("parse consumable: %v", err)
	}
	if cdef.OnUse.HealHP != 40 {
		t.Fatalf("legacy attrs.hp should fold into OnUse.HealHP, got %+v", cdef.OnUse)
	}
	if !cdef.IsConsumable() {
		t.Fatal("consumable type should be consumable")
	}
}

// TestSaveLoadUserItem round-trips an editor-authored item through
// disk so a designer's edits survive a restart untouched.
func TestSaveLoadUserItem(t *testing.T) {
	dir := t.TempDir()
	def := &ItemDef{
		ID: "magic_shield", Name: "Escudo Mágico",
		Type: ItemTypeShield, Slot: "offhand",
		Stack: 1, Rarity: "epic",
		Sprite: "icon_shield_iron", Description: "Brilha em runas.",
		Defense: 6, LevelReq: 8, Value: 800,
		Attrs: map[string]int{"int": 3},
	}
	if err := SaveUserItemDef(dir, def); err != nil {
		t.Fatalf("save: %v", err)
	}
	p := filepath.Join(dir, "items_user", "magic_shield.json")
	if _, err := os.Stat(p); err != nil {
		t.Fatalf("expected file at %s: %v", p, err)
	}
	loaded, err := LoadUserItemJSON(p)
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if loaded.Defense != 6 || loaded.LevelReq != 8 || loaded.Rarity != "epic" {
		t.Fatalf("round-trip mismatch: %+v", loaded)
	}
	if loaded.Attrs["int"] != 3 {
		t.Fatalf("attrs lost in round-trip: %+v", loaded.Attrs)
	}
	if err := DeleteUserItemDef(dir, "magic_shield"); err != nil {
		t.Fatalf("delete: %v", err)
	}
	if _, err := os.Stat(p); !os.IsNotExist(err) {
		t.Fatalf("file should be gone, stat err=%v", err)
	}
}
