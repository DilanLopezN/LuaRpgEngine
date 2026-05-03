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

// Phase 4 — NPCs and quests.
//
// An NPC is a content piece authored either as a Lua table in
// data/scripts/npcs/<id>.lua (designer-authored, hot-reloadable) or as
// a JSON document in data/scripts/npcs_user/<id>.json (created in-game
// through the editor). Both formats parse to the same NPCDef struct.
//
// An NPC carries a tree of dialogue nodes plus a *role* that decides
// behaviour at runtime. Friendly / merchant / quest_giver NPCs are
// static and only react to TALK; guardian / enemy NPCs are alive,
// have HP, and engage hostile factions just like the data-driven
// enemies in data/scripts/enemies/.

// NPC roles. The role drives behaviour selection in the spawner — a
// guardian gets HP and combat AI, a merchant stays put waiting for
// dialog. Keep these as constants so other packages can compare them
// without typo risk.
const (
	NPCRoleFriendly   = "friendly"
	NPCRoleMerchant   = "merchant"
	NPCRoleQuestGiver = "quest_giver"
	NPCRoleGuardian   = "guardian"
	NPCRoleEnemy      = "enemy"
)

// NPC factions. Decide who attacks who on aggro: ally never attacks
// players, hostile attacks on sight, neutral retaliates only.
const (
	NPCFactionAlly    = "ally"
	NPCFactionNeutral = "neutral"
	NPCFactionHostile = "hostile"
)

// NPCDef is the on-disk template for an NPC. Newer fields all carry
// safe zero defaults so old (Lua) NPC files keep loading unchanged —
// only the original ID/Name/Title/Nodes are required.
type NPCDef struct {
	ID    string
	Name  string
	Title string

	// Role + faction drive runtime behaviour. Empty Role means
	// "friendly" so legacy NPCs (which never declared one) still
	// behave as before.
	Role    string
	Faction string

	// Default sprite used when a MapEntity placement does not pin
	// its own. Optional; empty falls back to the engine default.
	Sprite string

	// Combat profile. Only consulted for guardian / enemy NPCs.
	HP       int
	Damage   int
	Speed    float64
	Aggro    int // tile radius — guardians wake up at this distance
	XP       int
	// Loot fires on death (guardian/enemy only). Each entry is rolled
	// independently with `Chance` in basis points (1000 = 100%).
	Loot []NPCLootEntry

	// Quest binding. When non-empty, handleTalk auto-routes the player
	// to the right dialog node based on quest state (offer / in
	// progress / turn-in). The engine will also synthesize a default
	// dialog tree if the author left Nodes empty.
	Quest string

	Nodes map[string]*NPCNode
}

// NPCLootEntry is a structured drop. Mirrors the loot.lua shape so
// designers stay consistent across the two surfaces.
type NPCLootEntry struct {
	Item   string
	Qty    int
	Chance int // basis points; 1000 == 100%
}

// IsHostile reports whether spawnNPCsFromMap should treat this NPC as
// a combatant (HP, AI chase, drop on kill). Both role-based and
// HP-based answers are accepted so a designer can tag an NPC as
// "enemy" without spelling out HP and the engine still gives it a
// fight; or grant HP without committing to a role and the system
// still treats it as a guardian.
func (d *NPCDef) IsHostile() bool {
	if d == nil {
		return false
	}
	switch d.Role {
	case NPCRoleEnemy, NPCRoleGuardian:
		return true
	}
	return d.HP > 0
}

// IsCombatant is true for any NPC that has HP — guardians and enemies.
// Used by combat / loot pipelines.
func (d *NPCDef) IsCombatant() bool { return d.IsHostile() }

// NPCNode is a single dialogue beat. Text is what the NPC says;
// Options are the player's responses, each pointing at the next node
// (or "end" to close the dialog). Hooks fire when the player lands on
// the node — they're enough for "give a quest" / "complete a quest" /
// "advance an objective" without scripting more glue.
type NPCNode struct {
	ID      string
	Text    string
	Options []NPCOption
	OnEnter NPCHook
}

type NPCOption struct {
	Text string
	Goto string
	Hook NPCHook
}

// NPCHook is the structured side-effect a dialogue beat can perform.
// Type is "quest_start" | "quest_complete" | "quest_advance" |
// "give_item" | "take_item". Quest is the quest id; Item/Qty target
// the inventory ops.
type NPCHook struct {
	Type   string
	Quest  string
	Stage  string
	Item   string
	Qty    int
	Reward map[string]int
}

func parseNPCDef(raw interface{}, fallbackID string) (*NPCDef, error) {
	m := asMap(raw)
	if m == nil {
		return nil, errors.New("npc must be a table")
	}
	id := asString(m["id"])
	if id == "" {
		id = fallbackID
	}
	name := asString(m["name"])
	if name == "" {
		name = id
	}
	def := &NPCDef{
		ID:      id,
		Name:    name,
		Title:   asString(m["title"]),
		Role:    asString(m["role"]),
		Faction: asString(m["faction"]),
		Sprite:  asString(m["sprite"]),
		Quest:   asString(m["quest"]),
		HP:      asInt(m["hp"]),
		Damage:  asInt(m["damage"]),
		Speed:   asFloat(m["speed"]),
		Aggro:   asInt(m["aggro"]),
		XP:      asInt(m["xp"]),
	}
	for _, raw := range asSlice(m["loot"]) {
		em := asMap(raw)
		if em == nil {
			continue
		}
		entry := NPCLootEntry{
			Item:   asString(em["item"]),
			Qty:    asInt(em["qty"]),
			Chance: asInt(em["chance"]),
		}
		if entry.Qty <= 0 {
			entry.Qty = 1
		}
		if entry.Chance <= 0 {
			entry.Chance = 1000
		}
		if entry.Item == "" {
			continue
		}
		def.Loot = append(def.Loot, entry)
	}

	def.Nodes = make(map[string]*NPCNode)
	for nid, raw := range asMap(m["dialog"]) {
		nm := asMap(raw)
		if nm == nil {
			continue
		}
		node := &NPCNode{ID: nid, Text: asString(nm["text"])}
		node.OnEnter = parseHook(asMap(nm["on_enter"]))
		for _, opRaw := range asSlice(nm["options"]) {
			om := asMap(opRaw)
			if om == nil {
				continue
			}
			opt := NPCOption{
				Text: asString(om["text"]),
				Goto: asString(om["next_node"]),
				Hook: parseHook(asMap(om["hook"])),
			}
			node.Options = append(node.Options, opt)
		}
		def.Nodes[nid] = node
	}

	// Default role + faction so downstream code can switch without
	// nil-checks. An unspecified NPC is a friendly villager.
	if def.Role == "" {
		if def.HP > 0 {
			def.Role = NPCRoleEnemy
		} else if def.Quest != "" {
			def.Role = NPCRoleQuestGiver
		} else {
			def.Role = NPCRoleFriendly
		}
	}
	if def.Faction == "" {
		switch def.Role {
		case NPCRoleEnemy:
			def.Faction = NPCFactionHostile
		case NPCRoleGuardian:
			def.Faction = NPCFactionNeutral
		default:
			def.Faction = NPCFactionAlly
		}
	}

	// Auto-synthesize a default dialog when the designer left the
	// tree empty — gives the editor a one-click "create NPC" flow
	// without forcing them to author nodes by hand. If the author
	// *did* write nodes but accidentally skipped "start", we still
	// surface the error below so the typo is caught at load time.
	if len(def.Nodes) == 0 {
		if def.Quest != "" {
			synthesizeQuestDialog(def)
		} else {
			synthesizeDefaultDialog(def)
		}
	}

	if _, ok := def.Nodes["start"]; !ok {
		return nil, fmt.Errorf("npc %s: missing 'start' node", id)
	}
	return def, nil
}

// synthesizeQuestDialog fills a four-node tree (offer → accept →
// in-progress → turn-in) for a quest giver who didn't author one.
// The strings are deliberately generic; designers who want voice can
// override individual nodes by writing them into the JSON.
func synthesizeQuestDialog(def *NPCDef) {
	intro := "Saudações, viajante. Tenho uma tarefa, se aceitar."
	more := fmt.Sprintf("Preciso de ajuda com %s. Topa a missão?", def.Quest)
	accepted := "Que os antigos deuses te guiem."
	inProg := "O trabalho ainda não está terminado. Volte quando estiver."
	done := "Bom trabalho. Aceite isto como recompensa."

	def.Nodes = map[string]*NPCNode{
		"start": {
			ID: "start", Text: intro,
			Options: []NPCOption{
				{Text: "Conte-me mais.", Goto: "more"},
				{Text: "Adeus.", Goto: "end"},
			},
		},
		"more": {
			ID: "more", Text: more,
			Options: []NPCOption{
				{Text: "Eu aceito.", Goto: "accepted",
					Hook: NPCHook{Type: "quest_start", Quest: def.Quest}},
				{Text: "Hoje não.", Goto: "end"},
			},
		},
		"accepted": {
			ID: "accepted", Text: accepted,
			Options: []NPCOption{{Text: "Adeus.", Goto: "end"}},
		},
		"return_in_progress": {
			ID: "return_in_progress", Text: inProg,
			Options: []NPCOption{{Text: "Adeus.", Goto: "end"}},
		},
		"return_done": {
			ID: "return_done", Text: done,
			Options: []NPCOption{
				{Text: "Obrigado.", Goto: "end",
					Hook: NPCHook{Type: "quest_complete", Quest: def.Quest}},
			},
		},
	}
}

// synthesizeDefaultDialog creates a single-node greeting for plain
// friendly NPCs that didn't author any dialog. Keeps placement
// frictionless: drop sprite, no JSON needed for the simplest case.
func synthesizeDefaultDialog(def *NPCDef) {
	greeting := "Saudações."
	switch def.Role {
	case NPCRoleMerchant:
		greeting = "Confira minhas mercadorias."
	case NPCRoleGuardian:
		greeting = "Mantenha-se afastado de problemas, viajante."
	case NPCRoleEnemy:
		greeting = "Um inimigo te observa..."
	}
	def.Nodes = map[string]*NPCNode{
		"start": {
			ID: "start", Text: greeting,
			Options: []NPCOption{{Text: "Adeus.", Goto: "end"}},
		},
	}
}

func parseHook(m map[string]interface{}) NPCHook {
	if m == nil {
		return NPCHook{}
	}
	h := NPCHook{
		Type:  asString(m["type"]),
		Quest: asString(m["quest"]),
		Stage: asString(m["stage"]),
		Item:  asString(m["item"]),
		Qty:   asInt(m["qty"]),
	}
	if h.Qty <= 0 && h.Item != "" {
		h.Qty = 1
	}
	if rew := asMap(m["reward"]); rew != nil {
		h.Reward = map[string]int{}
		for k, v := range rew {
			h.Reward[k] = asInt(v)
		}
	}
	return h
}

// QuestDef describes a quest authored in data/scripts/quests/<id>.lua.
// Stages are walked in order; "complete" is the implicit final stage.
// Objectives live as kill counts / item counts checked by the host.
type QuestDef struct {
	ID         string
	Name       string
	Stages     []string
	KillTarget string
	KillCount  int
	ItemTarget string
	ItemCount  int
	RewardXP   int
	RewardGold int
	RewardItem string
	RewardQty  int
}

func parseQuestDef(raw interface{}, fallbackID string) (*QuestDef, error) {
	m := asMap(raw)
	if m == nil {
		return nil, errors.New("quest must be a table")
	}
	id := asString(m["id"])
	if id == "" {
		id = fallbackID
	}
	q := &QuestDef{
		ID:   id,
		Name: asString(m["name"]),
	}
	if q.Name == "" {
		q.Name = id
	}
	for _, s := range asSlice(m["stages"]) {
		q.Stages = append(q.Stages, asString(s))
	}
	if obj := asMap(m["objective"]); obj != nil {
		q.KillTarget = asString(obj["kill"])
		q.KillCount = asInt(obj["count"])
		q.ItemTarget = asString(obj["item"])
		q.ItemCount = asInt(obj["item_count"])
	}
	if rew := asMap(m["reward"]); rew != nil {
		q.RewardXP = asInt(rew["xp"])
		q.RewardGold = asInt(rew["gold"])
		q.RewardItem = asString(rew["item"])
		q.RewardQty = asInt(rew["qty"])
	}
	return q, nil
}

// QuestState is the per-player progress on a quest.
type QuestState struct {
	ID        string
	Stage     string // "active" | "complete" | custom stage from def
	KillCount int
	Done      bool
}

// formatNPCDef ships an NPC to the client. The wire shape is now a
// single-line JSON document so newer fields (role/faction/quest/etc.)
// reach the renderer without another round of token surgery on every
// addition. Older clients that expected the legacy
// `NPC_DEF id name title` layout would have to be updated, but the
// editor + renderer in this repo are the only consumers.
func formatNPCDef(def *NPCDef) string {
	wire := struct {
		ID      string `json:"id"`
		Name    string `json:"name"`
		Title   string `json:"title,omitempty"`
		Role    string `json:"role,omitempty"`
		Faction string `json:"faction,omitempty"`
		Sprite  string `json:"sprite,omitempty"`
		HP      int    `json:"hp,omitempty"`
		Damage  int    `json:"damage,omitempty"`
		Speed   float64 `json:"speed,omitempty"`
		Aggro   int    `json:"aggro,omitempty"`
		XP      int    `json:"xp,omitempty"`
		Quest   string `json:"quest,omitempty"`
	}{
		ID: def.ID, Name: def.Name, Title: def.Title,
		Role: def.Role, Faction: def.Faction, Sprite: def.Sprite,
		HP: def.HP, Damage: def.Damage, Speed: def.Speed,
		Aggro: def.Aggro, XP: def.XP, Quest: def.Quest,
	}
	b, err := json.Marshal(wire)
	if err != nil {
		// Should never happen for plain types — fall back to a
		// minimal payload so the wire remains parseable.
		return fmt.Sprintf("NPC_DEF {\"id\":\"%s\",\"name\":\"%s\"}\n",
			def.ID, def.Name)
	}
	return "NPC_DEF " + string(b) + "\n"
}

func formatQuestDef(q *QuestDef) string {
	return fmt.Sprintf("QUEST_DEF %s %s %s %d %s %d %d %d\n",
		q.ID,
		strings.ReplaceAll(q.Name, " ", "_"),
		emptyDash(q.KillTarget), q.KillCount,
		emptyDash(q.ItemTarget), q.ItemCount,
		q.RewardXP, q.RewardGold)
}

func emptyDash(s string) string {
	if s == "" {
		return "-"
	}
	return s
}

// --- JSON-on-disk surface (npcs_user/) -------------------------------------

// userNPCDir is the bucket the editor writes into. Files are named
// <id>.json. This sits next to the Lua npc dir so designers can
// promote a user-authored NPC into the canonical content tree by
// porting the JSON to Lua — no schema translation needed.
func userNPCDir(root string) string {
	return filepath.Join(root, "npcs_user")
}

// LoadUserNPCJSON parses a single JSON file into an NPCDef. The
// document mirrors `parseNPCDef`'s map shape — load it as a generic
// interface{} so the parser stays single-source-of-truth.
func LoadUserNPCJSON(path string) (*NPCDef, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var raw interface{}
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("parse npc %s: %w", path, err)
	}
	base := strings.TrimSuffix(filepath.Base(path), ".json")
	return parseNPCDef(raw, base)
}

// listUserNPCFiles lists every .json file in npcs_user/ (sorted, so
// load order is stable). Missing dir is not an error — a fresh repo
// has no user NPCs yet.
func listUserNPCFiles(root string) ([]string, error) {
	dir := userNPCDir(root)
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

// SaveUserNPCDef serialises an NPCDef back to npcs_user/<id>.json.
// Used by the in-game editor's "Save NPC" path. The serialisation is
// the document the parser accepts so a round-trip preserves the
// design.
func SaveUserNPCDef(root string, def *NPCDef) error {
	if def == nil || def.ID == "" {
		return errors.New("npc def: missing id")
	}
	clean := sanitizeNPCID(def.ID)
	if clean == "" {
		return errors.New("npc def: invalid id")
	}
	dir := userNPCDir(root)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	doc := npcDefToDoc(def)
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

// DeleteUserNPCDef removes a JSON file from npcs_user/. No-op if the
// file does not exist so the editor can issue the call without first
// checking.
func DeleteUserNPCDef(root, id string) error {
	clean := sanitizeNPCID(id)
	if clean == "" {
		return errors.New("invalid id")
	}
	p := filepath.Join(userNPCDir(root), clean+".json")
	if err := os.Remove(p); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	return nil
}

func sanitizeNPCID(id string) string {
	var b strings.Builder
	for _, r := range id {
		if (r >= 'a' && r <= 'z') ||
			(r >= 'A' && r <= 'Z') ||
			(r >= '0' && r <= '9') ||
			r == '_' || r == '-' {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// npcDefToDoc builds the round-trippable document the parser reads.
// Loot and dialog are serialised so a JSON file written by the editor
// reloads back into the same NPCDef.
func npcDefToDoc(def *NPCDef) map[string]interface{} {
	doc := map[string]interface{}{
		"id":      def.ID,
		"name":    def.Name,
		"title":   def.Title,
		"role":    def.Role,
		"faction": def.Faction,
	}
	if def.Sprite != "" {
		doc["sprite"] = def.Sprite
	}
	if def.HP > 0 {
		doc["hp"] = def.HP
	}
	if def.Damage > 0 {
		doc["damage"] = def.Damage
	}
	if def.Speed > 0 {
		doc["speed"] = def.Speed
	}
	if def.Aggro > 0 {
		doc["aggro"] = def.Aggro
	}
	if def.XP > 0 {
		doc["xp"] = def.XP
	}
	if def.Quest != "" {
		doc["quest"] = def.Quest
	}
	if len(def.Loot) > 0 {
		loot := make([]interface{}, 0, len(def.Loot))
		for _, l := range def.Loot {
			loot = append(loot, map[string]interface{}{
				"item":   l.Item,
				"qty":    l.Qty,
				"chance": l.Chance,
			})
		}
		doc["loot"] = loot
	}
	if len(def.Nodes) > 0 {
		dialog := map[string]interface{}{}
		for nid, n := range def.Nodes {
			node := map[string]interface{}{
				"text": n.Text,
			}
			if n.OnEnter.Type != "" {
				node["on_enter"] = hookToDoc(n.OnEnter)
			}
			if len(n.Options) > 0 {
				opts := make([]interface{}, 0, len(n.Options))
				for _, opt := range n.Options {
					om := map[string]interface{}{
						"text":      opt.Text,
						"next_node": opt.Goto,
					}
					if opt.Hook.Type != "" {
						om["hook"] = hookToDoc(opt.Hook)
					}
					opts = append(opts, om)
				}
				node["options"] = opts
			}
			dialog[nid] = node
		}
		doc["dialog"] = dialog
	}
	return doc
}

func hookToDoc(h NPCHook) map[string]interface{} {
	doc := map[string]interface{}{"type": h.Type}
	if h.Quest != "" {
		doc["quest"] = h.Quest
	}
	if h.Stage != "" {
		doc["stage"] = h.Stage
	}
	if h.Item != "" {
		doc["item"] = h.Item
	}
	if h.Qty > 0 {
		doc["qty"] = h.Qty
	}
	if len(h.Reward) > 0 {
		rew := map[string]interface{}{}
		for k, v := range h.Reward {
			rew[k] = v
		}
		doc["reward"] = rew
	}
	return doc
}
