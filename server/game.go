package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	tickRate          = 30
	stepDuration      = 250 * time.Millisecond
	diagFactor        = 1.41421356
	attackDur         = 350 * time.Millisecond
	attackCD          = 600 * time.Millisecond
	attackRange       = 1.5
	attackDamage      = 10
	manaRegenInterval = 200 * time.Millisecond
	manaRegenAmount   = 1
	maxManaDefault    = 100

	spellMaxRange    = 30
	spellMaxRadius   = 10
	spellMaxPower    = 10000
	spellMaxManaCost = 10000
	spellMinCooldown = 50 * time.Millisecond
	spellMaxCooldown = 60 * time.Second
)

// Spell is a player-defined ability. Each player's set of spells lives on
// their Player struct, hydrated from Postgres on bindName and updated as the
// editor sends REGSPELL/DELSPELL. Visual fields (R/G/B, Name) are echoed back
// in SPELL_DEF / SPELL broadcasts so the client can render and label them.
type Spell struct {
	ID       string
	Name     string
	Kind     string // "line" | "area" | "self"
	Effect   string // "damage" | "heal" | "mana"
	Range    int
	Radius   int
	Power    int
	ManaCost int
	Cooldown time.Duration
	R, G, B  int
}

func (s *Spell) toRecord() SpellRecord {
	return SpellRecord{
		ID:         s.ID,
		Name:       s.Name,
		Kind:       s.Kind,
		Effect:     s.Effect,
		Range:      s.Range,
		Radius:     s.Radius,
		Power:      s.Power,
		ManaCost:   s.ManaCost,
		CooldownMs: int(s.Cooldown / time.Millisecond),
		R:          s.R,
		G:          s.G,
		B:          s.B,
	}
}

func spellFromRecord(r SpellRecord) *Spell {
	return &Spell{
		ID:       r.ID,
		Name:     r.Name,
		Kind:     r.Kind,
		Effect:   r.Effect,
		Range:    r.Range,
		Radius:   r.Radius,
		Power:    r.Power,
		ManaCost: r.ManaCost,
		Cooldown: time.Duration(r.CooldownMs) * time.Millisecond,
		R:        r.R,
		G:        r.G,
		B:        r.B,
	}
}

func formatSpellDef(s *Spell) string {
	name := s.Name
	if name == "" {
		name = s.ID
	}
	return fmt.Sprintf("SPELL_DEF %s %s %s %d %d %d %d %d %d %d %d %s\n",
		s.ID, s.Kind, s.Effect,
		s.Range, s.Radius, s.Power, s.ManaCost,
		int(s.Cooldown/time.Millisecond),
		s.R, s.G, s.B,
		name)
}

type Player struct {
	ID   int
	Name string

	TileX, TileY int
	FromX, FromY int
	Stepping     bool
	StepStart    time.Time
	StepDur      time.Duration

	DirX, DirY int

	FaceX, FaceY int

	HP, MaxHP int
	MP, MaxMP int
	Kills     int

	AttackUntil time.Time
	NextAttack  time.Time

	LastManaTick time.Time
	SpellCDs     map[string]time.Time
	Spells       map[string]*Spell

	// Phase 2.5 — global, data-driven skills learned via the skill tree.
	// Cooldowns are tracked separately from per-player Spells so the two
	// systems do not interfere.
	Learned     map[string]bool
	SkillPoints int
	SkillCDs    map[string]time.Time

	Statuses []Status

	// Phase 4 — character sheet / inventory / quest tracking. Pointers
	// stay non-nil after addPlayer, so the per-tick code never has to
	// nil-check.
	Stats     *CStats
	Gold      int
	Equipped  EquippedSet
	Quests    map[string]*QuestState
	NPCDialog string // active npc id; empty when no dialog is open
	NPCNode   string // current dialog node within that npc

	NextShout time.Time

	Out chan<- string

	// Phase 3 — ECS mirror. Components live on the entity; the
	// gameplay loop still mutates the Player fields above and a
	// per-tick sync copies the state across.
	Entity *Entity
}

func (p *Player) interpolated(now time.Time) (float64, float64) {
	if !p.Stepping {
		return float64(p.TileX), float64(p.TileY)
	}
	t := float64(now.Sub(p.StepStart)) / float64(p.StepDur)
	if t >= 1 {
		t = 1
	}
	x := float64(p.FromX) + (float64(p.TileX)-float64(p.FromX))*t
	y := float64(p.FromY) + (float64(p.TileY)-float64(p.FromY))*t
	return x, y
}

type Enemy struct {
	ID        int
	Kind      string
	X, Y      int
	HP, MaxHP int
	Statuses  []Status

	// Phase 3 — AI throttling lives next to gameplay state so the
	// AISystem callbacks can refer to it without a separate registry.
	LastStep   time.Time
	LastAttack time.Time

	// Phase 3 — see Player.Entity.
	Entity *Entity
}

type Game struct {
	mu          sync.Mutex
	players     map[int]*Player
	enemies     map[int]*Enemy
	nextID      int
	nextEnemyID int
	db          *DB
	cache       *Cache
	world       *Map
	scripts     *ScriptEngine
	progression *ProgressionDef

	// Phase 3 — ECS world. Player and Enemy keep their gameplay
	// fields (the legacy tick still drives them), but each one also
	// owns a mirror Entity here so new systems and the upcoming
	// ECS_SNAP wire format have a single registry to query.
	ecs      *ECSWorld
	pipeline *SystemPipeline
	tickN    int64

	// snapBuf is reused across ticks to avoid allocating a fresh
	// strings.Builder backing slice every 33ms. Mutated only under
	// g.mu inside buildSnapshotLocked.
	snapBuf strings.Builder

	// aiOutbox queues wire frames produced by the AISystem callbacks
	// while g.mu is held; the host flushes it after releasing the
	// lock. Owned by Game.tick — never read/written outside that path.
	aiOutbox []string
}

func NewGame(db *DB, cache *Cache) *Game {
	g := &Game{
		players: make(map[int]*Player),
		enemies: make(map[int]*Enemy),
		db:      db,
		cache:   cache,
		ecs:     NewECSWorld(),
	}
	g.pipeline = g.buildPipeline()
	m, err := LoadMap(defaultMapName)
	if err != nil {
		log.Printf("map load failed (%v); starting from blank map", err)
		m = DefaultMap(defaultMapName)
	} else {
		log.Printf("loaded map %q (%dx%d, %d entities)",
			m.Name, m.Width, m.Height, len(m.Entities))
	}
	g.world = m

	g.scripts = NewScriptEngine(scriptsRoot())
	g.scripts.SetHost(g)
	g.scripts.LoadAll()
	globalScripts = g.scripts
	g.progression = g.scripts.Progression()

	g.spawnEnemy("orc", 1, 1)
	g.spawnEnemy("orc", 6, 6)
	g.spawnNPCsFromMap()
	return g
}

// spawnNPCsFromMap walks the active map's entities and turns every
// type=npc record into a live NPC entity in the ECS world. Caller does
// not need to hold g.mu — NewGame is single-threaded.
func (g *Game) spawnNPCsFromMap() {
	if g.world == nil {
		return
	}
	for _, ent := range g.world.Entities {
		if ent.Type != "npc" {
			continue
		}
		g.spawnNPC(ent.Kind, ent.X, ent.Y)
	}
}

// spawnNPC adds an NPC entity to the ECS world. NPCs do not move and
// have no Health component — talking to them ignores HP.
func (g *Game) spawnNPC(kind string, x, y int) *Entity {
	if g.ecs == nil {
		return nil
	}
	return g.ecs.Add(&Entity{
		Kind: KindNPC,
		Name: kind,
		Position: &CPosition{
			X: x, Y: y, FromX: x, FromY: y,
		},
		AI: &CAI{Kind: kind, State: "npc"},
	})
}

// scriptsRoot returns the directory tree for data-driven content. The
// override is useful in tests; production sticks with data/scripts.
func scriptsRoot() string {
	if d := os.Getenv("SCRIPTS_DIR"); d != "" {
		return d
	}
	return filepath.Join("data", "scripts")
}

// mapWidth/mapHeight return the active map dimensions. Caller must hold g.mu
// when consistency with concurrent SAVE_MAP handlers matters.
func (g *Game) mapWidth() int  { return g.world.Width }
func (g *Game) mapHeight() int { return g.world.Height }

// tileOccupied reports whether tile (x, y) is currently held by another named
// player or any enemy. The caller must hold g.mu.
func (g *Game) tileOccupied(x, y, excludeID int) bool {
	for _, p := range g.players {
		if p.ID == excludeID || p.Name == "" || p.HP <= 0 {
			continue
		}
		if p.TileX == x && p.TileY == y {
			return true
		}
		if p.Stepping && p.FromX == x && p.FromY == y {
			return true
		}
	}
	for _, e := range g.enemies {
		if e.X == x && e.Y == y {
			return true
		}
	}
	return false
}

// findSpawn searches outward from the board centre for a free tile. The caller
// must hold g.mu.
func (g *Game) findSpawn(excludeID int) (int, int) {
	w, h := g.mapWidth(), g.mapHeight()
	cx, cy := w/2, h/2
	maxR := w
	if h > maxR {
		maxR = h
	}
	for r := 0; r < maxR; r++ {
		for dy := -r; dy <= r; dy++ {
			for dx := -r; dx <= r; dx++ {
				if absInt(dx) != r && absInt(dy) != r {
					continue
				}
				x, y := cx+dx, cy+dy
				if !g.world.InBounds(x, y) {
					continue
				}
				if !g.world.IsWalkable(x, y) {
					continue
				}
				if !g.tileOccupied(x, y, excludeID) {
					return x, y
				}
			}
		}
	}
	return cx, cy
}

func (g *Game) spawnEnemy(kind string, x, y int) *Enemy {
	hp := 30
	if g.scripts != nil {
		if def, ok := g.scripts.Enemy(kind); ok && def.HP > 0 {
			hp = def.HP
		}
	}
	g.nextEnemyID++
	e := &Enemy{
		ID: g.nextEnemyID, Kind: kind,
		X: x, Y: y,
		HP: hp, MaxHP: hp,
	}
	g.enemies[e.ID] = e
	if g.ecs != nil {
		e.Entity = g.ecs.Add(&Entity{
			Kind: KindEnemy,
			Name: kind,
			Position: &CPosition{
				X: x, Y: y, FromX: x, FromY: y,
			},
			Health: &CHealth{HP: hp, MaxHP: hp},
			Combat: &CCombat{Damage: attackDamage, Range: attackRange},
			AI:     &CAI{Kind: kind, State: "idle"},
		})
	}
	return e
}

func (g *Game) addPlayer(out chan<- string) *Player {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.nextID++
	cx, cy := g.mapWidth()/2, g.mapHeight()/2
	p := &Player{
		ID:    g.nextID,
		TileX: cx, TileY: cy,
		FromX: cx, FromY: cy,
		FaceX: 0, FaceY: 1,
		HP: 100, MaxHP: 100,
		MP: maxManaDefault, MaxMP: maxManaDefault,
		LastManaTick: time.Now(),
		SpellCDs:     make(map[string]time.Time),
		Spells:       make(map[string]*Spell),
		Learned:      make(map[string]bool),
		SkillCDs:     make(map[string]time.Time),
		Stats:        &CStats{Level: 1, NextX: defaultProgression().XPBase},
		Equipped:     make(EquippedSet),
		Quests:       make(map[string]*QuestState),
		Out:          out,
	}
	g.players[p.ID] = p
	if g.ecs != nil {
		p.Entity = g.ecs.Add(&Entity{
			Kind: KindPlayer,
			Position: &CPosition{
				X: cx, Y: cy, FromX: cx, FromY: cy, FaceX: 0, FaceY: 1,
			},
			Health: &CHealth{
				HP: p.HP, MaxHP: p.MaxHP,
				MP: p.MP, MaxMP: p.MaxMP,
			},
			Combat:    &CCombat{Damage: attackDamage, Range: attackRange, Cooldown: attackCD},
			Inventory: &CInventory{Items: nil, Capacity: 32},
		})
	}
	return p
}

func (g *Game) bindName(id int, name string) *Player {
	g.mu.Lock()
	defer g.mu.Unlock()
	p, ok := g.players[id]
	if !ok {
		return nil
	}
	p.Name = name
	if g.db != nil {
		rec := g.db.LoadOrCreate(name)
		p.HP, p.MaxHP = rec.HP, rec.MaxHP
		p.MP, p.MaxMP = rec.MP, rec.MaxMP
		p.Kills = rec.Kills
		if p.MaxHP <= 0 {
			p.MaxHP = 100
		}
		if p.MaxMP <= 0 {
			p.MaxMP = maxManaDefault
		}
		if p.HP <= 0 {
			p.HP = p.MaxHP
		}
		if p.MP > p.MaxMP {
			p.MP = p.MaxMP
		}
		for _, sr := range g.db.LoadSpells(name) {
			p.Spells[sr.ID] = spellFromRecord(sr)
		}
		p.SkillPoints = rec.SkillPoints
		for _, id := range g.db.LoadLearnedSkills(name) {
			p.Learned[id] = true
		}
		// Stats / progression.
		if rec.Level > 0 {
			p.Stats.Level = rec.Level
		}
		p.Stats.XP = rec.XP
		p.Stats.Str = rec.Str
		p.Stats.Dex = rec.Dex
		p.Stats.Int = rec.Int
		p.Stats.Vit = rec.Vit
		p.Gold = rec.Gold
		pd := g.progression
		if pd == nil {
			pd = defaultProgression()
		}
		p.Stats.NextX = pd.xpForLevel(p.Stats.Level)
		// Inventory + equipment.
		if p.Entity != nil && p.Entity.Inventory != nil {
			p.Entity.Inventory.Items = g.db.LoadInventory(name)
		}
		for slot, ref := range g.db.LoadEquipped(name) {
			p.Equipped[slot] = ref
		}
		// Quest progress.
		for _, qs := range g.db.LoadQuests(name) {
			p.Quests[qs.ID] = qs
		}
		if g.world.InBounds(rec.X, rec.Y) && g.world.IsWalkable(rec.X, rec.Y) &&
			!g.tileOccupied(rec.X, rec.Y, p.ID) {
			p.TileX, p.TileY = rec.X, rec.Y
			p.FromX, p.FromY = rec.X, rec.Y
		} else {
			sx, sy := g.findSpawn(p.ID)
			p.TileX, p.TileY = sx, sy
			p.FromX, p.FromY = sx, sy
		}
	} else {
		sx, sy := g.findSpawn(p.ID)
		p.TileX, p.TileY = sx, sy
		p.FromX, p.FromY = sx, sy
	}
	p.Stepping = false
	if g.cache != nil {
		g.cache.SetOnline(name)
	}
	hookName := name
	hookID := p.ID
	if g.scripts != nil {
		go g.scripts.FireHook("player_join", map[string]interface{}{
			"name": hookName,
			"id":   hookID,
		})
	}
	return p
}

func (g *Game) removePlayer(id int) {
	g.mu.Lock()
	p, ok := g.players[id]
	if !ok {
		g.mu.Unlock()
		return
	}
	delete(g.players, id)
	leave := fmt.Sprintf("LEAVE %d\n", id)
	others := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		others = append(others, op.Out)
	}
	name := p.Name
	hp, maxHp := p.HP, p.MaxHP
	mp, maxMp := p.MP, p.MaxMP
	kills, x, y := p.Kills, p.TileX, p.TileY
	g.mu.Unlock()

	if name != "" && g.db != nil {
		g.db.Save(name, hp, maxHp, mp, maxMp, kills, x, y)
	}
	if name != "" && g.cache != nil {
		g.cache.SetOffline(name)
	}
	for _, out := range others {
		select {
		case out <- leave:
		default:
		}
	}
}

func (g *Game) handleLine(p *Player, line string) {
	if strings.HasPrefix(line, "SAVE_MAP ") {
		g.handleSaveMap(p, strings.TrimPrefix(line, "SAVE_MAP "))
		return
	}
	// Chat commands carry free-form text after the verb; tokenise the
	// first word and pass the rest through verbatim.
	if strings.HasPrefix(line, "SAY ") {
		g.handleSay(p, strings.TrimPrefix(line, "SAY "))
		return
	}
	if strings.HasPrefix(line, "SHOUT ") {
		g.handleShout(p, strings.TrimPrefix(line, "SHOUT "))
		return
	}
	if strings.HasPrefix(line, "WHISPER ") {
		rest := strings.TrimPrefix(line, "WHISPER ")
		i := strings.IndexByte(rest, ' ')
		if i <= 0 {
			return
		}
		g.handleWhisper(p, rest[:i], rest[i+1:])
		return
	}
	parts := strings.Fields(line)
	if len(parts) == 0 {
		return
	}
	switch parts[0] {
	case "NAME":
		if len(parts) < 2 {
			return
		}
		name := strings.Join(parts[1:], " ")
		if len(name) > 24 {
			name = name[:24]
		}
		name = sanitizeName(name)
		if name == "" {
			name = fmt.Sprintf("Hero%d", p.ID)
		}
		bound := g.bindName(p.ID, name)
		if bound != nil {
			g.sendMapTo(bound)
			g.sendCharacterState(bound)
		}
	case "MOVE":
		if len(parts) != 3 {
			return
		}
		dx := parseDir(parts[1])
		dy := parseDir(parts[2])
		g.mu.Lock()
		p.DirX, p.DirY = dx, dy
		g.mu.Unlock()
	case "ATTACK":
		g.handleAttack(p)
	case "REGSPELL":
		g.handleRegSpell(p, parts[1:])
	case "DELSPELL":
		if len(parts) < 2 {
			return
		}
		g.handleDelSpell(p, parts[1])
	case "CAST":
		if len(parts) < 2 {
			return
		}
		g.handleCast(p, parts[1])
	case "CASTSKILL":
		if len(parts) < 2 {
			return
		}
		g.handleCastSkill(p, parts[1])
	case "LEARN":
		if len(parts) < 2 {
			return
		}
		g.handleLearn(p, parts[1])
	case "RESETTREE":
		g.handleResetTree(p)
	case "EQUIP":
		if len(parts) < 2 {
			return
		}
		g.handleEquip(p, parts[1])
	case "UNEQUIP":
		if len(parts) < 2 {
			return
		}
		g.handleUnequip(p, parts[1])
	case "DROP":
		if len(parts) < 2 {
			return
		}
		qty := 1
		if len(parts) >= 3 {
			if n, err := strconv.Atoi(parts[2]); err == nil && n > 0 {
				qty = n
			}
		}
		g.handleDropItem(p, parts[1], qty)
	case "TALK":
		if len(parts) < 2 {
			return
		}
		g.handleTalk(p, parts[1])
	case "DIALOG_PICK":
		if len(parts) < 2 {
			return
		}
		idx, err := strconv.Atoi(parts[1])
		if err != nil {
			return
		}
		g.handleDialogPick(p, idx)
	case "DIALOG_END":
		g.handleDialogEnd(p)
	case "RELOAD":
		domain := "all"
		if len(parts) >= 2 {
			domain = parts[1]
		}
		g.handleReload(p, domain)
	}
}

// sendCharacterState pushes the freshly-bound character's WELCOME, STATS,
// every persisted SPELL_DEF, and the data-driven SKILL_DEF / SKILL_LEARNED /
// SKILL_POINTS bundle so the client can rebuild every UI surface before the
// first P snapshot lands.
func (g *Game) sendCharacterState(p *Player) {
	g.mu.Lock()
	welcome := fmt.Sprintf("WELCOME %d %d %d %s\n",
		p.ID, g.mapWidth(), g.mapHeight(), p.Name)
	stats := characterStatsLocked(p)
	defs := make([]string, 0, len(p.Spells))
	for _, sp := range p.Spells {
		defs = append(defs, formatSpellDef(sp))
	}
	learned := make([]string, 0, len(p.Learned))
	for id := range p.Learned {
		learned = append(learned, id)
	}
	sort.Strings(learned)
	sp := p.SkillPoints
	invWire := inventoryWire(p)
	eqWire := equippedWire(p)
	questWires := make([]string, 0, len(p.Quests))
	for _, qs := range p.Quests {
		questWires = append(questWires,
			fmt.Sprintf("QUEST_STATE %s %s %d %s\n",
				qs.ID, qs.Stage, qs.KillCount, boolToFlag(qs.Done)))
	}
	out := p.Out
	g.mu.Unlock()

	// Block (with a short safety timeout) instead of dropping. These are
	// one-shot state messages — losing one means the client never learns
	// what skills it owns, which is far worse than a few ms of latency.
	send := func(msg string) {
		select {
		case out <- msg:
		case <-time.After(250 * time.Millisecond):
			log.Printf("character state send timed out: %q", strings.TrimSpace(msg))
		}
	}
	send(welcome)
	send(stats)
	for _, def := range defs {
		send(def)
	}
	if g.scripts != nil {
		for _, sk := range g.scripts.Skills() {
			send(formatSkillDef(sk))
		}
		for _, it := range g.scripts.Items() {
			send(formatItemDef(it))
		}
		for _, npc := range g.scripts.NPCs() {
			send(formatNPCDef(npc))
		}
		for _, q := range g.scripts.Quests() {
			send(formatQuestDef(q))
		}
	}
	for _, id := range learned {
		send(fmt.Sprintf("SKILL_LEARNED %s\n", id))
	}
	send(fmt.Sprintf("SKILL_POINTS %d\n", sp))
	send(invWire)
	send(eqWire)
	for _, w := range questWires {
		send(w)
	}
}

func absInt(v int) int {
	if v < 0 {
		return -v
	}
	return v
}

func clampInt(v, lo, hi int) int {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

func validKind(s string) bool {
	return s == "line" || s == "area" || s == "self"
}

func validEffect(s string) bool {
	return s == "damage" || s == "heal" || s == "mana"
}

// handleRegSpell stores or replaces a spell in the caster's personal registry
// and persists it to the character_spells table.
// Format:
//
//	REGSPELL <id> <kind> <effect> <range> <radius> <power> <manaCost>
//	         <cooldownMs> <r> <g> <b> <name with spaces>
func (g *Game) handleRegSpell(p *Player, args []string) {
	if len(args) < 12 {
		return
	}
	id := args[0]
	kind := args[1]
	effect := args[2]
	if id == "" || !validKind(kind) || !validEffect(effect) {
		return
	}
	rng, err := strconv.Atoi(args[3])
	if err != nil {
		return
	}
	rad, err := strconv.Atoi(args[4])
	if err != nil {
		return
	}
	pwr, err := strconv.Atoi(args[5])
	if err != nil {
		return
	}
	mc, err := strconv.Atoi(args[6])
	if err != nil {
		return
	}
	cdMs, err := strconv.Atoi(args[7])
	if err != nil {
		return
	}
	rr, _ := strconv.Atoi(args[8])
	gg, _ := strconv.Atoi(args[9])
	bb, _ := strconv.Atoi(args[10])
	name := strings.Join(args[11:], " ")
	if len(name) > 64 {
		name = name[:64]
	}

	cd := time.Duration(cdMs) * time.Millisecond
	if cd < spellMinCooldown {
		cd = spellMinCooldown
	}
	if cd > spellMaxCooldown {
		cd = spellMaxCooldown
	}

	sp := &Spell{
		ID:       id,
		Name:     name,
		Kind:     kind,
		Effect:   effect,
		Range:    clampInt(rng, 0, spellMaxRange),
		Radius:   clampInt(rad, 0, spellMaxRadius),
		Power:    clampInt(pwr, 0, spellMaxPower),
		ManaCost: clampInt(mc, 0, spellMaxManaCost),
		Cooldown: cd,
		R:        clampInt(rr, 0, 255),
		G:        clampInt(gg, 0, 255),
		B:        clampInt(bb, 0, 255),
	}

	g.mu.Lock()
	if p.Spells == nil {
		p.Spells = make(map[string]*Spell)
	}
	p.Spells[sp.ID] = sp
	character := p.Name
	g.mu.Unlock()

	if character != "" && g.db != nil {
		g.db.UpsertSpell(character, sp.toRecord())
	}
}

func (g *Game) handleDelSpell(p *Player, id string) {
	g.mu.Lock()
	if p.Spells != nil {
		delete(p.Spells, id)
	}
	delete(p.SpellCDs, id)
	character := p.Name
	g.mu.Unlock()

	if character != "" && g.db != nil {
		g.db.DeleteSpell(character, id)
	}
}

func (g *Game) handleCast(p *Player, spellID string) {
	now := time.Now()
	g.mu.Lock()
	if p.Name == "" || p.HP <= 0 {
		g.mu.Unlock()
		return
	}
	sp, ok := p.Spells[spellID]
	if !ok {
		g.mu.Unlock()
		return
	}
	if cd, has := p.SpellCDs[spellID]; has && now.Before(cd) {
		g.mu.Unlock()
		return
	}
	if p.MP < sp.ManaCost {
		g.mu.Unlock()
		return
	}
	p.MP -= sp.ManaCost
	if p.SpellCDs == nil {
		p.SpellCDs = make(map[string]time.Time)
	}
	p.SpellCDs[spellID] = now.Add(sp.Cooldown)

	fx, fy := p.FaceX, p.FaceY
	if fx == 0 && fy == 0 {
		fy = 1
	}
	ox, oy := p.TileX, p.TileY

	var out combatOutcome

	hitEnemy := func(e *Enemy) {
		if sp.Effect != "damage" {
			return
		}
		g.damageEnemy(e, sp.Power, &out)
	}

	hitPlayer := func(op *Player, isCaster bool) {
		switch sp.Effect {
		case "damage":
			if isCaster {
				return
			}
			g.damagePlayer(op, sp.Power, &out)
		case "heal":
			op.HP += sp.Power
			if op.HP > op.MaxHP {
				op.HP = op.MaxHP
			}
		case "mana":
			op.MP += sp.Power
			if op.MP > op.MaxMP {
				op.MP = op.MaxMP
			}
		}
	}

	switch sp.Kind {
	case "line":
		for step := 1; step <= sp.Range; step++ {
			tx := ox + fx*step
			ty := oy + fy*step
			for _, e := range g.enemies {
				if e.X == tx && e.Y == ty {
					hitEnemy(e)
				}
			}
			for _, op := range g.players {
				if op.Name == "" || op.HP <= 0 || op.ID == p.ID {
					continue
				}
				if op.TileX == tx && op.TileY == ty {
					hitPlayer(op, false)
				}
			}
		}
	case "area":
		cx := ox + fx
		cy := oy + fy
		for _, e := range g.enemies {
			if absInt(e.X-cx) <= sp.Radius && absInt(e.Y-cy) <= sp.Radius {
				hitEnemy(e)
			}
		}
		for _, op := range g.players {
			if op.Name == "" || op.HP <= 0 {
				continue
			}
			if absInt(op.TileX-cx) <= sp.Radius && absInt(op.TileY-cy) <= sp.Radius {
				hitPlayer(op, op.ID == p.ID)
			}
		}
	case "self":
		hitPlayer(p, true)
	}

	spellMsg := fmt.Sprintf("SPELL %d %s %d %d %d %d %s %d %d %d %d %d\n",
		p.ID, spellID, fx, fy, ox, oy,
		sp.Kind, sp.Range, sp.Radius, sp.R, sp.G, sp.B)
	outs := g.snapshotOutsLocked()
	for _, e := range out.enemyKilled {
		delete(g.enemies, e.ID)
		p.Kills++
	}
	playerName := p.Name
	pid := p.ID
	g.mu.Unlock()

	g.broadcastCombat(outs, spellMsg, out, playerName)
	g.creditKills(pid, out)
}

func parseDir(s string) int {
	switch s {
	case "-1":
		return -1
	case "1":
		return 1
	}
	return 0
}

func sanitizeName(s string) string {
	var b strings.Builder
	for _, r := range s {
		if r == ' ' || r == '_' || r == '-' ||
			(r >= 'a' && r <= 'z') ||
			(r >= 'A' && r <= 'Z') ||
			(r >= '0' && r <= '9') {
			b.WriteRune(r)
		}
	}
	return strings.TrimSpace(b.String())
}

func (g *Game) handleAttack(p *Player) {
	now := time.Now()
	g.mu.Lock()
	out, atkMsg, ok := g.runMeleeAttack(p, now)
	if !ok {
		g.mu.Unlock()
		return
	}
	outs := g.snapshotOutsLocked()
	playerName := p.Name
	pid := p.ID
	g.mu.Unlock()

	g.broadcastCombat(outs, atkMsg, out, playerName)
	g.creditKills(pid, out)
}

// snapshotOutsLocked returns a fresh slice of every connected player's
// output channel. Caller must hold g.mu. The slice is detached from
// the map so the broadcast can run after the lock is released.
func (g *Game) snapshotOutsLocked() []chan<- string {
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	return outs
}

func (g *Game) broadcast(outs []chan<- string, msg string) {
	for _, out := range outs {
		select {
		case out <- msg:
		default:
		}
	}
}

func (g *Game) tick(now time.Time) {
	g.mu.Lock()

	g.runManaRegen(now)
	deadEnemies, deadPlayers := g.tickStatuses(now)
	g.runMovement(now)

	// Phase 3 — sync legacy structs into entities first, then run the
	// system pipeline (movement settle, health clamp, AI step+attack).
	// The snapshot is built afterward so it observes the post-AI state.
	g.aiOutbox = g.aiOutbox[:0]
	if g.ecs != nil {
		g.syncECSLocked(now)
		g.tickN++
		dt := time.Second / tickRate
		g.pipeline.Tick(g.ecs, now, dt)
	}

	msg := g.buildSnapshotLocked(now)
	outs := g.snapshotOutsLocked()
	flush := append([]string(nil), g.aiOutbox...)

	g.mu.Unlock()

	g.broadcast(outs, msg)
	for _, e := range deadEnemies {
		g.broadcast(outs, fmt.Sprintf("EDIE %d\n", e.ID))
	}
	for _, id := range deadPlayers {
		g.broadcast(outs, fmt.Sprintf("PDIE %d\n", id))
	}
	for _, m := range flush {
		g.broadcast(outs, m)
	}
}

// buildSnapshotLocked emits the per-tick "P"/"E"/"N" wire frame.
// Caller must hold g.mu.
//
// Phase 3 — gameplay code still owns Player / Enemy structs (the
// network IDs come from there to keep wire-protocol stability), but
// the field values come exclusively from the ECS Entity components
// that syncECSLocked freshly populated. New component kinds appear in
// the snapshot without touching this loop.
func (g *Game) buildSnapshotLocked(now time.Time) string {
	if len(g.players) == 0 && len(g.enemies) == 0 && g.ecs == nil {
		return ""
	}
	g.snapBuf.Reset()
	for _, p := range g.players {
		if p.Name == "" || p.Entity == nil || p.Entity.Position == nil || p.Entity.Health == nil {
			continue
		}
		pos := p.Entity.Position
		hp := p.Entity.Health
		x, y := positionInterpolated(pos, now)
		atk := 0
		if p.Entity.Combat != nil && now.Before(p.Entity.Combat.AttackUntil) {
			atk = 1
		}
		fmt.Fprintf(&g.snapBuf, "P %d %.3f %.3f %d %d %d %d %d %d %d %s\n",
			p.ID, x, y, pos.FaceX, pos.FaceY,
			hp.HP, hp.MaxHP, hp.MP, hp.MaxMP, atk, p.Name)
	}
	for _, e := range g.enemies {
		if e.Entity == nil || e.Entity.Position == nil || e.Entity.Health == nil {
			continue
		}
		pos := e.Entity.Position
		hp := e.Entity.Health
		fmt.Fprintf(&g.snapBuf, "E %d %s %d %d %d %d\n",
			e.ID, e.Kind, pos.X, pos.Y, hp.HP, hp.MaxHP)
	}
	if g.ecs != nil {
		g.ecs.Each(func(en *Entity) {
			if en.Kind != KindNPC || en.Position == nil {
				return
			}
			fmt.Fprintf(&g.snapBuf, "N %d %s %d %d\n",
				en.ID, en.Name, en.Position.X, en.Position.Y)
		})
	}
	return g.snapBuf.String()
}

// positionInterpolated mirrors Player.interpolated but runs on a
// CPosition snapshot so the network layer doesn't need a Player
// pointer.
func positionInterpolated(p *CPosition, now time.Time) (float64, float64) {
	if !p.Stepping {
		return float64(p.X), float64(p.Y)
	}
	t := float64(now.Sub(p.StepStart)) / float64(p.StepDur)
	if t >= 1 {
		t = 1
	}
	x := float64(p.FromX) + (float64(p.X)-float64(p.FromX))*t
	y := float64(p.FromY) + (float64(p.Y)-float64(p.FromY))*t
	return x, y
}

// syncECSLocked mirrors the gameplay structs into their entity
// components and drops entities whose backing Player/Enemy is gone.
// Caller must hold g.mu.
func (g *Game) syncECSLocked(_ time.Time) {
	alive := make(map[EntityID]bool, len(g.players)+len(g.enemies))

	for _, p := range g.players {
		if p.Entity == nil {
			continue
		}
		alive[p.Entity.ID] = true
		p.Entity.Name = p.Name
		if p.Entity.Position != nil {
			p.Entity.Position.X = p.TileX
			p.Entity.Position.Y = p.TileY
			p.Entity.Position.FromX = p.FromX
			p.Entity.Position.FromY = p.FromY
			p.Entity.Position.FaceX = p.FaceX
			p.Entity.Position.FaceY = p.FaceY
			p.Entity.Position.Stepping = p.Stepping
			p.Entity.Position.StepStart = p.StepStart
			p.Entity.Position.StepDur = p.StepDur
		}
		if p.Entity.Health != nil {
			p.Entity.Health.HP = p.HP
			p.Entity.Health.MaxHP = p.MaxHP
			p.Entity.Health.MP = p.MP
			p.Entity.Health.MaxMP = p.MaxMP
		}
		if p.Entity.Combat != nil {
			p.Entity.Combat.AttackUntil = p.AttackUntil
			p.Entity.Combat.NextAttack = p.NextAttack
		}
	}

	for _, e := range g.enemies {
		if e.Entity == nil {
			continue
		}
		alive[e.Entity.ID] = true
		if e.Entity.Position != nil {
			e.Entity.Position.X = e.X
			e.Entity.Position.Y = e.Y
		}
		if e.Entity.Health != nil {
			e.Entity.Health.HP = e.HP
			e.Entity.Health.MaxHP = e.MaxHP
		}
	}

	var orphans []EntityID
	g.ecs.Each(func(en *Entity) {
		if !alive[en.ID] {
			orphans = append(orphans, en.ID)
		}
	})
	for _, id := range orphans {
		g.ecs.Remove(id)
	}
}

// SnapshotECS returns a serializable view of the current entity
// world. Phase 4+ swaps this in for the bespoke "P"/"E" lines; the
// method exists today so external tooling (admin console, replay)
// can already consume it.
func (g *Game) SnapshotECS() Snapshot {
	g.mu.Lock()
	tn := g.tickN
	g.mu.Unlock()
	return g.ecs.SnapshotAt(tn)
}

func (g *Game) Loop() {
	ticker := time.NewTicker(time.Second / tickRate)
	defer ticker.Stop()
	saveTicker := time.NewTicker(15 * time.Second)
	defer saveTicker.Stop()
	for {
		select {
		case t := <-ticker.C:
			g.tick(t)
		case <-saveTicker.C:
			g.persistAll()
		}
	}
}

func (g *Game) persistAll() {
	if g.db == nil {
		return
	}
	type snap struct {
		name             string
		hp, maxHp        int
		mp, maxMp, kills int
		x, y             int
	}
	g.mu.Lock()
	snaps := make([]snap, 0, len(g.players))
	for _, p := range g.players {
		if p.Name == "" {
			continue
		}
		snaps = append(snaps, snap{
			p.Name,
			p.HP, p.MaxHP,
			p.MP, p.MaxMP, p.Kills,
			p.TileX, p.TileY,
		})
	}
	g.mu.Unlock()
	for _, s := range snaps {
		g.db.Save(s.name, s.hp, s.maxHp, s.mp, s.maxMp, s.kills, s.x, s.y)
	}
}

// sendMapTo dumps the active world to a single MAP message so the client
// can rebuild its renderer cache. Caller must hold g.mu *or* be confident
// no SAVE_MAP is in flight; the JSON serialisation copies the slice
// headers, so brief contention is acceptable.
func (g *Game) sendMapTo(p *Player) {
	g.mu.Lock()
	data, err := g.world.Marshal()
	g.mu.Unlock()
	if err != nil {
		log.Printf("map marshal: %v", err)
		return
	}
	msg := "MAP " + string(data) + "\n"
	select {
	case p.Out <- msg:
	default:
	}
}

// handleSaveMap accepts a JSON payload from the client, validates it, and
// atomically replaces the active map. On success the new map is broadcast
// to every connected player so everyone stays in sync without a reconnect.
func (g *Game) handleSaveMap(p *Player, payload string) {
	if len(payload) > saveMapMaxPayload {
		log.Printf("save_map from %d rejected: payload %d bytes", p.ID, len(payload))
		return
	}
	var m Map
	if err := json.Unmarshal([]byte(payload), &m); err != nil {
		log.Printf("save_map from %d: parse: %v", p.ID, err)
		return
	}
	if err := validateMap(&m); err != nil {
		log.Printf("save_map from %d: invalid: %v", p.ID, err)
		return
	}
	if err := SaveMap(&m); err != nil {
		log.Printf("save_map persist: %v", err)
		return
	}
	g.mu.Lock()
	g.world = &m
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	data, _ := g.world.Marshal()
	g.mu.Unlock()

	log.Printf("map %q saved by player %d (%dx%d, %d entities)",
		m.Name, p.ID, m.Width, m.Height, len(m.Entities))
	g.broadcast(outs, "MAP "+string(data)+"\n")
}
