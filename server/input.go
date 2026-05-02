package main

import (
	"strconv"
	"sync"
	"time"
)

// Phase 4 → 5 — Player input pipeline.
//
// All player intent (WSAD movement and basic attack) flows through a
// single dispatch path: parse → validate → rate-limit → mutate the
// authoritative Player struct. Game.handleLine forwards MOVE / WSAD /
// ATTACK to the helpers in this file so the network layer stays free
// of gameplay rules.
//
// Rate limiting (anti-cheat seed). The server is already authoritative
// on positions/cooldowns, but a malicious client could still flood
// MOVE/ATTACK frames to force a hot loop on the host. The token bucket
// here caps how many input frames a single connection can consume per
// second; excess frames are silently dropped. The limits are generous
// enough that legitimate input never trips them.

const (
	// inputMoveBurst is the burst size of the per-player MOVE bucket.
	inputMoveBurst = 60
	// inputMoveRefillEvery is how often a single MOVE token is added.
	inputMoveRefillEvery = 16 * time.Millisecond // ~60 Hz steady-state.
	// inputAttackBurst sets how many ATTACK messages can arrive in a
	// burst (ATTACK is also gated by NextAttack, this is just a flood
	// preventer).
	inputAttackBurst       = 8
	inputAttackRefillEvery = 100 * time.Millisecond
	// inputGlobalBurst caps the total command rate per connection,
	// independent of which verb is used. Gives the rest of the protocol
	// (chat, equip, talk…) a single throttle.
	inputGlobalBurst       = 240
	inputGlobalRefillEvery = 8 * time.Millisecond
)

// tokenBucket is a tiny throttle: refill one token every `every`,
// capped at `burst`. Allow returns false when the bucket is empty.
type tokenBucket struct {
	mu     sync.Mutex
	tokens int
	burst  int
	every  time.Duration
	last   time.Time
}

func newBucket(burst int, every time.Duration) *tokenBucket {
	return &tokenBucket{tokens: burst, burst: burst, every: every, last: time.Now()}
}

func (b *tokenBucket) allow(now time.Time) bool {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.every > 0 {
		gap := now.Sub(b.last)
		if gap >= b.every {
			add := int(gap / b.every)
			b.tokens += add
			if b.tokens > b.burst {
				b.tokens = b.burst
			}
			b.last = b.last.Add(time.Duration(add) * b.every)
		}
	}
	if b.tokens <= 0 {
		return false
	}
	b.tokens--
	return true
}

// inputThrottle bundles the per-connection rate buckets. Lives on the
// Player struct (one-per-player) so the channel close cleans it up
// automatically.
type inputThrottle struct {
	move   *tokenBucket
	attack *tokenBucket
	global *tokenBucket
}

func newInputThrottle() *inputThrottle {
	return &inputThrottle{
		move:   newBucket(inputMoveBurst, inputMoveRefillEvery),
		attack: newBucket(inputAttackBurst, inputAttackRefillEvery),
		global: newBucket(inputGlobalBurst, inputGlobalRefillEvery),
	}
}

// allowGlobal is the umbrella throttle every command checks first.
func (t *inputThrottle) allowGlobal(now time.Time) bool {
	if t == nil {
		return true
	}
	return t.global.allow(now)
}

// parseDirToken accepts "-1" | "0" | "1" and clamps anything else to 0.
// Reused by both MOVE and the WSAD alias.
func parseDirToken(s string) (int, bool) {
	v, err := strconv.Atoi(s)
	if err != nil {
		return 0, false
	}
	if v < -1 {
		v = -1
	}
	if v > 1 {
		v = 1
	}
	return v, true
}

// applyMoveIntent sets the player's desired direction. WSAD on the
// client maps each physical key to a delta and the resolved (dx, dy)
// is sent here. Caller must NOT hold g.mu — we acquire it.
func (g *Game) applyMoveIntent(p *Player, dx, dy int) {
	if p == nil {
		return
	}
	now := time.Now()
	if p.Throttle != nil && !p.Throttle.move.allow(now) {
		mlog.Info("MOVE throttled", "player", p.ID)
		return
	}
	g.mu.Lock()
	if p.HP <= 0 {
		p.DirX, p.DirY = 0, 0
		g.mu.Unlock()
		return
	}
	p.DirX, p.DirY = dx, dy
	mlog.Info("MOVE applied", "player", p.ID, "name", p.Name, "dx", dx, "dy", dy,
		"tilex", p.TileX, "tiley", p.TileY, "stepping", p.Stepping, "hp", p.HP)
	if dx != 0 || dy != 0 {
		p.FaceX, p.FaceY = dx, dy
	}
	g.mu.Unlock()
}

// applyAttackIntent is the entry point for the basic attack. It
// short-circuits when the throttle bucket is empty so a flooded
// connection never reaches handleAttack at all.
func (g *Game) applyAttackIntent(p *Player) {
	if p == nil {
		return
	}
	now := time.Now()
	if p.Throttle != nil && !p.Throttle.attack.allow(now) {
		return
	}
	g.handleAttack(p)
}
