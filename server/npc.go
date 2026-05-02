package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"strings"
)

// Phase 4 — NPCs and quests.
//
// An NPC is a static entity authored in data/scripts/npcs/<id>.lua.
// Each NPC has a tree of dialogue nodes; the player walks the tree by
// sending TALK <npc> and DIALOG_PICK <option_index>. Nodes can attach
// quest hooks (start, complete, advance) so a single dialogue can drop
// the matar→loot→quest→progredir loop without any Go change.

// NPCDef is the on-disk template for an NPC. Like everything else in
// data/scripts/, the loader catches typos at boot.
//
// JSON tags mirror the Lua keys so the in-game NPC editor can ship a
// def directly via REGNPC and the loader can round-trip it from
// data/scripts/npcs_user/<id>.json.
type NPCDef struct {
	ID    string              `json:"id"`
	Name  string              `json:"name"`
	Title string              `json:"title"`
	Nodes map[string]*NPCNode `json:"dialog"`
}

// NPCNode is a single dialogue beat. Text is what the NPC says;
// Options are the player's responses, each pointing at the next node
// (or "end" to close the dialog). Hooks fire when the player lands on
// the node — they're enough for "give a quest" / "complete a quest" /
// "advance an objective" without scripting more glue.
type NPCNode struct {
	ID      string      `json:"-"`
	Text    string      `json:"text"`
	Options []NPCOption `json:"options,omitempty"`
	OnEnter NPCHook     `json:"on_enter,omitempty"`
}

type NPCOption struct {
	Text string  `json:"text"`
	Goto string  `json:"next_node,omitempty"`
	Hook NPCHook `json:"hook,omitempty"`
}

// NPCHook is the structured side-effect a dialogue beat can perform.
// Type is "quest_start" | "quest_complete" | "quest_advance" |
// "give_item" | "take_item". Quest is the quest id; Item/Qty target
// the inventory ops.
type NPCHook struct {
	Type   string         `json:"type,omitempty"`
	Quest  string         `json:"quest,omitempty"`
	Stage  string         `json:"stage,omitempty"`
	Item   string         `json:"item,omitempty"`
	Qty    int            `json:"qty,omitempty"`
	Reward map[string]int `json:"reward,omitempty"`
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
	title := asString(m["title"])
	nodes := make(map[string]*NPCNode)
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
		nodes[nid] = node
	}
	if _, ok := nodes["start"]; !ok {
		return nil, fmt.Errorf("npc %s: missing 'start' node", id)
	}
	return &NPCDef{ID: id, Name: name, Title: title, Nodes: nodes}, nil
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

// formatNPCDef ships an NPC to the client so chat-style UIs can render
// names without holding the source.
func formatNPCDef(def *NPCDef) string {
	return fmt.Sprintf("NPC_DEF %s %s %s\n",
		def.ID,
		strings.ReplaceAll(def.Name, " ", "_"),
		strings.ReplaceAll(def.Title, " ", "_"))
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

// formatNPCFull ships the entire NPC dialog tree as a single JSON line so
// the in-game NPC editor can hydrate its form. The id travels in plain
// text alongside the JSON so the parser can route the message even before
// touching the blob.
func formatNPCFull(def *NPCDef) string {
	data, err := json.Marshal(def)
	if err != nil {
		return ""
	}
	return fmt.Sprintf("NPC_FULL %s %s\n", def.ID, string(data))
}

// validateNPCID enforces the same character set the script loader uses
// for filenames, so a hostile client cannot craft an id that escapes the
// npcs_user directory or shadows a hand-authored .lua.
func validateNPCID(id string) error {
	if id == "" {
		return errors.New("npc id required")
	}
	if len(id) > 40 {
		return errors.New("npc id too long")
	}
	for _, r := range id {
		switch {
		case r >= 'a' && r <= 'z',
			r >= 'A' && r <= 'Z',
			r >= '0' && r <= '9',
			r == '_', r == '-':
			// ok
		default:
			return fmt.Errorf("npc id %q has invalid character %q", id, r)
		}
	}
	return nil
}

// validateNPCDef enforces the structural invariants the runtime relies on:
// every NPC must have a "start" node, hooks must use a known type, and
// option targets must point at an existing node or "end".
func validateNPCDef(def *NPCDef) error {
	if def == nil {
		return errors.New("nil npc")
	}
	if err := validateNPCID(def.ID); err != nil {
		return err
	}
	if len(def.Nodes) == 0 {
		return errors.New("npc has no dialog nodes")
	}
	if _, ok := def.Nodes["start"]; !ok {
		return errors.New("npc missing 'start' node")
	}
	for nid, n := range def.Nodes {
		if n == nil {
			return fmt.Errorf("node %q is nil", nid)
		}
		n.ID = nid
		if len(n.Text) > 4096 {
			return fmt.Errorf("node %q text too long", nid)
		}
		if err := validateHook(n.OnEnter); err != nil {
			return fmt.Errorf("node %q on_enter: %w", nid, err)
		}
		for i, opt := range n.Options {
			if len(opt.Text) > 256 {
				return fmt.Errorf("node %q option %d text too long", nid, i+1)
			}
			if opt.Goto != "" && opt.Goto != "end" {
				if _, ok := def.Nodes[opt.Goto]; !ok {
					return fmt.Errorf("node %q option %d points to unknown node %q",
						nid, i+1, opt.Goto)
				}
			}
			if err := validateHook(opt.Hook); err != nil {
				return fmt.Errorf("node %q option %d hook: %w", nid, i+1, err)
			}
		}
	}
	return nil
}

// validateHook accepts the empty hook (Type == "") and the four runtime
// types that applyNPCHook knows how to dispatch.
func validateHook(h NPCHook) error {
	switch h.Type {
	case "", "quest_start", "quest_complete", "quest_advance",
		"give_item", "take_item":
		return nil
	}
	return fmt.Errorf("unknown hook type %q", h.Type)
}
