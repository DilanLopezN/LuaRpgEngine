package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
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

	Out chan<- string
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
}

func NewGame(db *DB, cache *Cache) *Game {
	g := &Game{
		players: make(map[int]*Player),
		enemies: make(map[int]*Enemy),
		db:      db,
		cache:   cache,
	}
	m, err := LoadMap(defaultMapName)
	if err != nil {
		log.Printf("map load failed (%v); starting from blank map", err)
		m = DefaultMap(defaultMapName)
	} else {
		log.Printf("loaded map %q (%dx%d, %d entities)",
			m.Name, m.Width, m.Height, len(m.Entities))
	}
	g.world = m
	g.spawnEnemy("orc", 1, 1)
	g.spawnEnemy("orc", 6, 6)
	return g
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
	g.nextEnemyID++
	e := &Enemy{
		ID: g.nextEnemyID, Kind: kind,
		X: x, Y: y,
		HP: 30, MaxHP: 30,
	}
	g.enemies[e.ID] = e
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
		Out:          out,
	}
	g.players[p.ID] = p
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
			welcome := fmt.Sprintf("WELCOME %d %d %d %s\n",
				bound.ID, g.mapWidth(), g.mapHeight(), bound.Name)
			select {
			case bound.Out <- welcome:
			default:
			}
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
	}
}

// sendCharacterState pushes the freshly-bound character's WELCOME, STATS, and
// every persisted SPELL_DEF down the wire so the client can rebuild the HUD,
// spell registry, and skillbar before the first P snapshot lands.
func (g *Game) sendCharacterState(p *Player) {
	g.mu.Lock()
	welcome := fmt.Sprintf("WELCOME %d %d %d %s\n",
		p.ID, g.mapWidth(), g.mapHeight(), p.Name)
	stats := fmt.Sprintf("STATS %d %d %d %d\n", p.HP, p.MaxHP, p.MP, p.MaxMP)
	defs := make([]string, 0, len(p.Spells))
	for _, sp := range p.Spells {
		defs = append(defs, formatSpellDef(sp))
	}
	out := p.Out
	g.mu.Unlock()

	send := func(msg string) {
		select {
		case out <- msg:
		default:
		}
	}
	send(welcome)
	send(stats)
	for _, def := range defs {
		send(def)
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

	var (
		hits    []int
		killed  []*Enemy
		pHits   []int
		pKilled []int
	)

	hitEnemy := func(e *Enemy) {
		if sp.Effect != "damage" {
			return
		}
		e.HP -= sp.Power
		hits = append(hits, e.ID)
		if e.HP <= 0 {
			killed = append(killed, e)
		}
	}

	hitPlayer := func(op *Player, isCaster bool) {
		switch sp.Effect {
		case "damage":
			if isCaster {
				return
			}
			op.HP -= sp.Power
			pHits = append(pHits, op.ID)
			if op.HP <= 0 {
				op.HP = op.MaxHP
				op.Stepping = false
				op.DirX, op.DirY = 0, 0
				sx, sy := g.findSpawn(op.ID)
				op.TileX, op.TileY = sx, sy
				op.FromX, op.FromY = sx, sy
				pKilled = append(pKilled, op.ID)
			}
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
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}
	for _, e := range killed {
		delete(g.enemies, e.ID)
		p.Kills++
	}
	playerName := p.Name
	g.mu.Unlock()

	g.broadcast(outs, spellMsg)
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
	if p.Name == "" || now.Before(p.NextAttack) || p.HP <= 0 {
		g.mu.Unlock()
		return
	}
	p.AttackUntil = now.Add(attackDur)
	p.NextAttack = now.Add(attackCD)

	tx := float64(p.TileX) + float64(p.FaceX)
	ty := float64(p.TileY) + float64(p.FaceY)

	var killed []*Enemy
	var hits []int
	for _, e := range g.enemies {
		dx := float64(e.X) - tx
		dy := float64(e.Y) - ty
		if math.Hypot(dx, dy) <= attackRange {
			e.HP -= attackDamage
			hits = append(hits, e.ID)
			if e.HP <= 0 {
				killed = append(killed, e)
			}
		}
	}

	var pHits []int
	var pKilled []int
	for _, op := range g.players {
		if op.ID == p.ID || op.Name == "" || op.HP <= 0 {
			continue
		}
		dx := float64(op.TileX) - tx
		dy := float64(op.TileY) - ty
		if math.Hypot(dx, dy) <= attackRange {
			op.HP -= attackDamage
			pHits = append(pHits, op.ID)
			if op.HP <= 0 {
				op.HP = op.MaxHP
				op.Stepping = false
				op.DirX, op.DirY = 0, 0
				sx, sy := g.findSpawn(op.ID)
				op.TileX, op.TileY = sx, sy
				op.FromX, op.FromY = sx, sy
				pKilled = append(pKilled, op.ID)
			}
		}
	}

	atkMsg := fmt.Sprintf("ATK %d %d %d\n", p.ID, p.FaceX, p.FaceY)
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		outs = append(outs, op.Out)
	}

	for _, e := range killed {
		delete(g.enemies, e.ID)
		p.Kills++
	}
	playerName := p.Name
	g.mu.Unlock()

	g.broadcast(outs, atkMsg)
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

	for _, p := range g.players {
		if p.Stepping && now.Sub(p.StepStart) >= p.StepDur {
			p.FromX, p.FromY = p.TileX, p.TileY
			p.Stepping = false
		}
		if p.MaxMP > 0 && p.MP < p.MaxMP && now.Sub(p.LastManaTick) >= manaRegenInterval {
			p.MP += manaRegenAmount
			if p.MP > p.MaxMP {
				p.MP = p.MaxMP
			}
			p.LastManaTick = now
		}
	}

	for _, p := range g.players {
		if p.Stepping || p.Name == "" {
			continue
		}
		dx, dy := p.DirX, p.DirY
		if dx == 0 && dy == 0 {
			continue
		}
		nx, ny := p.TileX+dx, p.TileY+dy
		if !g.world.InBounds(nx, ny) {
			p.FaceX, p.FaceY = dx, dy
			continue
		}
		if !g.world.IsWalkable(nx, ny) {
			p.FaceX, p.FaceY = dx, dy
			continue
		}
		if g.tileOccupied(nx, ny, p.ID) {
			p.FaceX, p.FaceY = dx, dy
			continue
		}
		p.FromX, p.FromY = p.TileX, p.TileY
		p.TileX, p.TileY = nx, ny
		p.FaceX, p.FaceY = dx, dy
		p.Stepping = true
		p.StepStart = now
		if dx != 0 && dy != 0 {
			p.StepDur = time.Duration(float64(stepDuration) * diagFactor)
		} else {
			p.StepDur = stepDuration
		}
	}

	var sb strings.Builder
	for _, p := range g.players {
		if p.Name == "" {
			continue
		}
		x, y := p.interpolated(now)
		atk := 0
		if now.Before(p.AttackUntil) {
			atk = 1
		}
		fmt.Fprintf(&sb, "P %d %.3f %.3f %d %d %d %d %d %d %d %s\n",
			p.ID, x, y, p.FaceX, p.FaceY, p.HP, p.MaxHP, p.MP, p.MaxMP, atk, p.Name)
	}
	for _, e := range g.enemies {
		fmt.Fprintf(&sb, "E %d %s %d %d %d %d\n", e.ID, e.Kind, e.X, e.Y, e.HP, e.MaxHP)
	}
	msg := sb.String()
	outs := make([]chan<- string, 0, len(g.players))
	for _, p := range g.players {
		outs = append(outs, p.Out)
	}
	g.mu.Unlock()

	g.broadcast(outs, msg)
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
