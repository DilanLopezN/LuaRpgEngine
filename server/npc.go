package main

import (
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
type NPCDef struct {
	ID    string
	Name  string
	Title string
	Nodes map[string]*NPCNode
}

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
