package main

import (
	"fmt"
	"strings"
	"time"
)

// Phase 4 — Chat.
//
// Four channels: SAY (radius around speaker), SHOUT (whole map),
// WHISPER (single named target), and SYS (BroadcastSystem from
// scripts). All four converge on broadcastTo so rate-limit / mute
// hooks can be added in one place later.

const (
	chatSayRadius     = 8
	chatShoutCooldown = 1500 * time.Millisecond
	chatMaxMsgLen     = 200
)

// sanitizeChatMessage strips control characters and collapses long
// strings so a malicious client can't push 4 KiB of nulls through the
// room.
func sanitizeChatMessage(s string) string {
	s = strings.ReplaceAll(s, "\r", " ")
	s = strings.ReplaceAll(s, "\n", " ")
	s = strings.TrimSpace(s)
	if len(s) > chatMaxMsgLen {
		s = s[:chatMaxMsgLen]
	}
	return s
}

func (g *Game) handleSay(p *Player, msg string) {
	msg = sanitizeChatMessage(msg)
	if msg == "" {
		return
	}
	g.mu.Lock()
	if p.Name == "" {
		g.mu.Unlock()
		return
	}
	wire := fmt.Sprintf("CHAT SAY %s %s\n", p.Name, msg)
	x, y := p.TileX, p.TileY
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		if op.Name == "" {
			continue
		}
		if absInt(op.TileX-x) > chatSayRadius || absInt(op.TileY-y) > chatSayRadius {
			continue
		}
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	g.broadcast(outs, wire)
}

func (g *Game) handleShout(p *Player, msg string) {
	msg = sanitizeChatMessage(msg)
	if msg == "" {
		return
	}
	now := time.Now()
	g.mu.Lock()
	if p.Name == "" || now.Before(p.NextShout) {
		g.mu.Unlock()
		return
	}
	p.NextShout = now.Add(chatShoutCooldown)
	wire := fmt.Sprintf("CHAT SHOUT %s %s\n", p.Name, msg)
	outs := make([]chan<- string, 0, len(g.players))
	for _, op := range g.players {
		if op.Name == "" {
			continue
		}
		outs = append(outs, op.Out)
	}
	g.mu.Unlock()
	g.broadcast(outs, wire)
}

func (g *Game) handleWhisper(p *Player, target, msg string) {
	msg = sanitizeChatMessage(msg)
	if msg == "" || target == "" {
		return
	}
	g.mu.Lock()
	if p.Name == "" {
		g.mu.Unlock()
		return
	}
	var dst *Player
	for _, op := range g.players {
		if op.Name == target {
			dst = op
			break
		}
	}
	if dst == nil {
		out := p.Out
		g.mu.Unlock()
		sendNow(out, fmt.Sprintf("CHAT SYS server %s_offline\n", target))
		return
	}
	wire := fmt.Sprintf("CHAT WHISPER %s %s %s\n", p.Name, dst.Name, msg)
	srcOut := p.Out
	dstOut := dst.Out
	g.mu.Unlock()
	sendNow(srcOut, wire)
	sendNow(dstOut, wire)
}
