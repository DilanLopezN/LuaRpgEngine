package main

import (
	"sync"
	"time"
)

// Phase 3 — Sistema de Entidades (ECS Simplificado).
//
// Goal: collapse Player, Enemy, NPC, projectile, etc. into a single
// addressable thing — an Entity — and let independent Systems read the
// component pointers they care about without having to know the type.
//
// We deliberately avoid dense column storage / archetypes: this is a
// small server, the entity count is tiny, and pointer-per-component is
// more than fast enough while staying trivially debuggable. Phase 3
// only ships the *foundation*; the existing Player/Enemy structs keep
// driving gameplay until subsequent phases migrate logic onto Systems.

// EntityID is unique across the lifetime of the process. ID 0 is
// reserved as "no entity" so callers can return it as a not-found
// sentinel without colliding with a real entity.
type EntityID int

// Canonical entity kinds. Keep them as untyped constants so JSON
// snapshots stay stable regardless of refactors.
const (
	KindPlayer = "player"
	KindEnemy  = "enemy"
	KindNPC    = "npc"
)

// CPosition holds the tile-grid placement plus the in-flight step
// state used for client interpolation.
type CPosition struct {
	X, Y         int
	FromX, FromY int
	FaceX, FaceY int

	Stepping  bool
	StepStart time.Time
	StepDur   time.Duration
}

// CHealth covers both vitals so a single component carries the
// "alive / can act" surface.
type CHealth struct {
	HP, MaxHP int
	MP, MaxMP int
}

// CCombat owns attack timing and damage profile. Range is in tiles
// (float because diagonals exist).
type CCombat struct {
	Damage      int
	Range       float64
	Cooldown    time.Duration
	AttackUntil time.Time
	NextAttack  time.Time
}

// CAI is intentionally tiny in the base implementation — Phase 3 only
// needs the seam. Real behaviour trees / utility AI land in Phase 4+
// once the data-driven AI definitions exist.
type CAI struct {
	Kind   string // species / archetype id
	State  string // "idle" | "chase" | "attack" | "flee"
	Target EntityID
}

// CInventory lists carried items. The slice is the source of truth;
// stack rules are validated on mutation, not on read.
type CInventory struct {
	Items    []ItemRef
	Capacity int
}

// ItemRef is the on-the-wire reference to an item template. The actual
// item data lives in data/scripts/items/* once Phase 4 wires it up.
type ItemRef struct {
	ID  string `json:"id"`
	Qty int    `json:"qty"`
}

// Entity bundles components. Nil pointers mean "this entity does not
// have that component"; systems must always nil-check before touching.
//
// Sprite is an optional artwork id (matching a key in the client's
// Sprites.npcSprites table). It is purely cosmetic on the server side —
// the gameplay layer never reads it — but is forwarded to clients so the
// "Criar NPCs" editor's sprite selection survives the round trip.
type Entity struct {
	ID     EntityID
	Kind   string
	Name   string
	Sprite string

	// Phase 2 — which map this entity lives on. Empty string is read
	// as the default ("world") map. Players carry MapName on the
	// Player struct; the snapshot path mirrors it here so AoI filters
	// can stay component-only without crossing back through the Game.
	MapName string

	Position  *CPosition
	Health    *CHealth
	Combat    *CCombat
	AI        *CAI
	Inventory *CInventory
}

// ECSWorld is the registry. It is concurrency-safe for top-level
// Add/Remove/Get; component fields are mutated under the caller's
// lock (Game.mu today, until subsequent phases extract per-system
// locking).
type ECSWorld struct {
	mu       sync.RWMutex
	nextID   EntityID
	entities map[EntityID]*Entity
}

// NewECSWorld returns an empty world ready to receive entities.
func NewECSWorld() *ECSWorld {
	return &ECSWorld{entities: make(map[EntityID]*Entity)}
}

// Add registers a new entity, assigning a fresh ID, and returns it so
// callers can keep a pointer for fast component access without going
// back through Get.
func (w *ECSWorld) Add(e *Entity) *Entity {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.nextID++
	e.ID = w.nextID
	w.entities[e.ID] = e
	return e
}

// Remove drops the entity from the registry. Returns true if the ID
// existed.
func (w *ECSWorld) Remove(id EntityID) bool {
	w.mu.Lock()
	defer w.mu.Unlock()
	if _, ok := w.entities[id]; !ok {
		return false
	}
	delete(w.entities, id)
	return true
}

// Get returns the entity (or nil) without holding any lock to the
// caller — the pointer is shared mutable state, treat accordingly.
func (w *ECSWorld) Get(id EntityID) *Entity {
	w.mu.RLock()
	defer w.mu.RUnlock()
	return w.entities[id]
}

// Each invokes fn for every registered entity. Fn must not call back
// into Add/Remove on the same world (would deadlock).
func (w *ECSWorld) Each(fn func(*Entity)) {
	w.mu.RLock()
	defer w.mu.RUnlock()
	for _, e := range w.entities {
		fn(e)
	}
}

// ByKind returns a fresh slice of entities matching a given kind.
func (w *ECSWorld) ByKind(kind string) []*Entity {
	w.mu.RLock()
	defer w.mu.RUnlock()
	out := make([]*Entity, 0, len(w.entities))
	for _, e := range w.entities {
		if e.Kind == kind {
			out = append(out, e)
		}
	}
	return out
}

// Count reports the registry size, useful for telemetry / sanity
// asserts in tests.
func (w *ECSWorld) Count() int {
	w.mu.RLock()
	defer w.mu.RUnlock()
	return len(w.entities)
}

// --- Network serialization -------------------------------------------------
//
// Snapshot is the wire-friendly projection of the world. It strips the
// step-interpolation timestamps (clients don't need them; they get the
// interpolated x/y in the legacy P/E messages today) and only emits
// components the entity actually owns.
//
// In Phase 4 the snapshot will replace the bespoke "P" / "E" lines
// with a single ECS_SNAP frame. Until then, this function exists so
// gameplay code can already start writing against the Entity surface.

type Snapshot struct {
	Tick     int64             `json:"tick"`
	Entities []EntitySnapshot  `json:"entities"`
}

type EntitySnapshot struct {
	ID        EntityID       `json:"id"`
	Kind      string         `json:"kind"`
	Name      string         `json:"name,omitempty"`
	Position  *PositionSnap  `json:"pos,omitempty"`
	Health    *HealthSnap    `json:"health,omitempty"`
	Combat    *CombatSnap    `json:"combat,omitempty"`
	AI        *AISnap        `json:"ai,omitempty"`
	Inventory *InventorySnap `json:"inv,omitempty"`
}

// Component snapshots. Each field carries an explicit JSON tag so the
// wire shape never drifts when fields get reordered.

type PositionSnap struct {
	X     int `json:"x"`
	Y     int `json:"y"`
	FaceX int `json:"fx"`
	FaceY int `json:"fy"`
}

type HealthSnap struct {
	HP    int `json:"hp"`
	MaxHP int `json:"maxHp"`
	MP    int `json:"mp"`
	MaxMP int `json:"maxMp"`
}

type CombatSnap struct {
	Damage int     `json:"dmg"`
	Range  float64 `json:"range"`
}

type AISnap struct {
	Kind   string   `json:"kind"`
	State  string   `json:"state"`
	Target EntityID `json:"target,omitempty"`
}

type InventorySnap struct {
	Items    []ItemRef `json:"items"`
	Capacity int       `json:"cap"`
}

// SnapshotAt produces a network-ready view of the entire world. The
// `tick` argument is the gameplay tick number — the client uses it
// for ordering / drop detection once the wire format adopts ECS_SNAP.
func (w *ECSWorld) SnapshotAt(tick int64) Snapshot {
	w.mu.RLock()
	defer w.mu.RUnlock()
	snap := Snapshot{Tick: tick, Entities: make([]EntitySnapshot, 0, len(w.entities))}
	for _, e := range w.entities {
		snap.Entities = append(snap.Entities, e.Snapshot())
	}
	return snap
}

// Snapshot produces a single-entity view. Components that are nil are
// omitted entirely — the JSON stays compact and the receiver can rely
// on "field present" implying "component exists".
func (e *Entity) Snapshot() EntitySnapshot {
	out := EntitySnapshot{ID: e.ID, Kind: e.Kind, Name: e.Name}
	if e.Position != nil {
		out.Position = &PositionSnap{
			X: e.Position.X, Y: e.Position.Y,
			FaceX: e.Position.FaceX, FaceY: e.Position.FaceY,
		}
	}
	if e.Health != nil {
		out.Health = &HealthSnap{
			HP: e.Health.HP, MaxHP: e.Health.MaxHP,
			MP: e.Health.MP, MaxMP: e.Health.MaxMP,
		}
	}
	if e.Combat != nil {
		out.Combat = &CombatSnap{Damage: e.Combat.Damage, Range: e.Combat.Range}
	}
	if e.AI != nil {
		out.AI = &AISnap{Kind: e.AI.Kind, State: e.AI.State, Target: e.AI.Target}
	}
	if e.Inventory != nil {
		out.Inventory = &InventorySnap{
			Items:    append([]ItemRef(nil), e.Inventory.Items...),
			Capacity: e.Inventory.Capacity,
		}
	}
	return out
}
