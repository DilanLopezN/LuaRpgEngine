package main

import (
	"fmt"
	"log"
	"math"
	"sort"
	"strings"
	"time"
)

// Skill cast pipeline, skill-tree learn flow, status-effect ticking,
// hot reload, and the ScriptHost surface live here so game.go stays
// focused on the existing tick/move/attack flow.

// --- ScriptHost implementation --------------------------------------------

// BroadcastSystem sends a SYS message to every connected, named player.
func (g *Game) BroadcastSystem(msg string) {
	if msg == "" {
		return
	}
	clean := strings.ReplaceAll(msg, "\n", " ")
	wire := fmt.Sprintf("SYS %s\n", clean)
	g.mu.Lock()
	outs := make([]chan<- string, 0, len(g.players))
	for _, p := range g.players {
		if p.Name == "" {
			continue
		}
		outs = append(outs, p.Out)
	}
	g.mu.Unlock()
	g.broadcast(outs, wire)
}

// SpawnEnemy is the host-side primitive used by hooks/scripts to drop
// an enemy onto the map. It enforces walkability and bounds; an
// invalid request returns 0 instead of panicking the script.
func (g *Game) SpawnEnemy(kind string, x, y int) int {
	g.mu.Lock()
	defer g.mu.Unlock()
	if !g.world.InBounds(x, y) || !g.world.IsWalkable(x, y) {
		return 0
	}
	if g.tileOccupied(x, y, 0) {
		return 0
	}
	e := g.spawnEnemy(kind, x, y)
	return e.ID
}

// DamageEntity applies raw damage to whichever entity (player or
// enemy) shares the supplied ID. Returns true when something was hit.
func (g *Game) DamageEntity(id, amount int) bool {
	if amount <= 0 {
		return false
	}
	var (
		killedEnemy *Enemy
		hitEnemyID  int
		hitPlayerID int
		killedID    int
	)
	g.mu.Lock()
	if e, ok := g.enemies[id]; ok {
		e.HP -= amount
		hitEnemyID = e.ID
		if e.HP <= 0 {
			killedEnemy = e
			delete(g.enemies, e.ID)
		}
	} else if p, ok := g.players[id]; ok && p.HP > 0 {
		p.HP -= amount
		hitPlayerID = p.ID
		if p.HP <= 0 {
			g.respawnPlayer(p)
			killedID = p.ID
		}
	} else {
		g.mu.Unlock()
		return false
	}
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()

	if hitEnemyID != 0 {
		g.broadcast(outs, fmt.Sprintf("HIT %d\n", hitEnemyID))
	}
	if hitPlayerID != 0 {
		g.broadcast(outs, fmt.Sprintf("PHIT %d\n", hitPlayerID))
	}
	if killedID != 0 {
		g.broadcast(outs, fmt.Sprintf("PDIE %d\n", killedID))
	}
	if killedEnemy != nil {
		g.broadcast(outs, fmt.Sprintf("EDIE %d\n", killedEnemy.ID))
	}
	return true
}

// FindEntitiesInRange returns IDs of every enemy and named player
// within Chebyshev distance `radius` of (x, y). The simple metric
// matches how the editor renders area effects, so designers can
// reason about ranges without reading code.
func (g *Game) FindEntitiesInRange(x, y, radius int) []int {
	if radius < 0 {
		radius = 0
	}
	g.mu.Lock()
	defer g.mu.Unlock()
	out := make([]int, 0)
	for _, e := range g.enemies {
		if absInt(e.X-x) <= radius && absInt(e.Y-y) <= radius {
			out = append(out, e.ID)
		}
	}
	for _, p := range g.players {
		if p.Name == "" || p.HP <= 0 {
			continue
		}
		if absInt(p.TileX-x) <= radius && absInt(p.TileY-y) <= radius {
			out = append(out, p.ID)
		}
	}
	sort.Ints(out)
	return out
}

// GetPlayerInfo returns (id, x, y, hp, true) for a named player. The
// fifth return is false if the name is unknown — Lua hooks rely on
// the `if info then ... end` idiom so a missing player must surface
// as nil, not zeros.
func (g *Game) GetPlayerInfo(name string) (int, int, int, int, bool) {
	g.mu.Lock()
	defer g.mu.Unlock()
	for _, p := range g.players {
		if p.Name == name {
			return p.ID, p.TileX, p.TileY, p.HP, true
		}
	}
	return 0, 0, 0, 0, false
}

// ApplyStatus attaches a timed status to player or enemy `targetID`.
// Re-applying the same status refreshes its expiry and overwrites
// power so the caller doesn't have to clean up first.
func (g *Game) ApplyStatus(targetID int, status string, durationMs, power int) {
	if status == "" || durationMs <= 0 {
		return
	}
	if durationMs > int(statusMaxDuration/time.Millisecond) {
		durationMs = int(statusMaxDuration / time.Millisecond)
	}
	now := time.Now()
	st := Status{
		Name:      status,
		Power:     power,
		ExpiresAt: now.Add(time.Duration(durationMs) * time.Millisecond),
		NextTick:  now.Add(statusTickEvery),
		Interval:  statusTickEvery,
	}
	g.mu.Lock()
	defer g.mu.Unlock()
	if e, ok := g.enemies[targetID]; ok {
		e.Statuses = upsertStatus(e.Statuses, st)
		return
	}
	if p, ok := g.players[targetID]; ok {
		p.Statuses = upsertStatus(p.Statuses, st)
	}
}

func upsertStatus(list []Status, st Status) []Status {
	for i := range list {
		if list[i].Name == st.Name {
			list[i] = st
			return list
		}
	}
	return append(list, st)
}

// ScheduleEvent is a placeholder for the timer wheel that Phase 4
// will need. We log so designers can see their hook fired without
// blocking on the real implementation.
func (g *Game) ScheduleEvent(name string, delayMs int, payload string) {
	log.Printf("scripts: schedule_event %s in %dms (payload=%q)",
		name, delayMs, payload)
}

// DropItem is the ScriptHost surface for loot. It defers to rollDrop.
func (g *Game) DropItem(killerID int, itemID string, qty, chance int) bool {
	return g.rollDrop(killerID, itemID, qty, chance)
}

// GiveItem grants qty of itemID to a player by ID. Returns the actual
// quantity added (capped by inventory capacity). Safe to call from
// anywhere — acquires g.mu internally.
func (g *Game) GiveItem(playerID int, itemID string, qty int) int {
	if g.scripts == nil {
		return 0
	}
	def, ok := g.scripts.Item(itemID)
	if !ok {
		return 0
	}
	g.mu.Lock()
	p, ok := g.players[playerID]
	if !ok || p.Name == "" {
		g.mu.Unlock()
		return 0
	}
	added := g.addItem(p, def, qty)
	wire := inventoryWire(p)
	out := p.Out
	character := p.Name
	g.mu.Unlock()
	if added <= 0 {
		return 0
	}
	if g.db != nil {
		g.db.SaveInventory(character, p)
	}
	sendNow(out, wire)
	sendNow(out, fmt.Sprintf("LOOT %s %d\n", itemID, added))
	return added
}

// GiveXP awards XP and rolls level-ups. Returns the number of levels
// gained, so Lua callers can branch on the result.
func (g *Game) GiveXP(playerID, amount int) int {
	if amount <= 0 {
		return 0
	}
	g.mu.Lock()
	p, ok := g.players[playerID]
	if !ok || p.Name == "" {
		g.mu.Unlock()
		return 0
	}
	gained := g.awardXP(p, amount)
	wire := characterStatsLocked(p)
	out := p.Out
	character := p.Name
	hp, maxHp, mp, maxMp, kills, x, y := p.HP, p.MaxHP, p.MP, p.MaxMP, p.Kills, p.TileX, p.TileY
	st := *p.Stats
	gold := p.Gold
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.Save(character, hp, maxHp, mp, maxMp, kills, x, y)
		g.db.SaveProgression(character, st.Level, st.XP, st.Str, st.Dex, st.Int, st.Vit, gold)
	}
	sendNow(out, wire)
	sendNow(out, fmt.Sprintf("XP_GAIN %d\n", amount))
	if gained > 0 {
		sendNow(out, fmt.Sprintf("LEVELUP %d\n", gained))
	}
	return gained
}

// GiveGold credits gold and pushes a fresh STATS frame.
func (g *Game) GiveGold(playerID, amount int) int {
	if amount == 0 {
		return 0
	}
	g.mu.Lock()
	p, ok := g.players[playerID]
	if !ok || p.Name == "" {
		g.mu.Unlock()
		return 0
	}
	p.Gold += amount
	if p.Gold < 0 {
		p.Gold = 0
	}
	gold := p.Gold
	wire := characterStatsLocked(p)
	out := p.Out
	character := p.Name
	st := *p.Stats
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveProgression(character, st.Level, st.XP, st.Str, st.Dex, st.Int, st.Vit, gold)
	}
	sendNow(out, wire)
	return amount
}

// --- skill casting ---------------------------------------------------------

// handleCastSkill resolves a global, data-driven skill cast. Validation
// order matches handleCast (the per-player Spell pipeline) so the two
// systems behave identically from the player's perspective.
func (g *Game) handleCastSkill(p *Player, skillID string) {
	if g.scripts == nil {
		return
	}
	sk, ok := g.scripts.Skill(skillID)
	if !ok {
		return
	}

	now := time.Now()
	g.mu.Lock()
	if p.Name == "" || p.HP <= 0 {
		g.mu.Unlock()
		return
	}
	if !p.Learned[skillID] {
		g.mu.Unlock()
		return
	}
	if cd, has := p.SkillCDs[skillID]; has && now.Before(cd) {
		g.mu.Unlock()
		return
	}
	if p.MP < sk.ManaCost {
		g.mu.Unlock()
		return
	}
	p.MP -= sk.ManaCost
	if p.SkillCDs == nil {
		p.SkillCDs = make(map[string]time.Time)
	}
	p.SkillCDs[skillID] = now.Add(sk.Cooldown)

	fx, fy := p.FaceX, p.FaceY
	if fx == 0 && fy == 0 {
		fy = 1
	}
	ox, oy := p.TileX, p.TileY

	targets := g.collectTargets(p, sk, fx, fy, ox, oy)

	hits, pHits, killed, pKilled := g.applyEffects(p, sk, targets)

	for _, e := range killed {
		delete(g.enemies, e.ID)
		p.Kills++
	}

	wire := fmt.Sprintf("SKILL %d %s %d %d %d %d\n",
		p.ID, skillID, fx, fy, ox, oy)
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	playerName := p.Name
	pid := p.ID
	g.mu.Unlock()

	g.broadcast(outs, wire)
	for _, id := range hits {
		g.broadcast(outs, fmt.Sprintf("HIT %d\n", id))
	}
	for _, id := range pHits {
		g.broadcast(outs, fmt.Sprintf("PHIT %d\n", id))
	}
	for _, id := range pKilled {
		g.broadcast(outs, fmt.Sprintf("PDIE %d\n", id))
	}
	for _, e := range killed {
		g.broadcast(outs, fmt.Sprintf("EDIE %d\n", e.ID))
		if g.cache != nil {
			g.cache.RecordKill(playerName)
		}
	}
	g.creditKills(pid, combatOutcome{enemyKilled: killed})
}

// skillTarget bundles a candidate together with whether it is the
// caster — heal/buff effects skip the caster vs not depending on the
// effect, so the dispatcher needs to know.
type skillTarget struct {
	enemy    *Enemy
	player   *Player
	isCaster bool
}

// collectTargets gathers everyone in range/radius of the skill, given
// the caster's facing and tile. The caller must hold g.mu.
func (g *Game) collectTargets(caster *Player, sk *Skill, fx, fy, ox, oy int) []skillTarget {
	var out []skillTarget
	add := func(t skillTarget) { out = append(out, t) }

	switch sk.Type {
	case "melee", "projectile":
		rng := sk.Range
		if sk.Type == "melee" && rng <= 0 {
			rng = 1
		}
		for step := 1; step <= rng; step++ {
			tx := ox + fx*step
			ty := oy + fy*step
			for _, e := range g.enemies {
				if e.X == tx && e.Y == ty {
					add(skillTarget{enemy: e})
				}
			}
			for _, op := range g.players {
				if op.Name == "" || op.HP <= 0 || op.ID == caster.ID {
					continue
				}
				if op.TileX == tx && op.TileY == ty {
					add(skillTarget{player: op})
				}
			}
		}
	case "area":
		cx := ox + fx
		cy := oy + fy
		for _, e := range g.enemies {
			if absInt(e.X-cx) <= sk.Radius && absInt(e.Y-cy) <= sk.Radius {
				add(skillTarget{enemy: e})
			}
		}
		for _, op := range g.players {
			if op.Name == "" || op.HP <= 0 {
				continue
			}
			if absInt(op.TileX-cx) <= sk.Radius && absInt(op.TileY-cy) <= sk.Radius {
				add(skillTarget{player: op, isCaster: op.ID == caster.ID})
			}
		}
	case "heal", "buff":
		add(skillTarget{player: caster, isCaster: true})
	case "debuff":
		// Single-target debuff lands on the closest non-caster within
		// `range` along facing. Mirrors how a 1-radius area would feel
		// without the friendly-fire surface.
		rng := sk.Range
		if rng <= 0 {
			rng = 1
		}
		for step := 1; step <= rng; step++ {
			tx := ox + fx*step
			ty := oy + fy*step
			for _, e := range g.enemies {
				if e.X == tx && e.Y == ty {
					add(skillTarget{enemy: e})
				}
			}
		}
	}
	return out
}

// applyEffects walks the effects DSL once per target. The split into
// (caster vs non-caster) is so heal-on-self skills don't trip the
// "no friendly fire" guard inside damage. Caller must hold g.mu.
func (g *Game) applyEffects(caster *Player, sk *Skill, targets []skillTarget) (hits, pHits []int, killed []*Enemy, pKilled []int) {
	for _, t := range targets {
		for _, eff := range sk.Effects {
			value := eff.Value
			if value == 0 && eff.Type == "damage" {
				// Convenience: if effects is empty/value-less, fall
				// back to the top-level Damage stat.
				value = sk.Damage
			}
			if eff.Scale > 0 && eff.Value > 0 {
				value = int(float64(eff.Value) * eff.Scale)
			}
			if eff.Type == "damage" || eff.Type == "heal" {
				value = applyStatScaling(value, sk.Scaling, caster.Stats)
			}
			switch eff.Type {
			case "damage":
				if t.player != nil && t.isCaster {
					continue
				}
				if t.enemy != nil {
					t.enemy.HP -= value
					hits = append(hits, t.enemy.ID)
					if t.enemy.HP <= 0 {
						killed = append(killed, t.enemy)
					}
				} else if t.player != nil {
					t.player.HP -= value
					pHits = append(pHits, t.player.ID)
					if t.player.HP <= 0 {
						g.respawnPlayer(t.player)
						pKilled = append(pKilled, t.player.ID)
					}
				}
			case "heal":
				if t.player == nil {
					continue
				}
				t.player.HP += value
				if t.player.HP > t.player.MaxHP {
					t.player.HP = t.player.MaxHP
				}
			case "mana":
				if t.player == nil {
					continue
				}
				t.player.MP += value
				if t.player.MP > t.player.MaxMP {
					t.player.MP = t.player.MaxMP
				}
			case "apply_status":
				duration := eff.Duration
				if duration <= 0 {
					continue
				}
				power := eff.Power
				if power == 0 {
					power = value
				}
				now := time.Now()
				st := Status{
					Name:      eff.Status,
					Power:     power,
					ExpiresAt: now.Add(time.Duration(duration) * time.Millisecond),
					NextTick:  now.Add(statusTickEvery),
					Interval:  statusTickEvery,
					Source:    caster.ID,
				}
				if t.enemy != nil {
					t.enemy.Statuses = upsertStatus(t.enemy.Statuses, st)
				} else if t.player != nil {
					t.player.Statuses = upsertStatus(t.player.Statuses, st)
				}
			}
		}
	}
	_ = caster
	_ = math.Pi // keep import stable if future effects need geometry
	return
}

// tickStatuses advances every entity's active statuses, applies tick
// damage, and prunes expired entries. Caller must hold g.mu.
func (g *Game) tickStatuses(now time.Time) (deadEnemies []*Enemy, deadPlayers []int) {
	tickEnemy := func(e *Enemy) {
		if len(e.Statuses) == 0 {
			return
		}
		next := e.Statuses[:0]
		for _, st := range e.Statuses {
			if now.After(st.ExpiresAt) {
				continue
			}
			if !st.NextTick.IsZero() && !now.Before(st.NextTick) {
				if st.Name == "burn" || st.Name == "poison" {
					e.HP -= st.Power
				}
				st.NextTick = now.Add(st.Interval)
			}
			next = append(next, st)
		}
		e.Statuses = next
		if e.HP <= 0 {
			deadEnemies = append(deadEnemies, e)
		}
	}
	for _, e := range g.enemies {
		tickEnemy(e)
	}

	for _, p := range g.players {
		if len(p.Statuses) == 0 || p.HP <= 0 {
			continue
		}
		next := p.Statuses[:0]
		for _, st := range p.Statuses {
			if now.After(st.ExpiresAt) {
				continue
			}
			if !st.NextTick.IsZero() && !now.Before(st.NextTick) {
				if st.Name == "burn" || st.Name == "poison" {
					p.HP -= st.Power
				}
				st.NextTick = now.Add(st.Interval)
			}
			next = append(next, st)
		}
		p.Statuses = next
		if p.HP <= 0 {
			g.respawnPlayer(p)
			p.Statuses = nil
			deadPlayers = append(deadPlayers, p.ID)
		}
	}

	for _, e := range deadEnemies {
		delete(g.enemies, e.ID)
	}
	return
}

// --- skill tree (learn / reset) -------------------------------------------

// handleLearn validates prerequisites + skill-point cost and unlocks
// the skill. Failures are silent — the client should already know
// from SKILL_POINTS / SKILL_LEARNED whether the request is viable.
func (g *Game) handleLearn(p *Player, skillID string) {
	if g.scripts == nil {
		return
	}
	if _, ok := g.scripts.Skill(skillID); !ok {
		return
	}
	tree := g.scripts.Tree()
	node, hasNode := tree[skillID]

	g.mu.Lock()
	if p.Name == "" {
		g.mu.Unlock()
		return
	}
	if p.Learned[skillID] {
		g.mu.Unlock()
		return
	}
	cost := 1
	if hasNode {
		cost = node.Cost
		for _, req := range node.Requires {
			if !p.Learned[req] {
				g.mu.Unlock()
				return
			}
		}
	}
	if p.SkillPoints < cost {
		g.mu.Unlock()
		return
	}
	p.SkillPoints -= cost
	p.Learned[skillID] = true
	name := p.Name
	pts := p.SkillPoints
	out := p.Out
	g.mu.Unlock()

	if g.db != nil {
		g.db.LearnSkill(name, skillID)
		g.db.SaveSkillPoints(name, pts)
	}
	send := func(msg string) {
		select {
		case out <- msg:
		default:
		}
	}
	send(fmt.Sprintf("SKILL_LEARNED %s\n", skillID))
	send(fmt.Sprintf("SKILL_POINTS %d\n", pts))
}

// handleResetTree wipes the player's tree and refunds every spent
// point. Reserved for admin/dev usage; we don't gate it yet (single-
// player engine), but this is the choke point if access control is
// added later.
func (g *Game) handleResetTree(p *Player) {
	g.mu.Lock()
	if p.Name == "" {
		g.mu.Unlock()
		return
	}
	tree := map[string]*SkillTreeNode{}
	if g.scripts != nil {
		tree = g.scripts.Tree()
	}
	refund := 0
	for id := range p.Learned {
		if node, ok := tree[id]; ok {
			refund += node.Cost
		} else {
			refund += 1
		}
	}
	p.SkillPoints += refund
	p.Learned = make(map[string]bool)
	p.SkillCDs = make(map[string]time.Time)
	name := p.Name
	pts := p.SkillPoints
	out := p.Out
	g.mu.Unlock()

	if g.db != nil {
		g.db.ResetLearnedSkills(name)
		g.db.SaveSkillPoints(name, pts)
	}
	send := func(msg string) {
		select {
		case out <- msg:
		default:
		}
	}
	send(fmt.Sprintf("SKILL_RESET %d\n", pts))
}

// --- hot reload ------------------------------------------------------------

// handleReload triggers a script reload and pushes fresh SKILL_DEF
// snapshots to every named player so client UI stays in sync. The
// command is intentionally available to any connected player while
// the engine is single-developer; gate this on an admin role once
// multi-user access is added.
func (g *Game) handleReload(_ *Player, domain string) {
	if g.scripts == nil {
		return
	}
	if err := g.scripts.LoadDomain(domain); err != nil {
		log.Printf("reload: %v", err)
		return
	}
	defs := g.scripts.Skills()
	g.mu.Lock()
	outs := make([]chan<- string, 0, len(g.players))
	for _, p := range g.players {
		if p.Name == "" {
			continue
		}
		outs = append(outs, p.Out)
	}
	g.mu.Unlock()

	wire := strings.Builder{}
	wire.WriteString(fmt.Sprintf("RELOADED %s\n", domain))
	for _, sk := range defs {
		wire.WriteString(formatSkillDef(sk))
	}
	g.broadcast(outs, wire.String())
}
