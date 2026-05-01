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

// AISystem walks the AI component into the next State based on the
// shipped enemy archetypes. Phase 3 only ships a placeholder
// transition table (idle ⇄ chase) so we can prove the seam compiles
// and exercises every component pointer; real behaviour lives in
// data/scripts/enemies/* once Phase 4 hooks it up.
type AISystem struct {
	// Cb is invoked when the AI decides to act. The host wires this
	// to gameplay primitives (move toward target, attack, etc.).
	Cb func(self *Entity, action string)
}

func (s AISystem) Tick(w *ECSWorld, _ time.Time, _ time.Duration) {
	w.Each(func(e *Entity) {
		ai := e.AI
		if ai == nil {
			return
		}
		switch ai.State {
		case "":
			ai.State = "idle"
		case "idle":
			if ai.Target != 0 {
				ai.State = "chase"
				if s.Cb != nil {
					s.Cb(e, "engage")
				}
			}
		case "chase":
			if ai.Target == 0 {
				ai.State = "idle"
			}
		}
	})
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
