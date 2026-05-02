package main

import (
	"errors"
	"fmt"
	"strings"
)

// Phase 4 — Items.
//
// ItemDefs live as data in data/scripts/items/<id>.lua. The format is
// intentionally tiny: id, name, slot, stack, rarity, bound flag, and a
// flat attribute map applied while equipped. Adding a new item means
// dropping a .lua file — the loader picks it up on /reload items.

// itemSlots constrains where an equippable item lives. Empty / "none"
// means the item is just inventory clutter (potion, gold, quest item).
var itemSlots = map[string]bool{
	"":        true,
	"none":    true,
	"weapon":  true,
	"armor":   true,
	"helmet":  true,
	"trinket": true,
}

// itemRarities is the closed set of rarities. Designers have to use one
// of these so client UI / drop weighting can switch on the value.
var itemRarities = map[string]bool{
	"common":    true,
	"uncommon":  true,
	"rare":      true,
	"epic":      true,
	"legendary": true,
}

// ItemDef is the shared template behind every ItemRef in an inventory.
// The pointer is read-only at runtime; mutations would surface across
// every player carrying the item.
type ItemDef struct {
	ID     string
	Name   string
	Slot   string
	Stack  int            // max stack size; 1 means unique
	Rarity string         // "common" | "uncommon" | ...
	Bound  bool           // bound-on-pickup flag
	Attrs  map[string]int // hp, mp, atk, def, str, dex, int, vit
}

// parseItemDef converts a Lua-loaded table into an ItemDef. The rules
// match the rest of the loaders: typos in slot/rarity surface as load
// errors so a bad file is loud instead of silently producing junk.
func parseItemDef(raw interface{}, fallbackID string) (*ItemDef, error) {
	m := asMap(raw)
	if m == nil {
		return nil, errors.New("item must be a table")
	}
	id := asString(m["id"])
	if id == "" {
		id = fallbackID
	}
	name := asString(m["name"])
	if name == "" {
		name = id
	}
	slot := strings.ToLower(asString(m["slot"]))
	if !itemSlots[slot] {
		return nil, fmt.Errorf("unknown item slot %q", slot)
	}
	rarity := strings.ToLower(asString(m["rarity"]))
	if rarity == "" {
		rarity = "common"
	}
	if !itemRarities[rarity] {
		return nil, fmt.Errorf("unknown rarity %q", rarity)
	}
	stack := asInt(m["stack"])
	if stack <= 0 {
		stack = 1
	}
	if stack > 9999 {
		stack = 9999
	}
	bound := false
	if v, ok := m["bound"].(bool); ok {
		bound = v
	}
	attrs := map[string]int{}
	for k, v := range asMap(m["attrs"]) {
		attrs[k] = asInt(v)
	}
	return &ItemDef{
		ID:     id,
		Name:   name,
		Slot:   slot,
		Stack:  stack,
		Rarity: rarity,
		Bound:  bound,
		Attrs:  attrs,
	}, nil
}

// formatItemDef ships an ItemDef to the client so UI can render names
// and tooltips without holding the Lua source.
func formatItemDef(it *ItemDef) string {
	return fmt.Sprintf("ITEM_DEF %s %s %s %d %s %d %s\n",
		it.ID, it.Slot, it.Rarity, it.Stack,
		boolToFlag(it.Bound),
		len(it.Attrs),
		strings.ReplaceAll(it.Name, " ", "_"))
}

func boolToFlag(b bool) string {
	if b {
		return "1"
	}
	return "0"
}
