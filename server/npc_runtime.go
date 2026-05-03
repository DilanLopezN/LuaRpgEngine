package main

import (
	"fmt"
	"strconv"
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
//
// Quest-aware routing: when the NPC declares a Quest, the entry node
// is selected from the player's quest state — offer the quest if not
// taken, gate progress if active-but-incomplete, walk into the
// turn-in flow once the objective is satisfied. The NPC author can
// still override any of those nodes by writing them; this only fires
// when the matching node exists.
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
	entry := pickNPCEntryNode(def, p, g.scripts)
	p.NPCDialog = npcID
	p.NPCNode = entry
	// Talk-objective hook fires on every dialog open. Multiple talks
	// to the same NPC re-bump the counter up to its target — the
	// ceiling clamp inside trackTalkForQuests prevents over-counting.
	talkUpdates := g.trackTalkForQuests(p, npcID)
	out := p.Out
	g.mu.Unlock()
	for _, w := range talkUpdates {
		select {
		case out <- w:
		default:
		}
	}
	g.enterDialogNode(p, def, entry)
}

// pickNPCEntryNode chooses which dialog node to enter based on the
// player's progress against any quest this NPC hands out. Two paths
// are honored:
//
//  1. Legacy: NPCDef.Quest names a single bound quest. Drives the
//     original elder-style flow.
//  2. New: any QuestDef whose Giver is this NPC's id participates.
//     The routing prefers a turn-in (return_done) for a satisfied
//     active quest, then "still working" (return_in_progress) for
//     any active-but-not-satisfied quest, and finally "start".
//
// The function is total — it always returns a node that exists in
// def.Nodes, falling back to "start". Caller MUST hold g.mu so
// p.Quests is observed consistently.
func pickNPCEntryNode(def *NPCDef, p *Player, scripts *ScriptEngine) string {
	if def == nil {
		return "start"
	}
	hasNode := func(id string) bool { _, ok := def.Nodes[id]; return ok }
	// Build the set of quest ids relevant to this NPC.
	candidates := map[string]bool{}
	if def.Quest != "" {
		candidates[def.Quest] = true
	}
	if scripts != nil {
		for qid, qd := range scripts.Quests() {
			if qd.Giver == def.ID {
				candidates[qid] = true
			}
		}
	}
	if len(candidates) == 0 {
		return "start"
	}
	var (
		seenSatisfied bool
		seenActive    bool
	)
	for qid := range candidates {
		qs, taken := p.Quests[qid]
		if !taken || qs.Done {
			continue
		}
		if scripts == nil {
			seenActive = true
			continue
		}
		qdef, ok := scripts.Quest(qid)
		if !ok {
			continue
		}
		if questObjectiveSatisfied(qdef, qs, p) {
			seenSatisfied = true
		} else {
			seenActive = true
		}
	}
	if seenSatisfied && hasNode("return_done") {
		return "return_done"
	}
	if seenActive && hasNode("return_in_progress") {
		return "return_in_progress"
	}
	return "start"
}

// questObjectiveSatisfied reports whether the player has met every
// objective on the quest. The check is structural — Progress[i] must
// be at least Objectives[i].Count, plus collect-objective items must
// still be in the inventory at turn-in (to gate against drop-and-claim).
// Splits the predicate from completeQuest so handleTalk's routing
// stays in sync with the actual gate.
func questObjectiveSatisfied(qdef *QuestDef, qs *QuestState, p *Player) bool {
	if qdef == nil || qs == nil {
		return false
	}
	for i, o := range qdef.Objectives {
		need := o.Count
		if need <= 0 {
			need = 1
		}
		switch o.Type {
		case "kill", "talk", "visit":
			if i >= len(qs.Progress) || qs.Progress[i] < need {
				return false
			}
		case "level":
			if p.Stats == nil || p.Stats.Level < need {
				return false
			}
		case "collect":
			if p.Entity == nil || p.Entity.Inventory == nil {
				return false
			}
			have := 0
			for _, it := range p.Entity.Inventory.Items {
				if it.ID == o.Target {
					have += it.Qty
				}
			}
			if have < need {
				return false
			}
		}
	}
	return true
}

// questProgressLine emits the wire frame the client uses to render a
// quest's progress in the journal. Format:
//
//	QUEST_STATE <id> <stage> <killCount> <done> <progress comma list>
//
// `killCount` is kept first for backward compat with older clients;
// `progress` carries the full multi-objective vector. A quest with
// no Progress emits "-" so the client knows to fall back to the
// legacy one-objective rendering.
func questProgressLine(qs *QuestState) string {
	prog := "-"
	if len(qs.Progress) > 0 {
		parts := make([]string, len(qs.Progress))
		for i, v := range qs.Progress {
			parts[i] = strconv.Itoa(v)
		}
		prog = strings.Join(parts, ",")
	}
	return fmt.Sprintf("QUEST_STATE %s %s %d %s %s\n",
		qs.ID, qs.Stage, qs.KillCount, boolToFlag(qs.Done), prog)
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

// startQuest opens a new active QuestState for the player, after
// checking prerequisites. Returns the wire frame to send if anything
// changed; the caller dispatches it. Idempotent for non-repeatable
// quests (re-entering once Done is a no-op); repeatable quests reset
// progress and re-arm.
func (g *Game) startQuest(p *Player, questID string) {
	if g.scripts == nil {
		return
	}
	qdef, ok := g.scripts.Quest(questID)
	if !ok {
		return
	}
	g.mu.Lock()
	// Prereq gate: level / preceding quest. Class is reserved for
	// when the engine grows class identity; today it never blocks.
	if qdef.Prerequisites.Level > 0 &&
		(p.Stats == nil || p.Stats.Level < qdef.Prerequisites.Level) {
		out := p.Out
		g.mu.Unlock()
		sendNow(out, fmt.Sprintf("SYS Você precisa do nível %d para essa quest.\n",
			qdef.Prerequisites.Level))
		return
	}
	if pre := qdef.Prerequisites.Quest; pre != "" {
		s, has := p.Quests[pre]
		if !has || !s.Done {
			out := p.Out
			g.mu.Unlock()
			sendNow(out, fmt.Sprintf("SYS Termine '%s' antes de aceitar essa quest.\n", pre))
			return
		}
	}
	existing, exists := p.Quests[questID]
	if exists {
		if !qdef.Repeatable {
			g.mu.Unlock()
			return
		}
		// Repeatable: clear and re-arm.
		existing.Done = false
		existing.Stage = "active"
		existing.KillCount = 0
		existing.Progress = make([]int, len(qdef.Objectives))
	} else {
		existing = &QuestState{
			ID:       questID,
			Stage:    "active",
			Progress: make([]int, len(qdef.Objectives)),
		}
		p.Quests[questID] = existing
	}
	out := p.Out
	character := p.Name
	wire := questProgressLine(existing)
	intro := qdef.IntroMessage
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveQuest(character, existing)
	}
	if intro != "" {
		sendNow(out, "SYS "+intro+"\n")
	}
	sendNow(out, wire)
	// Fire the optional Lua hook outside g.mu — see roadmap §🔒.
	go g.scripts.FireHook("quest_start", map[string]interface{}{
		"quest":  questID,
		"player": p.ID,
	})
	if qdef.OnStartHook != "" {
		go g.scripts.FireHook(qdef.OnStartHook, map[string]interface{}{
			"quest": questID, "player": p.ID,
		})
	}
}

func (g *Game) advanceQuest(p *Player, questID, stage string) {
	g.mu.Lock()
	qs, ok := p.Quests[questID]
	if !ok {
		g.mu.Unlock()
		return
	}
	qs.Stage = stage
	wire := questProgressLine(qs)
	out := p.Out
	character := p.Name
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveQuest(character, qs)
	}
	sendNow(out, wire)
}

// completeQuest grants the quest reward bundle once every objective is
// satisfied. Collect-objectives consume their items as part of the
// turn-in (gates against drop-and-claim).
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
	if !questObjectiveSatisfied(qdef, qs, p) {
		g.mu.Unlock()
		return
	}
	// Consume any collect-objective items at turn-in.
	for _, o := range qdef.Objectives {
		if o.Type == "collect" && o.Target != "" {
			need := o.Count
			if need <= 0 {
				need = 1
			}
			g.removeItem(p, o.Target, need)
		}
	}
	qs.Stage = "complete"
	qs.Done = true
	reward := qdef.Reward
	completeMsg := qdef.CompleteMessage
	pid := p.ID
	out := p.Out
	character := p.Name
	wire := questProgressLine(qs)
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveQuest(character, qs)
	}
	if reward.XP > 0 {
		g.GiveXP(pid, reward.XP)
	}
	if reward.Gold > 0 {
		g.GiveGold(pid, reward.Gold)
	}
	for _, it := range reward.Items {
		if it.ID != "" && it.Qty > 0 {
			g.GiveItem(pid, it.ID, it.Qty)
		}
	}
	if reward.SkillPoints > 0 {
		g.mu.Lock()
		if pp, ok := g.players[pid]; ok {
			pp.SkillPoints += reward.SkillPoints
			sendNow(pp.Out,
				fmt.Sprintf("SKILL_POINTS %d\n", pp.SkillPoints))
		}
		g.mu.Unlock()
	}
	if reward.LearnSkill != "" {
		g.mu.Lock()
		if pp, ok := g.players[pid]; ok {
			pp.Learned[reward.LearnSkill] = true
			sendNow(pp.Out,
				fmt.Sprintf("SKILL_LEARNED %s\n", reward.LearnSkill))
		}
		g.mu.Unlock()
	}
	if completeMsg != "" {
		sendNow(out, "SYS "+completeMsg+"\n")
	}
	sendNow(out, wire)
	sendNow(out, fmt.Sprintf("QUEST_COMPLETE %s\n", questID))
	// Hooks fire outside any lock (see roadmap §🔒).
	go g.scripts.FireHook("quest_complete", map[string]interface{}{
		"quest":  questID,
		"player": pid,
	})
	if qdef.OnCompleteHook != "" {
		go g.scripts.FireHook(qdef.OnCompleteHook, map[string]interface{}{
			"quest": questID, "player": pid,
		})
	}
}

// trackKillForQuests bumps every active quest's kill objectives that
// match the slain enemy kind. Caller must hold g.mu. Returns the wire
// frames to broadcast after releasing the lock.
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
		changed := false
		ensureProgressLen(qs, len(def.Objectives))
		for i, o := range def.Objectives {
			if o.Type != "kill" || o.Target != kind {
				continue
			}
			need := o.Count
			if need <= 0 {
				need = 1
			}
			if qs.Progress[i] >= need {
				continue
			}
			qs.Progress[i]++
			changed = true
		}
		if !changed {
			continue
		}
		// Mirror first-kill progress into legacy KillCount for DB.
		if i := def.FirstKillObjectiveIdx(); i >= 0 && i < len(qs.Progress) {
			qs.KillCount = qs.Progress[i]
		}
		updates = append(updates, questProgressLine(qs))
	}
	return updates
}

// trackTalkForQuests bumps "talk" objectives when the player opens a
// dialog with the named NPC. Caller must hold g.mu. Returns wire
// frames the caller should dispatch after dropping the lock.
func (g *Game) trackTalkForQuests(p *Player, npcID string) []string {
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
		changed := false
		ensureProgressLen(qs, len(def.Objectives))
		for i, o := range def.Objectives {
			if o.Type != "talk" || o.Target != npcID {
				continue
			}
			need := o.Count
			if need <= 0 {
				need = 1
			}
			if qs.Progress[i] >= need {
				continue
			}
			qs.Progress[i]++
			changed = true
		}
		if changed {
			updates = append(updates, questProgressLine(qs))
		}
	}
	return updates
}

// trackVisitForQuests bumps "visit" objectives when the player steps
// near (X, Y). Range can override the default "exact tile" check.
// Caller must hold g.mu.
func (g *Game) trackVisitForQuests(p *Player, x, y int) []string {
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
		changed := false
		ensureProgressLen(qs, len(def.Objectives))
		for i, o := range def.Objectives {
			if o.Type != "visit" {
				continue
			}
			r := o.Range
			if r < 0 {
				r = 0
			}
			if absInt(x-o.X) > r || absInt(y-o.Y) > r {
				continue
			}
			need := o.Count
			if need <= 0 {
				need = 1
			}
			if qs.Progress[i] >= need {
				continue
			}
			qs.Progress[i]++
			changed = true
		}
		if changed {
			updates = append(updates, questProgressLine(qs))
		}
	}
	return updates
}

// trackLevelForQuests is a snapshot of "did the level objectives just
// flip to satisfied?". Caller must hold g.mu. We do not increment a
// counter — the predicate is checked at completion time directly via
// p.Stats.Level. The wire frame still needs to refresh so the
// journal UI reflects the new state.
func (g *Game) trackLevelForQuests(p *Player) []string {
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
		changed := false
		ensureProgressLen(qs, len(def.Objectives))
		for i, o := range def.Objectives {
			if o.Type != "level" {
				continue
			}
			need := o.Count
			if need <= 0 {
				need = 1
			}
			if p.Stats != nil && p.Stats.Level >= need {
				if qs.Progress[i] != 1 {
					qs.Progress[i] = 1
					changed = true
				}
			}
		}
		if changed {
			updates = append(updates, questProgressLine(qs))
		}
	}
	return updates
}

// ensureProgressLen pads qs.Progress so direct indexing is safe even
// when the def gained new objectives after the save was persisted.
func ensureProgressLen(qs *QuestState, n int) {
	if len(qs.Progress) >= n {
		return
	}
	pad := make([]int, n)
	copy(pad, qs.Progress)
	qs.Progress = pad
}

// npcInRange returns true if there is an NPC entity with name == id
// within talk range of (x, y). Caller must hold g.mu.
//
// Both pure NPCs (KindNPC) and hostile-NPC-promoted enemies (KindEnemy
// whose .Name matches the NPC id) qualify — a guardian must remain
// talkable even while it has HP and an AI tick. Stock enemies
// (KindEnemy whose name is "orc" / "troll" / etc.) are not in the
// NPC registry, so the lookup at handleTalk gates them out before
// this function is called.
func (g *Game) npcInRange(id string, x, y int) bool {
	if g.ecs == nil {
		return false
	}
	found := false
	g.ecs.Each(func(e *Entity) {
		if found || e.Position == nil || e.Name != id {
			return
		}
		if e.Kind != KindNPC && e.Kind != KindEnemy {
			return
		}
		if absInt(e.Position.X-x) <= dialogTalkRange &&
			absInt(e.Position.Y-y) <= dialogTalkRange {
			found = true
		}
	})
	return found
}
