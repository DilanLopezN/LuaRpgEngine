package main

import (
	"fmt"
	"strings"
)

// Phase 4 — NPC dialog runtime.
//
// Talking to an NPC walks the dialog tree authored in
// data/scripts/npcs/<id>.lua. The state machine lives entirely on the
// player (NPCDialog/NPCNode) so a disconnect drops the conversation
// cleanly. Hooks (quest_start / quest_complete / give_item / take_item)
// run server-side here so the rules cannot be cheated by a malicious
// client choosing arbitrary node IDs.

const dialogTalkRange = 4

// handleTalk opens a dialog with the NPC whose id is supplied. The NPC
// must be on the map and within talk range of the player.
func (g *Game) handleTalk(p *Player, npcID string) {
	if g.scripts == nil {
		return
	}
	def, ok := g.scripts.NPC(npcID)
	if !ok {
		return
	}
	g.mu.Lock()
	if p.Name == "" {
		g.mu.Unlock()
		return
	}
	if !g.npcInRange(npcID, p.TileX, p.TileY) {
		g.mu.Unlock()
		return
	}
	p.NPCDialog = npcID
	p.NPCNode = "start"
	g.mu.Unlock()
	g.enterDialogNode(p, def, "start")
}

// handleDialogPick walks one option of the active node. Index is
// 1-based to match the wire format the client emits.
func (g *Game) handleDialogPick(p *Player, idx int) {
	if g.scripts == nil {
		return
	}
	g.mu.Lock()
	npcID := p.NPCDialog
	nodeID := p.NPCNode
	g.mu.Unlock()
	if npcID == "" {
		return
	}
	def, ok := g.scripts.NPC(npcID)
	if !ok {
		g.handleDialogEnd(p)
		return
	}
	node, ok := def.Nodes[nodeID]
	if !ok || idx < 1 || idx > len(node.Options) {
		return
	}
	opt := node.Options[idx-1]
	if opt.Hook.Type != "" {
		g.applyNPCHook(p, opt.Hook)
	}
	if opt.Goto == "" || opt.Goto == "end" {
		g.handleDialogEnd(p)
		return
	}
	g.mu.Lock()
	p.NPCNode = opt.Goto
	g.mu.Unlock()
	g.enterDialogNode(p, def, opt.Goto)
}

func (g *Game) handleDialogEnd(p *Player) {
	g.mu.Lock()
	p.NPCDialog = ""
	p.NPCNode = ""
	out := p.Out
	g.mu.Unlock()
	sendNow(out, "DIALOG_END\n")
}

func (g *Game) enterDialogNode(p *Player, def *NPCDef, nodeID string) {
	node, ok := def.Nodes[nodeID]
	if !ok {
		g.handleDialogEnd(p)
		return
	}
	if node.OnEnter.Type != "" {
		g.applyNPCHook(p, node.OnEnter)
	}
	g.mu.Lock()
	out := p.Out
	g.mu.Unlock()

	text := strings.ReplaceAll(node.Text, "\n", " ")
	sendNow(out, fmt.Sprintf("DIALOG %s %s %s\n",
		def.ID, nodeID, encodeDialogText(text)))
	for i, opt := range node.Options {
		sendNow(out, fmt.Sprintf("DIALOG_OPT %d %s\n",
			i+1, encodeDialogText(opt.Text)))
	}
}

// encodeDialogText replaces spaces with underscores so the wire format
// stays whitespace-tokenisable. The client reverses the substitution.
func encodeDialogText(s string) string {
	if s == "" {
		return "_"
	}
	return strings.ReplaceAll(s, " ", "_")
}

// applyNPCHook runs the structured side-effect attached to a dialog
// option / node. Errors (missing items, unknown quests) are silent —
// the client's UI should already gate the option, the server is the
// last line of defence.
func (g *Game) applyNPCHook(p *Player, h NPCHook) {
	switch h.Type {
	case "quest_start":
		g.startQuest(p, h.Quest)
	case "quest_complete":
		g.completeQuest(p, h.Quest)
	case "quest_advance":
		g.advanceQuest(p, h.Quest, h.Stage)
	case "give_item":
		g.GiveItem(p.ID, h.Item, h.Qty)
	case "take_item":
		g.takeItem(p, h.Item, h.Qty)
	}
}

func (g *Game) takeItem(p *Player, itemID string, qty int) bool {
	if qty <= 0 {
		return false
	}
	g.mu.Lock()
	removed := g.removeItem(p, itemID, qty)
	wire := inventoryWire(p)
	out := p.Out
	character := p.Name
	g.mu.Unlock()
	if removed < qty {
		// Refund partial removals so we never leave the player with a
		// silent "lost half a stack" surface.
		if removed > 0 && g.scripts != nil {
			if def, ok := g.scripts.Item(itemID); ok {
				g.mu.Lock()
				g.addItem(p, def, removed)
				wire = inventoryWire(p)
				g.mu.Unlock()
				sendNow(out, wire)
			}
		}
		return false
	}
	if g.db != nil && character != "" {
		g.db.SaveInventory(character, p)
	}
	sendNow(out, wire)
	return true
}

func (g *Game) startQuest(p *Player, questID string) {
	if g.scripts == nil {
		return
	}
	if _, ok := g.scripts.Quest(questID); !ok {
		return
	}
	g.mu.Lock()
	if _, exists := p.Quests[questID]; exists {
		g.mu.Unlock()
		return
	}
	qs := &QuestState{ID: questID, Stage: "active"}
	p.Quests[questID] = qs
	out := p.Out
	character := p.Name
	wire := fmt.Sprintf("QUEST_STATE %s %s %d %s\n",
		qs.ID, qs.Stage, qs.KillCount, boolToFlag(qs.Done))
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveQuest(character, qs)
	}
	sendNow(out, wire)
}

func (g *Game) advanceQuest(p *Player, questID, stage string) {
	g.mu.Lock()
	qs, ok := p.Quests[questID]
	if !ok {
		g.mu.Unlock()
		return
	}
	qs.Stage = stage
	wire := fmt.Sprintf("QUEST_STATE %s %s %d %s\n",
		qs.ID, qs.Stage, qs.KillCount, boolToFlag(qs.Done))
	out := p.Out
	character := p.Name
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveQuest(character, qs)
	}
	sendNow(out, wire)
}

// completeQuest grants the quest reward (xp/gold/item) once the
// objective threshold is satisfied. Quests that haven't met the kill /
// item objectives are rejected so the dialog branch cannot be used to
// skip combat.
func (g *Game) completeQuest(p *Player, questID string) {
	if g.scripts == nil {
		return
	}
	qdef, ok := g.scripts.Quest(questID)
	if !ok {
		return
	}
	g.mu.Lock()
	qs, ok := p.Quests[questID]
	if !ok || qs.Done {
		g.mu.Unlock()
		return
	}
	if qdef.KillCount > 0 && qs.KillCount < qdef.KillCount {
		g.mu.Unlock()
		return
	}
	if qdef.ItemTarget != "" && qdef.ItemCount > 0 {
		// Verify the player still has the items, then remove them as
		// part of the turn-in.
		have := 0
		if p.Entity != nil && p.Entity.Inventory != nil {
			for _, it := range p.Entity.Inventory.Items {
				if it.ID == qdef.ItemTarget {
					have += it.Qty
				}
			}
		}
		if have < qdef.ItemCount {
			g.mu.Unlock()
			return
		}
		g.removeItem(p, qdef.ItemTarget, qdef.ItemCount)
	}
	qs.Stage = "complete"
	qs.Done = true
	rewardXP := qdef.RewardXP
	rewardGold := qdef.RewardGold
	rewardItem := qdef.RewardItem
	rewardQty := qdef.RewardQty
	pid := p.ID
	out := p.Out
	character := p.Name
	wire := fmt.Sprintf("QUEST_STATE %s %s %d %s\n",
		qs.ID, qs.Stage, qs.KillCount, boolToFlag(qs.Done))
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveQuest(character, qs)
	}
	if rewardXP > 0 {
		g.GiveXP(pid, rewardXP)
	}
	if rewardGold > 0 {
		g.GiveGold(pid, rewardGold)
	}
	if rewardItem != "" && rewardQty > 0 {
		g.GiveItem(pid, rewardItem, rewardQty)
	}
	sendNow(out, wire)
	sendNow(out, fmt.Sprintf("QUEST_COMPLETE %s\n", questID))
}

// trackKillForQuests bumps every active quest whose kill target matches
// the slain enemy. Caller must hold g.mu.
func (g *Game) trackKillForQuests(p *Player, kind string) []string {
	if g.scripts == nil {
		return nil
	}
	var updates []string
	for _, qs := range p.Quests {
		if qs.Done {
			continue
		}
		def, ok := g.scripts.Quest(qs.ID)
		if !ok {
			continue
		}
		if def.KillTarget != kind || def.KillCount <= 0 {
			continue
		}
		if qs.KillCount >= def.KillCount {
			continue
		}
		qs.KillCount++
		updates = append(updates, fmt.Sprintf("QUEST_STATE %s %s %d %s\n",
			qs.ID, qs.Stage, qs.KillCount, boolToFlag(qs.Done)))
	}
	return updates
}

// npcInRange returns true if there is an NPC entity with name == id
// within talk range of (x, y). Caller must hold g.mu.
func (g *Game) npcInRange(id string, x, y int) bool {
	if g.ecs == nil {
		return false
	}
	found := false
	g.ecs.Each(func(e *Entity) {
		if found || e.Kind != KindNPC || e.Position == nil || e.Name != id {
			return
		}
		if absInt(e.Position.X-x) <= dialogTalkRange &&
			absInt(e.Position.Y-y) <= dialogTalkRange {
			found = true
		}
	})
	return found
}
