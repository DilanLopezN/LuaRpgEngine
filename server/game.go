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
	"sync/atomic"
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

	// Phase 5 — per-connection input throttle. nil for tests that
	// bypass addPlayer; the helpers in input.go nil-check before use.
	Throttle *inputThrottle

	// Phase 5 — per-player AoI / snapshot diff state. The host fills
	// LastSeen each tick with the entities the client now knows about
	// so the next tick can emit only what changed.
	LastSeen map[snapKey]snapState
	LastFull time.Time

	// Phase 5 — heartbeat. Owned by HandleConn; nil for tests that
	// bypass the network layer. Stored as a pointer so the conn-level
	// goroutine and handleLine can race-free update it via atomic.
	lastPong *atomic.Int64

	// Phase 1 — SAVE_MAP rate-limit bucket. Created on demand the first
	// time the player issues a SAVE_MAP so non-editor sessions pay zero
	// memory.
	saveMapBucket *tokenBucket

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
// type=npc record into a live entity. Friendly / merchant / quest_giver
// NPCs go in as static dialog entities; guardian / enemy NPCs are
// promoted to Enemy and join the AI / combat / loot pipeline so the
// editor can drop a hostile NPC and watch it actually fight.
//
// Caller does not need to hold g.mu when called from NewGame
// (single-threaded boot). When called from handleSaveMap, the caller
// MUST hold g.mu — see reconcileMapNPCsLocked.
func (g *Game) spawnNPCsFromMap() {
	if g.world == nil {
		return
	}
	for _, ent := range g.world.Entities {
		if ent.Type != "npc" {
			continue
		}
		def, _ := g.npcDefFor(ent.Kind)
		sprite := ent.Sprite
		if sprite == "" && def != nil {
			sprite = def.Sprite
		}
		if def != nil && def.IsHostile() {
			// Hostile NPCs reuse the enemy spawning path so they
			// inherit the AI tick, attack callbacks, and loot
			// hook. The synthetic EnemyDef installed by
			// loadNPCs makes the kind lookup succeed.
			e := g.spawnEnemy(ent.Kind, ent.X, ent.Y)
			if e != nil && e.Entity != nil {
				e.Entity.Sprite = sprite
			}
			continue
		}
		g.spawnNPC(ent.Kind, sprite, ent.X, ent.Y)
	}
}

// npcDefFor looks up an NPC definition without holding g.mu. The
// scripts subsystem keeps its own lock; callers must not pass g.mu in.
func (g *Game) npcDefFor(id string) (*NPCDef, bool) {
	if g.scripts == nil {
		return nil, false
	}
	return g.scripts.NPC(id)
}

// reconcileMapNPCsLocked tears down NPC entities sourced from the map
// (whether they ended up as KindNPC or KindEnemy via the hostile
// promotion) and rebuilds them from the current g.world.Entities.
// Used after SAVE_MAP so editor placements take effect immediately
// without a server restart. Caller MUST hold g.mu.
func (g *Game) reconcileMapNPCsLocked() {
	if g.ecs == nil {
		return
	}
	// Collect NPC entities — these are always map-sourced.
	var dropEntities []EntityID
	g.ecs.Each(func(e *Entity) {
		if e.Kind == KindNPC {
			dropEntities = append(dropEntities, e.ID)
		}
	})
	for _, id := range dropEntities {
		g.ecs.Remove(id)
	}
	// Drop enemies that originated from a hostile NPC kind. We treat
	// any enemy whose kind matches a known hostile NPC as map-sourced.
	// The two stock orcs spawned in NewGame keep ".Kind == orc"
	// which is NOT in the npcs registry, so they survive.
	hostile := make(map[string]bool)
	if g.scripts != nil {
		for id, def := range g.scripts.NPCs() {
			if def.IsHostile() {
				hostile[id] = true
			}
		}
	}
	for id, e := range g.enemies {
		if hostile[e.Kind] {
			if e.Entity != nil {
				g.ecs.Remove(e.Entity.ID)
			}
			delete(g.enemies, id)
		}
	}
	g.spawnNPCsFromMap()
}

// spawnNPC adds an NPC entity to the ECS world. NPCs do not move and
// have no Health component — talking to them ignores HP. Sprite is the
// client-side artwork id chosen in the "Criar NPCs" editor; an empty
// string means "use the default look".
func (g *Game) spawnNPC(kind, sprite string, x, y int) *Entity {
	if g.ecs == nil {
		return nil
	}
	return g.ecs.Add(&Entity{
		Kind:   KindNPC,
		Name:   kind,
		Sprite: sprite,
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
		Throttle:     newInputThrottle(),
		LastSeen:     make(map[snapKey]snapState),
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
		// Quest progress. Progress slice is padded against the active
		// QuestDef's objective list so a designer adding an objective
		// to an existing quest doesn't break in-flight playthroughs.
		for _, qs := range g.db.LoadQuests(name) {
			if g.scripts != nil {
				if def, ok := g.scripts.Quest(qs.ID); ok {
					ensureProgressLen(qs, len(def.Objectives))
				}
			}
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
	fmt.Printf(">>> handleLine player=%d line=%q\n", p.ID, line)
	if p != nil && p.Throttle != nil && !p.Throttle.allowGlobal(time.Now()) {
		// Drop this command entirely. Legitimate clients never trip the
		// global bucket; floods are absorbed silently to avoid feeding
		// any signal back to the attacker.
		return
	}
	if strings.HasPrefix(line, "SAVE_MAP ") {
		g.handleSaveMap(p, strings.TrimPrefix(line, "SAVE_MAP "))
		return
	}
	// In-game NPC authoring. The editor sends the full NPCDef as a
	// JSON document; we parse, persist to npcs_user/, and broadcast
	// the new NPC_DEF so every player's UI updates without a /reload.
	if strings.HasPrefix(line, "SAVE_NPC_DEF ") {
		g.handleSaveNPCDef(p, strings.TrimPrefix(line, "SAVE_NPC_DEF "))
		return
	}
	if strings.HasPrefix(line, "DELETE_NPC_DEF ") {
		g.handleDeleteNPCDef(p, strings.TrimSpace(strings.TrimPrefix(line, "DELETE_NPC_DEF ")))
		return
	}
	// Quest authoring (Phase 4 — editor in-game). The payload is the
	// full QuestDef as JSON; the server parses, persists to
	// quests_user/<id>.json, and rebroadcasts QUEST_DEF.
	if strings.HasPrefix(line, "SAVE_QUEST_DEF ") {
		g.handleSaveQuestDef(p, strings.TrimPrefix(line, "SAVE_QUEST_DEF "))
		return
	}
	if strings.HasPrefix(line, "DELETE_QUEST_DEF ") {
		g.handleDeleteQuestDef(p, strings.TrimSpace(strings.TrimPrefix(line, "DELETE_QUEST_DEF ")))
		return
	}
	// Item authoring (Phase 4 — editor in-game). Same shape as the
	// quest / NPC paths: full ItemDef as JSON, persisted to
	// items_user/<id>.json, broadcast as ITEM_DEF so every connected
	// client's catalog updates in real time.
	if strings.HasPrefix(line, "SAVE_ITEM_DEF ") {
		g.handleSaveItemDef(p, strings.TrimPrefix(line, "SAVE_ITEM_DEF "))
		return
	}
	if strings.HasPrefix(line, "DELETE_ITEM_DEF ") {
		g.handleDeleteItemDef(p, strings.TrimSpace(strings.TrimPrefix(line, "DELETE_ITEM_DEF ")))
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
case "MOVE", "WSAD":
    fmt.Printf(">>> got %s from player %d (parts=%v)\n", parts[0], p.ID, parts)
    if len(parts) != 3 {
        fmt.Printf(">>> rejected: parts != 3 (got %d)\n", len(parts))
        return
    }
    dx, ok1 := parseDirToken(parts[1])
    dy, ok2 := parseDirToken(parts[2])
    fmt.Printf(">>> parsed dx=%d dy=%d (ok1=%v ok2=%v)\n", dx, dy, ok1, ok2)
    if !ok1 || !ok2 {
        return
    }
    g.applyMoveIntent(p, dx, dy)
	case "ATTACK":
		g.applyAttackIntent(p)
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
	case "USE":
		if len(parts) < 2 {
			return
		}
		g.handleUseItem(p, parts[1])
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
		questWires = append(questWires, questProgressLine(qs))
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
	if msg == "" {
		return
	}
	for _, out := range outs {
		select {
		case out <- msg:
		default:
		}
	}
	metricsBroadcastObserved(len(outs))
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

	// Phase 5 — per-player AoI + snapshot diff. Each named player gets
	// only the entities within their interest radius, and only the
	// ones whose state changed since the last tick.
	type perPlayer struct {
		out chan<- string
		msg string
	}
	frames := make([]perPlayer, 0, len(g.players))
	for _, p := range g.players {
		if p.Name == "" {
			continue
		}
		frames = append(frames, perPlayer{
			out: p.Out,
			msg: g.buildPlayerSnapshot(p, now),
		})
	}
	outs := g.snapshotOutsLocked()
	flush := append([]string(nil), g.aiOutbox...)

	g.mu.Unlock()

	for _, f := range frames {
		if f.msg == "" {
			continue
		}
		select {
		case f.out <- f.msg:
		default:
		}
	}
	metricsTickObserved(len(frames))
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
//
// Concurrency: the snapshot is built under Game.mu so the copy made
// by Entity.Snapshot() observes a consistent view — AI callbacks
// mutate component pointers under Game.mu, so reading them from a
// goroutine without the lock would race. The lock is dropped before
// returning, so the caller can serialise / send the result freely.
func (g *Game) SnapshotECS() Snapshot {
	g.mu.Lock()
	defer g.mu.Unlock()
	return g.ecs.SnapshotAt(g.tickN)
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
	// Phase 1 hardening: throttle SAVE_MAP to 1 per second per player so
	// a held key (or a malicious client) can't spam timestamped backups
	// to disk. The bucket is lazy because non-editor sessions never
	// trip the path.
	if p != nil {
		if p.saveMapBucket == nil {
			p.saveMapBucket = newBucket(1, time.Second)
		}
		if !p.saveMapBucket.allow(time.Now()) {
			mlog.Info("SAVE_MAP throttled", "player", p.ID)
			return
		}
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
	// Reconcile live NPC entities so the editor's placements (or
	// removals) reflect on every player's screen on the next tick
	// without needing a server restart. Reseting LastFull on each
	// viewer forces the next snapshot to be a full one — that wipes
	// the per-client AoI cache so a deleted NPC doesn't linger in
	// LastSeen waiting for an X drop line that never comes.
	g.reconcileMapNPCsLocked()
	for _, op := range g.players {
		op.LastSeen = nil
		op.LastFull = time.Time{}
	}
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

// handleSaveNPCDef accepts a full NPCDef as JSON, persists it under
// data/scripts/npcs_user/, refreshes the live registry (so live
// instances of the NPC pick up new HP / dialog / role on next tick)
// and rebroadcasts the NPC_DEF wire frame so every player's UI
// catalog stays in sync. The hostile-promotion lookup happens
// inside SaveUserNPC, so a freshly-authored guardian becomes a
// spawnable enemy immediately.
func (g *Game) handleSaveNPCDef(p *Player, payload string) {
	if g.scripts == nil {
		return
	}
	if len(payload) > 256*1024 {
		log.Printf("save_npc_def from %d rejected: payload too large", p.ID)
		return
	}
	var raw interface{}
	if err := json.Unmarshal([]byte(payload), &raw); err != nil {
		log.Printf("save_npc_def from %d: parse: %v", p.ID, err)
		return
	}
	def, err := parseNPCDef(raw, "")
	if err != nil {
		log.Printf("save_npc_def from %d: invalid: %v", p.ID, err)
		return
	}
	clean := sanitizeNPCID(def.ID)
	if clean == "" {
		log.Printf("save_npc_def from %d: invalid id", p.ID)
		return
	}
	def.ID = clean
	if err := g.scripts.SaveUserNPC(def); err != nil {
		log.Printf("save_npc_def persist: %v", err)
		return
	}
	// If the saved NPC is currently placed on the map, reconcile so
	// its role / HP / sprite changes go live immediately.
	g.mu.Lock()
	g.reconcileMapNPCsLocked()
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		op.LastSeen = nil
		op.LastFull = time.Time{}
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	log.Printf("npc def %q saved by player %d", def.ID, p.ID)
	g.broadcast(outs, formatNPCDef(def))
}

// handleSaveQuestDef accepts a full QuestDef as JSON, persists it
// under data/scripts/quests_user/, refreshes the live registry, and
// rebroadcasts QUEST_DEF so every connected client's journal/editor
// picks up the new quest. Players who already have an active state
// for this quest get their Progress slice padded so a designer
// adding a fifth objective doesn't break in-flight playthroughs.
func (g *Game) handleSaveQuestDef(p *Player, payload string) {
	if g.scripts == nil {
		return
	}
	if len(payload) > 256*1024 {
		log.Printf("save_quest_def from %d rejected: payload too large", p.ID)
		return
	}
	var raw interface{}
	if err := json.Unmarshal([]byte(payload), &raw); err != nil {
		log.Printf("save_quest_def from %d: parse: %v", p.ID, err)
		return
	}
	def, err := parseQuestDef(raw, "")
	if err != nil {
		log.Printf("save_quest_def from %d: invalid: %v", p.ID, err)
		return
	}
	clean := sanitizeNPCID(def.ID)
	if clean == "" {
		log.Printf("save_quest_def from %d: invalid id", p.ID)
		return
	}
	def.ID = clean
	if err := g.scripts.SaveUserQuest(def); err != nil {
		log.Printf("save_quest_def persist: %v", err)
		return
	}
	g.mu.Lock()
	outs := make([]chan<- string, 0, len(g.players))
	updates := make([]string, 0)
	for _, op := range g.players {
		if qs, ok := op.Quests[def.ID]; ok {
			ensureProgressLen(qs, len(def.Objectives))
			updates = append(updates, questProgressLine(qs))
		}
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	log.Printf("quest def %q saved by player %d", def.ID, p.ID)
	g.broadcast(outs, formatQuestDef(def))
	for _, w := range updates {
		g.broadcast(outs, w)
	}
}

// handleDeleteQuestDef drops a user-authored quest. Live state for
// players who have it accepted stays in their journal but turns into
// a no-op (the def lookup at completion will miss).
func (g *Game) handleDeleteQuestDef(p *Player, id string) {
	if g.scripts == nil {
		return
	}
	clean := sanitizeNPCID(id)
	if clean == "" {
		return
	}
	if err := g.scripts.DeleteUserQuest(clean); err != nil {
		log.Printf("delete_quest_def: %v", err)
		return
	}
	g.mu.Lock()
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	log.Printf("quest def %q deleted by player %d", clean, p.ID)
	g.broadcast(outs, "QUEST_DEF_DELETE "+clean+"\n")
}

// handleSaveItemDef accepts a full ItemDef as JSON, persists it under
// data/scripts/items_user/, refreshes the live registry, and
// rebroadcasts ITEM_DEF so every connected client's catalog updates
// without needing a /reload.
func (g *Game) handleSaveItemDef(p *Player, payload string) {
	if g.scripts == nil {
		return
	}
	if len(payload) > 256*1024 {
		log.Printf("save_item_def from %d rejected: payload too large", p.ID)
		return
	}
	var raw interface{}
	if err := json.Unmarshal([]byte(payload), &raw); err != nil {
		log.Printf("save_item_def from %d: parse: %v", p.ID, err)
		return
	}
	def, err := parseItemDef(raw, "")
	if err != nil {
		log.Printf("save_item_def from %d: invalid: %v", p.ID, err)
		return
	}
	clean := sanitizeNPCID(def.ID)
	if clean == "" {
		log.Printf("save_item_def from %d: invalid id", p.ID)
		return
	}
	def.ID = clean
	if err := g.scripts.SaveUserItem(def); err != nil {
		log.Printf("save_item_def persist: %v", err)
		return
	}
	g.mu.Lock()
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	log.Printf("item def %q saved by player %d", def.ID, p.ID)
	g.broadcast(outs, formatItemDef(def))
}

// handleDeleteItemDef drops a user-authored item. Players still
// carrying it keep their stack; lookups in the catalog miss but the
// inventory line stays intact (the wire renders "<id>" so the player
// can still drop it).
func (g *Game) handleDeleteItemDef(p *Player, id string) {
	if g.scripts == nil {
		return
	}
	clean := sanitizeNPCID(id)
	if clean == "" {
		return
	}
	if err := g.scripts.DeleteUserItem(clean); err != nil {
		log.Printf("delete_item_def: %v", err)
		return
	}
	g.mu.Lock()
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	log.Printf("item def %q deleted by player %d", clean, p.ID)
	g.broadcast(outs, "ITEM_DEF_DELETE "+clean+"\n")
}

// handleDeleteNPCDef drops a user-authored NPC. The on-disk JSON is
// removed and the live registry forgets the id. Any map entity that
// references the now-absent NPC will fall back to a placeholder
// renderer client-side; deleting also removes the NPC from any
// active dialog by re-running reconcile.
func (g *Game) handleDeleteNPCDef(p *Player, id string) {
	if g.scripts == nil {
		return
	}
	clean := sanitizeNPCID(id)
	if clean == "" {
		return
	}
	if err := g.scripts.DeleteUserNPC(clean); err != nil {
		log.Printf("delete_npc_def: %v", err)
		return
	}
	g.mu.Lock()
	g.reconcileMapNPCsLocked()
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		op.LastSeen = nil
		op.LastFull = time.Time{}
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	log.Printf("npc def %q deleted by player %d", clean, p.ID)
	g.broadcast(outs, "NPC_DEF_DELETE "+clean+"\n")
}
