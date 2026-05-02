package main

import "time"

// Phase 3 — Sistemas independentes por responsabilidade.
//
// Each System operates on the components it needs and is allowed to
// ignore everything else. Game.Loop drives them in deterministic
// order each tick. The base implementation keeps three small systems
// online so the surface is exercised end-to-end; subsequent phases
// migrate combat, AI, projectiles, etc. onto this seam.

// System is the only contract the runtime imposes. Implementations
// must be safe to call without holding ECSWorld.mu — they take
// whatever lock they need internally. Dt is provided in case a system
// wants smooth updates between tick boundaries; integer-tick systems
// can ignore it.
type System interface {
	Tick(w *ECSWorld, now time.Time, dt time.Duration)
}

// MovementSystem closes out finished step animations (Stepping flag
// flips to false, FromX/Y catch up to X/Y). It deliberately does NOT
// initiate moves — that still lives in Game.tick because legacy
// Player/Enemy structs hold the source of truth until later phases
// migrate it.
type MovementSystem struct{}

func (MovementSystem) Tick(w *ECSWorld, now time.Time, _ time.Duration) {
	w.Each(func(e *Entity) {
		p := e.Position
		if p == nil || !p.Stepping {
			return
		}
		if now.Sub(p.StepStart) < p.StepDur {
			return
		}
		p.FromX, p.FromY = p.X, p.Y
		p.Stepping = false
	})
}

// HealthSystem clamps HP/MP within bounds and is the natural home for
// regeneration in Phase 4. Today it only enforces the invariants so
// damage/heal callsites can be sloppier.
type HealthSystem struct{}

func (HealthSystem) Tick(w *ECSWorld, _ time.Time, _ time.Duration) {
	w.Each(func(e *Entity) {
		h := e.Health
		if h == nil {
			return
		}
		if h.MaxHP > 0 && h.HP > h.MaxHP {
			h.HP = h.MaxHP
		}
		if h.HP < 0 {
			h.HP = 0
		}
		if h.MaxMP > 0 && h.MP > h.MaxMP {
			h.MP = h.MaxMP
		}
		if h.MP < 0 {
			h.MP = 0
		}
	})
}

// AISystem walks every enemy entity's AI: pick the closest player as
// target, step toward them while out of range, and trigger a contact
// attack when adjacent. The host wires the actual mutations through
// callbacks so the system stays decoupled from gameplay state.
type AISystem struct {
	// Targets is invoked once per tick to retrieve the targetable
	// entities (typically: alive named players). Returning a fresh
	// slice keeps the system free of locking concerns.
	Targets func() []*Entity
	// Step asks the host to move `self` one tile toward (tx, ty). The
	// host enforces walkability; AISystem doesn't care whether the
	// step actually landed.
	Step func(self *Entity, tx, ty int)
	// Attack asks the host to deliver one tick of contact damage from
	// `self` to `target`.
	Attack func(self, target *Entity)
	// SightRange is the Chebyshev distance at which an idle enemy
	// notices a player.
	SightRange int
	// AttackRange is the Chebyshev distance at which the AI attacks
	// instead of stepping closer.
	AttackRange int
}

func (s AISystem) Tick(w *ECSWorld, _ time.Time, _ time.Duration) {
	if s.SightRange == 0 {
		s.SightRange = 8
	}
	if s.AttackRange == 0 {
		s.AttackRange = 1
	}
	var targets []*Entity
	if s.Targets != nil {
		targets = s.Targets()
	}

	w.Each(func(e *Entity) {
		ai := e.AI
		if ai == nil || ai.Kind == "" || e.Kind != KindEnemy {
			return
		}
		if ai.State == "" {
			ai.State = "idle"
		}

		// Refresh target: nearest visible candidate, or 0 when none.
		var (
			nearest *Entity
			bestD   int
		)
		for _, t := range targets {
			if t == nil || t.Position == nil {
				continue
			}
			d := chebyshev(e.Position, t.Position)
			if d > s.SightRange {
				continue
			}
			if nearest == nil || d < bestD {
				nearest = t
				bestD = d
			}
		}
		if nearest == nil {
			ai.Target = 0
			ai.State = "idle"
			return
		}
		ai.Target = nearest.ID

		if bestD <= s.AttackRange {
			ai.State = "attack"
			if s.Attack != nil {
				s.Attack(e, nearest)
			}
			return
		}
		ai.State = "chase"
		if s.Step != nil {
			s.Step(e, nearest.Position.X, nearest.Position.Y)
		}
	})
}

func chebyshev(a, b *CPosition) int {
	dx := a.X - b.X
	if dx < 0 {
		dx = -dx
	}
	dy := a.Y - b.Y
	if dy < 0 {
		dy = -dy
	}
	if dx > dy {
		return dx
	}
	return dy
}

// SystemPipeline runs a fixed list of systems in order on every tick
// and exposes a single hook for the Game.Loop. Keeping the slice
// here makes it the canonical place to register a new system.
type SystemPipeline struct {
	Systems []System
}

// NewDefaultPipeline returns the Phase-3 baseline order: movement
// settles step animations first so HealthSystem sees the new tile,
// AISystem reacts last so it always operates on freshly clamped HP.
//
// The default pipeline ships with an inert AISystem (no callbacks set);
// the live game replaces it with a bound system that knows how to move
// and attack via the host. Tests can keep using the inert default.
func NewDefaultPipeline() *SystemPipeline {
	return &SystemPipeline{
		Systems: []System{
			MovementSystem{},
			HealthSystem{},
			AISystem{},
		},
	}
}

// Tick advances every registered system. The caller passes `now` so
// systems share a single clock reading (cheap, but matters for
// determinism in tests).
func (p *SystemPipeline) Tick(w *ECSWorld, now time.Time, dt time.Duration) {
	for _, s := range p.Systems {
		s.Tick(w, now, dt)
	}
}
