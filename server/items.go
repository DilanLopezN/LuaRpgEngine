package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Phase 4 — Items.
//
// ItemDefs live as data in two surfaces:
//   - data/scripts/items/<id>.lua          (canonical, designer-authored)
//   - data/scripts/items_user/<id>.json    (in-game editor authored)
//
// Both formats parse to the same ItemDef struct. The editor writes JSON
// so changes round-trip without forcing the designer to learn Lua.
//
// An ItemDef now carries: type (weapon/armor/helmet/shield/staff/ring/
// amulet/boots/consumable/quest/key/material/currency), sprite (icon id
// rendered by the client), damage / defense (combat numbers folded
// into derivedAttack/derivedDefense), description, level requirement,
// gold value, two-handed flag, and an on_use payload (heal HP/MP)
// consumed by handleUseItem. The Slot is derived from Type so the
// editor only has to set Type and the equipping pipeline knows where
// it goes.

// ItemType is the closed set of item kinds. Adding a new kind here
// means the editor catalog and slot mapping need updating in the same
// commit so designers never see a broken type tag.
const (
	ItemTypeNone       = "none"
	ItemTypeWeapon     = "weapon"
	ItemTypeStaff      = "staff"
	ItemTypeShield     = "shield"
	ItemTypeArmor      = "armor"
	ItemTypeHelmet     = "helmet"
	ItemTypeBoots      = "boots"
	ItemTypeRing       = "ring"
	ItemTypeAmulet     = "amulet"
	ItemTypeConsumable = "consumable"
	ItemTypeQuest      = "quest"
	ItemTypeKey        = "key"
	ItemTypeMaterial   = "material"
	ItemTypeCurrency   = "currency"
)

// itemTypes is the validation set used by the parser. Sorted callers
// iterate slotForType / itemTypeOrder.
var itemTypes = map[string]bool{
	ItemTypeNone: true, ItemTypeWeapon: true, ItemTypeStaff: true,
	ItemTypeShield: true, ItemTypeArmor: true, ItemTypeHelmet: true,
	ItemTypeBoots: true, ItemTypeRing: true, ItemTypeAmulet: true,
	ItemTypeConsumable: true, ItemTypeQuest: true, ItemTypeKey: true,
	ItemTypeMaterial: true, ItemTypeCurrency: true,
}

// slotForType maps an item type to the equipment slot it occupies. An
// empty result means "non-equippable" — consumables, quest items,
// materials, currency.
func slotForType(t string) string {
	switch t {
	case ItemTypeWeapon, ItemTypeStaff:
		return "weapon"
	case ItemTypeShield:
		return "offhand"
	case ItemTypeArmor:
		return "armor"
	case ItemTypeHelmet:
		return "helmet"
	case ItemTypeBoots:
		return "boots"
	case ItemTypeRing:
		return "ring"
	case ItemTypeAmulet:
		return "trinket"
	}
	return ""
}

// itemSlots is the closed set of equipment slots accepted on EQUIP
// frames. "trinket" is the legacy name for amulet — kept so older
// inventories still equip without a migration step.
var itemSlots = map[string]bool{
	"":        true,
	"none":    true,
	"weapon":  true,
	"offhand": true,
	"armor":   true,
	"helmet":  true,
	"boots":   true,
	"ring":    true,
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

// ItemUseEffect is the structured side-effect a consumable applies.
// Heal* are the only fields the runtime currently consumes; future
// additions (cast spell, summon, etc.) would extend this struct.
type ItemUseEffect struct {
	HealHP int `json:"heal_hp,omitempty"`
	HealMP int `json:"heal_mp,omitempty"`
	Buff   string `json:"buff,omitempty"`   // status id applied on use
	BuffMs int    `json:"buff_ms,omitempty"`// duration of the buff
}

// ItemDef is the shared template behind every ItemRef in an inventory.
// The pointer is read-only at runtime; mutations would surface across
// every player carrying the item.
type ItemDef struct {
	ID          string
	Name        string
	Type        string         // weapon/armor/helmet/...; drives Slot
	Slot        string         // derived from Type unless explicit override
	Stack       int            // max stack size; 1 means unique
	Rarity      string         // "common" | "uncommon" | ...
	Bound       bool           // bound-on-pickup flag
	Sprite      string         // client-side icon id
	Description string         // tooltip text
	Damage      int            // weapon damage (folded into derivedAttack)
	Defense     int            // armor defense (folded into derivedDefense)
	LevelReq    int            // minimum level required to equip / use
	Value       int            // gold value (sell price)
	TwoHanded   bool           // weapon occupies both weapon + offhand
	Attrs       map[string]int // extra stat bonuses while equipped
	OnUse       ItemUseEffect  // consumable payload
}

// IsEquippable reports whether the item can be put into a slot. The
// runtime uses this both to gate EQUIP and to render hints in the UI.
func (d *ItemDef) IsEquippable() bool {
	if d == nil {
		return false
	}
	return d.Slot != "" && d.Slot != "none"
}

// IsConsumable reports whether the item should respond to the USE
// command (drink potion, eat food, read scroll). Consumables are never
// equippable and decrement their stack on use.
func (d *ItemDef) IsConsumable() bool {
	if d == nil {
		return false
	}
	if d.Type == ItemTypeConsumable {
		return true
	}
	// Any item with a heal payload is treated as consumable even if the
	// designer forgot to set Type — so old `health_potion` still works.
	return d.OnUse.HealHP > 0 || d.OnUse.HealMP > 0
}

// parseItemDef converts a Lua-loaded table into an ItemDef. The rules
// match the rest of the loaders: typos in slot/rarity surface as load
// errors so a bad file is loud instead of silently producing junk.
//
// Backward-compat: legacy items (rusty_sword, leather_armor, ...) only
// declared `slot` and `attrs`. Those keep parsing — if Type is missing
// we infer it from Slot so the new client UI still picks up a sane
// type tag.
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

	typ := strings.ToLower(asString(m["type"]))
	slot := strings.ToLower(asString(m["slot"]))

	// Slot takes precedence when set explicitly, but Type drives the
	// canonical mapping for new items.
	if typ == "" {
		typ = inferTypeFromSlot(slot)
	}
	if !itemTypes[typ] {
		return nil, fmt.Errorf("unknown item type %q", typ)
	}
	if slot == "" {
		slot = slotForType(typ)
	}
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
	bound := asBool(m["bound"])
	twoHanded := asBool(m["two_handed"])

	attrs := map[string]int{}
	for k, v := range asMap(m["attrs"]) {
		attrs[k] = asInt(v)
	}

	use := ItemUseEffect{}
	if u := asMap(m["on_use"]); u != nil {
		use.HealHP = asInt(u["heal_hp"])
		use.HealMP = asInt(u["heal_mp"])
		use.Buff = asString(u["buff"])
		use.BuffMs = asInt(u["buff_ms"])
	}
	// Legacy compat: `attrs.hp` on a consumable used to be the heal
	// amount. Promote it to OnUse.HealHP if the new field is empty so
	// data/scripts/items/health_potion.lua keeps healing without an
	// edit.
	if typ == ItemTypeConsumable && use.HealHP == 0 {
		use.HealHP = attrs["hp"]
	}

	def := &ItemDef{
		ID:          id,
		Name:        name,
		Type:        typ,
		Slot:        slot,
		Stack:       stack,
		Rarity:      rarity,
		Bound:       bound,
		Sprite:      asString(m["sprite"]),
		Description: asString(m["description"]),
		Damage:      asInt(m["damage"]),
		Defense:     asInt(m["defense"]),
		LevelReq:    asInt(m["level_req"]),
		Value:       asInt(m["value"]),
		TwoHanded:   twoHanded,
		Attrs:       attrs,
		OnUse:       use,
	}
	return def, nil
}

// inferTypeFromSlot maps a legacy `slot` field back onto the new Type
// taxonomy so old items load with a sensible type tag.
func inferTypeFromSlot(slot string) string {
	switch slot {
	case "weapon":
		return ItemTypeWeapon
	case "offhand":
		return ItemTypeShield
	case "armor":
		return ItemTypeArmor
	case "helmet":
		return ItemTypeHelmet
	case "boots":
		return ItemTypeBoots
	case "ring":
		return ItemTypeRing
	case "trinket":
		return ItemTypeAmulet
	case "", "none":
		return ItemTypeMaterial
	}
	return ItemTypeMaterial
}

// formatItemDef ships an ItemDef to the client. The wire shape is now
// a single-line JSON document so newer fields (sprite, description,
// damage, level_req, ...) reach the renderer without another round of
// token surgery on every addition.
func formatItemDef(it *ItemDef) string {
	wire := struct {
		ID          string         `json:"id"`
		Name        string         `json:"name"`
		Type        string         `json:"type,omitempty"`
		Slot        string         `json:"slot,omitempty"`
		Stack       int            `json:"stack,omitempty"`
		Rarity      string         `json:"rarity,omitempty"`
		Bound       bool           `json:"bound,omitempty"`
		Sprite      string         `json:"sprite,omitempty"`
		Description string         `json:"description,omitempty"`
		Damage      int            `json:"damage,omitempty"`
		Defense     int            `json:"defense,omitempty"`
		LevelReq    int            `json:"level_req,omitempty"`
		Value       int            `json:"value,omitempty"`
		TwoHanded   bool           `json:"two_handed,omitempty"`
		Attrs       map[string]int `json:"attrs,omitempty"`
		OnUse       *ItemUseEffect `json:"on_use,omitempty"`
	}{
		ID: it.ID, Name: it.Name, Type: it.Type, Slot: it.Slot,
		Stack: it.Stack, Rarity: it.Rarity, Bound: it.Bound,
		Sprite: it.Sprite, Description: it.Description,
		Damage: it.Damage, Defense: it.Defense, LevelReq: it.LevelReq,
		Value: it.Value, TwoHanded: it.TwoHanded, Attrs: it.Attrs,
	}
	if it.OnUse != (ItemUseEffect{}) {
		ou := it.OnUse
		wire.OnUse = &ou
	}
	b, err := json.Marshal(wire)
	if err != nil {
		return fmt.Sprintf("ITEM_DEF {\"id\":\"%s\",\"name\":\"%s\"}\n",
			it.ID, it.Name)
	}
	return "ITEM_DEF " + string(b) + "\n"
}

func boolToFlag(b bool) string {
	if b {
		return "1"
	}
	return "0"
}

// --- Item user authoring (data/scripts/items_user/) -----------------------
//
// Mirrors the npcs_user/ + quests_user/ flow. The editor writes JSON
// here, the loader picks it up alongside the Lua bucket, and same-id
// collisions resolve in favour of the user file (so a designer can
// override a stock item without editing the canonical Lua).

func userItemDir(root string) string {
	return filepath.Join(root, "items_user")
}

// LoadUserItemJSON parses a single editor-authored item file.
func LoadUserItemJSON(path string) (*ItemDef, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var raw interface{}
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("parse item %s: %w", path, err)
	}
	base := strings.TrimSuffix(filepath.Base(path), ".json")
	return parseItemDef(raw, base)
}

func listUserItemFiles(root string) ([]string, error) {
	dir := userItemDir(root)
	entries, err := os.ReadDir(dir)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil, nil
		}
		return nil, err
	}
	var out []string
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".json") {
			continue
		}
		out = append(out, filepath.Join(dir, e.Name()))
	}
	sort.Strings(out)
	return out, nil
}

// SaveUserItemDef serialises an ItemDef back to items_user/<id>.json.
// The document mirrors parseItemDef's input shape so a round-trip is
// lossless.
func SaveUserItemDef(root string, def *ItemDef) error {
	if def == nil || def.ID == "" {
		return errors.New("item def: missing id")
	}
	clean := sanitizeNPCID(def.ID)
	if clean == "" {
		return errors.New("item def: invalid id")
	}
	dir := userItemDir(root)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	doc := itemDefToDoc(def)
	data, err := json.MarshalIndent(doc, "", "  ")
	if err != nil {
		return err
	}
	p := filepath.Join(dir, clean+".json")
	tmp := p + ".tmp"
	if err := os.WriteFile(tmp, data, 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, p)
}

func DeleteUserItemDef(root, id string) error {
	clean := sanitizeNPCID(id)
	if clean == "" {
		return errors.New("invalid id")
	}
	p := filepath.Join(userItemDir(root), clean+".json")
	if err := os.Remove(p); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	return nil
}

func itemDefToDoc(def *ItemDef) map[string]interface{} {
	doc := map[string]interface{}{
		"id":   def.ID,
		"name": def.Name,
	}
	if def.Type != "" {
		doc["type"] = def.Type
	}
	if def.Slot != "" {
		doc["slot"] = def.Slot
	}
	if def.Stack > 0 {
		doc["stack"] = def.Stack
	}
	if def.Rarity != "" {
		doc["rarity"] = def.Rarity
	}
	if def.Bound {
		doc["bound"] = true
	}
	if def.Sprite != "" {
		doc["sprite"] = def.Sprite
	}
	if def.Description != "" {
		doc["description"] = def.Description
	}
	if def.Damage > 0 {
		doc["damage"] = def.Damage
	}
	if def.Defense > 0 {
		doc["defense"] = def.Defense
	}
	if def.LevelReq > 0 {
		doc["level_req"] = def.LevelReq
	}
	if def.Value > 0 {
		doc["value"] = def.Value
	}
	if def.TwoHanded {
		doc["two_handed"] = true
	}
	if len(def.Attrs) > 0 {
		attrs := map[string]interface{}{}
		for k, v := range def.Attrs {
			attrs[k] = v
		}
		doc["attrs"] = attrs
	}
	if def.OnUse != (ItemUseEffect{}) {
		ou := map[string]interface{}{}
		if def.OnUse.HealHP > 0 {
			ou["heal_hp"] = def.OnUse.HealHP
		}
		if def.OnUse.HealMP > 0 {
			ou["heal_mp"] = def.OnUse.HealMP
		}
		if def.OnUse.Buff != "" {
			ou["buff"] = def.OnUse.Buff
		}
		if def.OnUse.BuffMs > 0 {
			ou["buff_ms"] = def.OnUse.BuffMs
		}
		doc["on_use"] = ou
	}
	return doc
}
