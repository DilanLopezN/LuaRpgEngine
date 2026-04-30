package main

import (
	"fmt"
	"math"
	"strings"
	"sync"
	"time"
)

const (
	tickRate     = 30
	mapSize      = 8
	stepDuration = 250 * time.Millisecond
	diagFactor   = 1.41421356
	attackDur    = 350 * time.Millisecond
	attackCD     = 600 * time.Millisecond
	attackRange  = 1.5
	attackDamage = 10
)

type Player struct {
	ID   int
	Name string

	// Tile-based position. While stepping the renderable position is interpolated
	// between (FromX,FromY) and (TileX,TileY) using StepStart/StepDur (Tibia style).
	TileX, TileY int
	FromX, FromY int
	Stepping     bool
	StepStart    time.Time
	StepDur      time.Duration

	// Latest input direction (-1, 0, 1 each axis). Server schedules the next
	// step from this whenever the player is idle.
	DirX, DirY int

	// Last facing direction so attacks have a known orientation.
	FaceX, FaceY int

	HP, MaxHP int
	Kills     int

	AttackUntil time.Time
	NextAttack  time.Time

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
}

func NewGame(db *DB, cache *Cache) *Game {
	g := &Game{
		players: make(map[int]*Player),
		enemies: make(map[int]*Enemy),
		db:      db,
		cache:   cache,
	}
	g.spawnEnemy("orc", 1, 1)
	g.spawnEnemy("orc", 6, 6)
	return g
}

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

func absInt(v int) int {
	if v < 0 {
		return -v
	}
	return v
}

// findSpawn searches outward from the board centre for a free tile. The caller
// must hold g.mu.
func (g *Game) findSpawn(excludeID int) (int, int) {
	cx, cy := mapSize/2, mapSize/2
	for r := 0; r < mapSize; r++ {
		for dy := -r; dy <= r; dy++ {
			for dx := -r; dx <= r; dx++ {
				if absInt(dx) != r && absInt(dy) != r {
					continue
				}
				x, y := cx+dx, cy+dy
				if x < 0 || x >= mapSize || y < 0 || y >= mapSize {
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
	p := &Player{
		ID:    g.nextID,
		TileX: mapSize / 2, TileY: mapSize / 2,
		FromX: mapSize / 2, FromY: mapSize / 2,
		FaceX: 0, FaceY: 1,
		HP: 100, MaxHP: 100,
		Out: out,
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
		p.HP, p.Kills = rec.HP, rec.Kills
		if p.HP <= 0 {
			p.HP = p.MaxHP
		}
		if rec.X >= 0 && rec.X < mapSize && rec.Y >= 0 && rec.Y < mapSize &&
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
	hp, kills, x, y := p.HP, p.Kills, p.TileX, p.TileY
	g.mu.Unlock()

	if name != "" && g.db != nil {
		g.db.Save(name, hp, kills, x, y)
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
			welcome := fmt.Sprintf("WELCOME %d %d %s\n", bound.ID, mapSize, bound.Name)
			select {
			case bound.Out <- welcome:
			default:
			}
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
		if nx < 0 || nx >= mapSize || ny < 0 || ny >= mapSize {
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
		fmt.Fprintf(&sb, "P %d %.3f %.3f %d %d %d %d %s\n",
			p.ID, x, y, p.FaceX, p.FaceY, p.HP, atk, p.Name)
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
		name      string
		hp, kills int
		x, y      int
	}
	g.mu.Lock()
	snaps := make([]snap, 0, len(g.players))
	for _, p := range g.players {
		if p.Name == "" {
			continue
		}
		snaps = append(snaps, snap{p.Name, p.HP, p.Kills, p.TileX, p.TileY})
	}
	g.mu.Unlock()
	for _, s := range snaps {
		g.db.Save(s.name, s.hp, s.kills, s.x, s.y)
	}
}
