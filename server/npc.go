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

// QuestDef describes a quest. Loaded from either:
//   - data/scripts/quests/<id>.lua (canonical, designer-authored), or
//   - data/scripts/quests_user/<id>.json (in-game editor authored).
//
// The schema is multi-objective so a single quest can chain a kill
// list with item collection, a map visit, a level milestone, and a
// "talk to NPC" beat. Each objective tracks its own progress; the
// quest only completes when every objective is satisfied.
//
// Backward compatibility: the legacy single-objective shape
// (`objective = { kill = …, count = …, item = …, item_count = … }`,
// `reward = { xp, gold, item, qty }`) is still accepted by the
// parser and folded into the new Objectives / Reward fields so old
// Lua content keeps loading unchanged.
type QuestDef struct {
	ID          string
	Name        string
	Description string

	// Giver is the optional NPC id that hands out the quest. The
	// editor uses it to mark the NPC with a yellow "!" exclamation
	// in the world; runtime uses it to gate where the quest can be
	// accepted (when set).
	Giver string

	// Repeatable lets a player re-take the quest after completing it.
	// One-shot quests (the default) lock once Done is set.
	Repeatable bool

	Prerequisites QuestPrereqs

	Objectives []QuestObjective

	Reward QuestReward

	// Messages shown in the chat / UI at lifecycle events. Each is
	// optional; falls back to a generic system line when blank.
	IntroMessage    string
	ProgressMessage string
	CompleteMessage string

	// Hooks fire FireHook events ("quest_<id>_start" / "_complete")
	// so designers can attach custom Lua glue without touching Go.
	OnStartHook    string
	OnCompleteHook string
}

// QuestPrereqs decide whether a player is allowed to start a quest.
// Empty values disable the corresponding gate.
type QuestPrereqs struct {
	Level int    // minimum character level
	Quest string // id of a quest that must be Done first
	Class string // optional class id (free-form; engine ignores until classes ship)
}

// QuestObjective is one row in the objective list. Type drives which
// fields matter; the rest are zero values to keep the JSON tidy.
//
// Supported types:
//
//	"kill"    → enemy kind == Target, Count enemies slain
//	"collect" → item id == Target, Count items in inventory at turn-in
//	"visit"   → walk onto tile (X, Y) on map MapName (within Range tiles)
//	"level"   → reach character level Count
//	"talk"    → talk to NPC id == Target
type QuestObjective struct {
	Type    string `json:"type"`
	Target  string `json:"target,omitempty"`
	Count   int    `json:"count,omitempty"`
	MapName string `json:"map,omitempty"`
	X       int    `json:"x,omitempty"`
	Y       int    `json:"y,omitempty"`
	Range   int    `json:"range,omitempty"`
	Note    string `json:"note,omitempty"`
}

// QuestReward bundles every kind of payout. Items can be a list so
// the editor can hand out multiple stacks in one turn-in.
type QuestReward struct {
	XP          int       `json:"xp,omitempty"`
	Gold        int       `json:"gold,omitempty"`
	SkillPoints int       `json:"skill_points,omitempty"`
	LearnSkill  string    `json:"learn_skill,omitempty"`
	Items       []ItemRef `json:"items,omitempty"`
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
		ID:              id,
		Name:            asString(m["name"]),
		Description:     asString(m["description"]),
		Giver:           asString(m["giver"]),
		Repeatable:      asBool(m["repeatable"]),
		IntroMessage:    asString(m["intro"]),
		ProgressMessage: asString(m["in_progress"]),
		CompleteMessage: asString(m["complete"]),
		OnStartHook:     asString(m["on_start_hook"]),
		OnCompleteHook:  asString(m["on_complete_hook"]),
	}
	if q.Name == "" {
		q.Name = id
	}
	if pre := asMap(m["prerequisites"]); pre != nil {
		q.Prerequisites = QuestPrereqs{
			Level: asInt(pre["level"]),
			Quest: asString(pre["quest"]),
			Class: asString(pre["class"]),
		}
	}
	// Multi-objective: prefer `objectives = [...]` if present.
	for _, raw := range asSlice(m["objectives"]) {
		om := asMap(raw)
		if om == nil {
			continue
		}
		obj := QuestObjective{
			Type:    asString(om["type"]),
			Target:  asString(om["target"]),
			Count:   asInt(om["count"]),
			MapName: asString(om["map"]),
			X:       asInt(om["x"]),
			Y:       asInt(om["y"]),
			Range:   asInt(om["range"]),
			Note:    asString(om["note"]),
		}
		if obj.Count <= 0 && (obj.Type == "kill" || obj.Type == "collect" || obj.Type == "level" || obj.Type == "talk") {
			obj.Count = 1
		}
		if obj.Type == "" {
			continue
		}
		q.Objectives = append(q.Objectives, obj)
	}
	// Legacy single-objective shape — kept to avoid breaking
	// data/scripts/quests/orc_hunt.lua and similar files.
	if obj := asMap(m["objective"]); obj != nil {
		if kill := asString(obj["kill"]); kill != "" {
			q.Objectives = append(q.Objectives, QuestObjective{
				Type: "kill", Target: kill, Count: asInt(obj["count"]),
			})
		}
		if item := asString(obj["item"]); item != "" {
			q.Objectives = append(q.Objectives, QuestObjective{
				Type: "collect", Target: item, Count: asInt(obj["item_count"]),
			})
		}
	}
	// Multi-reward.
	if rew := asMap(m["reward"]); rew != nil {
		q.Reward.XP = asInt(rew["xp"])
		q.Reward.Gold = asInt(rew["gold"])
		q.Reward.SkillPoints = asInt(rew["skill_points"])
		q.Reward.LearnSkill = asString(rew["learn_skill"])
		// Legacy single-item reward.
		if it := asString(rew["item"]); it != "" {
			qty := asInt(rew["qty"])
			if qty <= 0 {
				qty = 1
			}
			q.Reward.Items = append(q.Reward.Items,
				ItemRef{ID: it, Qty: qty})
		}
		for _, raw := range asSlice(rew["items"]) {
			im := asMap(raw)
			if im == nil {
				continue
			}
			it := asString(im["id"])
			if it == "" {
				continue
			}
			qty := asInt(im["qty"])
			if qty <= 0 {
				qty = 1
			}
			q.Reward.Items = append(q.Reward.Items,
				ItemRef{ID: it, Qty: qty})
		}
	}
	// Default an objective when nothing was authored — the editor
	// flow lets the user save a half-filled draft.
	if len(q.Objectives) == 0 {
		q.Objectives = []QuestObjective{{Type: "talk", Count: 1}}
	}
	return q, nil
}

// QuestState is the per-player progress on a quest. Progress[i] tracks
// objective i's current count (kills made / items collected / level
// reached / talks done / visits done). The legacy KillCount field is
// kept for DB backward compat — it mirrors Progress[firstKill].
type QuestState struct {
	ID        string
	Stage     string // "active" | "complete" | custom
	KillCount int   // legacy; kept in sync with first kill objective
	Progress  []int // per-objective progress
	Done      bool
}

// FirstKillObjectiveIdx returns the index of the first kill objective,
// or -1. Used to keep the DB-level KillCount in sync with the new
// per-objective progress slice without forcing a schema migration.
func (q *QuestDef) FirstKillObjectiveIdx() int {
	for i, o := range q.Objectives {
		if o.Type == "kill" {
			return i
		}
	}
	return -1
}

// FirstCollectObjectiveIdx returns the index of the first collect
// objective, or -1.
func (q *QuestDef) FirstCollectObjectiveIdx() int {
	for i, o := range q.Objectives {
		if o.Type == "collect" {
			return i
		}
	}
	return -1
}

// asBool tolerates lua/json bool, "true"/"false" strings, and
// non-zero numbers (so `repeatable = 1` works).
func asBool(v interface{}) bool {
	switch t := v.(type) {
	case bool:
		return t
	case string:
		return t == "true" || t == "yes" || t == "1"
	case int:
		return t != 0
	case int64:
		return t != 0
	case float64:
		return t != 0
	}
	return false
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

// formatQuestDef serialises the full QuestDef to a JSON wire frame.
// The richer schema (multi-objective + bundle reward + prereqs) does
// not fit the legacy whitespace-separated layout, so the wire moves
// to JSON the same way NPC_DEF did. The client parses it as a Lua
// table and uses it to render the journal / editor catalog.
func formatQuestDef(q *QuestDef) string {
	wire := struct {
		ID              string           `json:"id"`
		Name            string           `json:"name"`
		Description     string           `json:"description,omitempty"`
		Giver           string           `json:"giver,omitempty"`
		Repeatable      bool             `json:"repeatable,omitempty"`
		Prerequisites   QuestPrereqs     `json:"prerequisites,omitempty"`
		Objectives      []QuestObjective `json:"objectives,omitempty"`
		Reward          QuestReward      `json:"reward,omitempty"`
		Intro           string           `json:"intro,omitempty"`
		InProgress      string           `json:"in_progress,omitempty"`
		Complete        string           `json:"complete,omitempty"`
	}{
		ID: q.ID, Name: q.Name, Description: q.Description,
		Giver: q.Giver, Repeatable: q.Repeatable,
		Prerequisites: q.Prerequisites,
		Objectives:    q.Objectives,
		Reward:        q.Reward,
		Intro:         q.IntroMessage,
		InProgress:    q.ProgressMessage,
		Complete:      q.CompleteMessage,
	}
	b, err := json.Marshal(wire)
	if err != nil {
		return fmt.Sprintf("QUEST_DEF {\"id\":\"%s\",\"name\":\"%s\"}\n",
			q.ID, q.Name)
	}
	return "QUEST_DEF " + string(b) + "\n"
}

func emptyDash(s string) string {
	if s == "" {
		return "-"
	}
	return s
}

// --- Quest user authoring (data/scripts/quests_user/) ---------------------

func userQuestDir(root string) string {
	return filepath.Join(root, "quests_user")
}

// LoadUserQuestJSON parses a quest JSON file (editor-authored).
func LoadUserQuestJSON(path string) (*QuestDef, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var raw interface{}
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, fmt.Errorf("parse quest %s: %w", path, err)
	}
	base := strings.TrimSuffix(filepath.Base(path), ".json")
	return parseQuestDef(raw, base)
}

func listUserQuestFiles(root string) ([]string, error) {
	dir := userQuestDir(root)
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

// SaveUserQuestDef serialises the def back to disk. The document is
// the parser's input shape so a round-trip preserves the design.
func SaveUserQuestDef(root string, q *QuestDef) error {
	if q == nil || q.ID == "" {
		return errors.New("quest def: missing id")
	}
	clean := sanitizeNPCID(q.ID) // same sanitiser; alnum + _-
	if clean == "" {
		return errors.New("quest def: invalid id")
	}
	dir := userQuestDir(root)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	doc := questDefToDoc(q)
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

func DeleteUserQuestDef(root, id string) error {
	clean := sanitizeNPCID(id)
	if clean == "" {
		return errors.New("invalid id")
	}
	p := filepath.Join(userQuestDir(root), clean+".json")
	if err := os.Remove(p); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	return nil
}

func questDefToDoc(q *QuestDef) map[string]interface{} {
	doc := map[string]interface{}{
		"id":   q.ID,
		"name": q.Name,
	}
	if q.Description != "" {
		doc["description"] = q.Description
	}
	if q.Giver != "" {
		doc["giver"] = q.Giver
	}
	if q.Repeatable {
		doc["repeatable"] = true
	}
	if q.Prerequisites != (QuestPrereqs{}) {
		pre := map[string]interface{}{}
		if q.Prerequisites.Level > 0 {
			pre["level"] = q.Prerequisites.Level
		}
		if q.Prerequisites.Quest != "" {
			pre["quest"] = q.Prerequisites.Quest
		}
		if q.Prerequisites.Class != "" {
			pre["class"] = q.Prerequisites.Class
		}
		doc["prerequisites"] = pre
	}
	if len(q.Objectives) > 0 {
		objs := make([]interface{}, 0, len(q.Objectives))
		for _, o := range q.Objectives {
			om := map[string]interface{}{"type": o.Type}
			if o.Target != "" {
				om["target"] = o.Target
			}
			if o.Count > 0 {
				om["count"] = o.Count
			}
			if o.MapName != "" {
				om["map"] = o.MapName
			}
			if o.X != 0 {
				om["x"] = o.X
			}
			if o.Y != 0 {
				om["y"] = o.Y
			}
			if o.Range > 0 {
				om["range"] = o.Range
			}
			if o.Note != "" {
				om["note"] = o.Note
			}
			objs = append(objs, om)
		}
		doc["objectives"] = objs
	}
	rew := map[string]interface{}{}
	if q.Reward.XP > 0 {
		rew["xp"] = q.Reward.XP
	}
	if q.Reward.Gold > 0 {
		rew["gold"] = q.Reward.Gold
	}
	if q.Reward.SkillPoints > 0 {
		rew["skill_points"] = q.Reward.SkillPoints
	}
	if q.Reward.LearnSkill != "" {
		rew["learn_skill"] = q.Reward.LearnSkill
	}
	if len(q.Reward.Items) > 0 {
		items := make([]interface{}, 0, len(q.Reward.Items))
		for _, it := range q.Reward.Items {
			items = append(items, map[string]interface{}{
				"id": it.ID, "qty": it.Qty,
			})
		}
		rew["items"] = items
	}
	if len(rew) > 0 {
		doc["reward"] = rew
	}
	if q.IntroMessage != "" {
		doc["intro"] = q.IntroMessage
	}
	if q.ProgressMessage != "" {
		doc["in_progress"] = q.ProgressMessage
	}
	if q.CompleteMessage != "" {
		doc["complete"] = q.CompleteMessage
	}
	if q.OnStartHook != "" {
		doc["on_start_hook"] = q.OnStartHook
	}
	if q.OnCompleteHook != "" {
		doc["on_complete_hook"] = q.OnCompleteHook
	}
	return doc
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
