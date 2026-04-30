package main

import (
	"fmt"
	"math"
	"strings"
	"sync"
	"time"
)

const (
	tickRate    = 30
	playerSpeed = 4.0
	mapSize     = 20
)

type Player struct {
	ID     int
	X, Y   float64
	DX, DY float64
	Out    chan<- string
}

type Game struct {
	mu      sync.Mutex
	players map[int]*Player
	nextID  int
}

func NewGame() *Game {
	return &Game{players: make(map[int]*Player)}
}

func (g *Game) addPlayer(out chan<- string) *Player {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.nextID++
	p := &Player{
		ID:  g.nextID,
		X:   float64(mapSize) / 2,
		Y:   float64(mapSize) / 2,
		Out: out,
	}
	g.players[p.ID] = p
	return p
}

func (g *Game) removePlayer(id int) {
	g.mu.Lock()
	_, ok := g.players[id]
	if !ok {
		g.mu.Unlock()
		return
	}
	delete(g.players, id)
	leave := fmt.Sprintf("LEAVE %d\n", id)
	others := make([]chan<- string, 0, len(g.players))
	for _, p := range g.players {
		others = append(others, p.Out)
	}
	g.mu.Unlock()
	for _, out := range others {
		select {
		case out <- leave:
		default:
		}
	}
}

func (g *Game) setInput(id int, dx, dy float64) {
	mag := dx*dx + dy*dy
	if mag > 1 {
		s := 1.0 / math.Sqrt(mag)
		dx *= s
		dy *= s
	}
	g.mu.Lock()
	defer g.mu.Unlock()
	if p, ok := g.players[id]; ok {
		p.DX, p.DY = dx, dy
	}
}

func (g *Game) handleLine(p *Player, line string) {
	parts := strings.Fields(line)
	if len(parts) == 0 {
		return
	}
	switch parts[0] {
	case "MOVE":
		if len(parts) != 3 {
			return
		}
		var dx, dy float64
		fmt.Sscanf(parts[1], "%f", &dx)
		fmt.Sscanf(parts[2], "%f", &dy)
		g.setInput(p.ID, dx, dy)
	}
}

func (g *Game) tick(dt float64) {
	g.mu.Lock()
	max := float64(mapSize - 1)
	for _, p := range g.players {
		nx := p.X + p.DX*playerSpeed*dt
		ny := p.Y + p.DY*playerSpeed*dt
		if nx < 0 {
			nx = 0
		} else if nx > max {
			nx = max
		}
		if ny < 0 {
			ny = 0
		} else if ny > max {
			ny = max
		}
		p.X, p.Y = nx, ny
	}

	var sb strings.Builder
	for _, p := range g.players {
		fmt.Fprintf(&sb, "P %d %.3f %.3f\n", p.ID, p.X, p.Y)
	}
	msg := sb.String()
	outs := make([]chan<- string, 0, len(g.players))
	for _, p := range g.players {
		outs = append(outs, p.Out)
	}
	g.mu.Unlock()

	for _, out := range outs {
		select {
		case out <- msg:
		default:
		}
	}
}

func (g *Game) Loop() {
	dt := 1.0 / float64(tickRate)
	ticker := time.NewTicker(time.Second / tickRate)
	defer ticker.Stop()
	for range ticker.C {
		g.tick(dt)
	}
}
