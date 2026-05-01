package main

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

// Phase 2.5 — Skills (data + types + tree).
//
// Skills are *global* abilities loaded from data/scripts/skills/*.lua.
// They differ from the per-player Spell editor (Phase 1.5): a Skill is
// authored once by the developer, learned via the skill tree, and
// validated entirely on the server. The Lua file is data-only — no
// runtime callbacks. Behaviour comes from the `effects` DSL and the
// dispatcher in this file, which keeps gameplay logic in Go where it
// can be tested cheaply while still letting designers tune values
// without recompiling.

const (
	skillMaxRange    = 32
	skillMaxRadius   = 12
	skillMaxValue    = 100000
	skillMinCooldown = 50 * time.Millisecond
	skillMaxCooldown = 5 * time.Minute

	statusMaxDuration = 60 * time.Second
	statusTickEvery   = 500 * time.Millisecond
)

// Allowed skill types. The dispatcher (resolveSkill) refuses anything
// outside this set during load — a typo in a Lua file is an error,
// not a silent no-op.
var skillTypes = map[string]bool{
	"melee":      true,
	"projectile": true,
	"area":       true,
	"heal":       true,
	"buff":       true,
	"debuff":     true,
}

// Allowed effect operators. Same rationale — typos must be caught.
var effectOps = map[string]bool{
	"damage":       true,
	"heal":         true,
	"mana":         true,
	"apply_status": true,
}

// Skill is a data-driven ability. The pointer is shared across all
// callers; gameplay code must not mutate it.
type Skill struct {
	ID       string
	Name     string
	Type     string
	Damage   int
	ManaCost int
	Cooldown time.Duration
	Range    int
	Radius   int
	Scaling  map[string]float64
	Effects  []SkillEffect
}

// SkillEffect is one entry of the effects DSL. Only fields relevant to
// the operator are read; the others are zero. Keeping them flat (vs a
// sealed sum type) makes Lua-side authoring trivial — designers don't
// have to remember which subtype goes where.
type SkillEffect struct {
	Type     string  // "damage" | "heal" | "mana" | "apply_status"
	Value    int     // for damage/heal/mana
	Scale    float64 // optional: extra multiplier on Value
	Status   string  // for apply_status
	Duration int     // ms
	Power    int     // tick magnitude for apply_status
}

// SkillTreeNode represents a single node in data/scripts/skills/tree.lua.
// Requires are the IDs of skills that must already be learned before
// this skill can be unlocked. Cost is in skill points.
type SkillTreeNode struct {
	ID       string
	Requires []string
	Cost     int
}

// Status is an active timed effect on a Player or Enemy. Statuses are
// stored on the entity itself; the game tick advances and expires them.
type Status struct {
	Name      string
	Power     int
	ExpiresAt time.Time
	NextTick  time.Time
	Interval  time.Duration
	Source    int // caster entity ID, for damage attribution
}

// parseSkill converts a Lua-loaded definition into a Skill, applying
// the same value clamps the live-edit Spell pipeline uses so designers
// can't accidentally ship a 1-tick-cooldown nuke.
func parseSkill(raw interface{}, fallbackID string) (*Skill, error) {
	m := asMap(raw)
	if m == nil {
		return nil, errors.New("skill must be a table")
	}
	id := asString(m["id"])
	if id == "" {
		id = fallbackID
	}
	typ := asString(m["type"])
	if !skillTypes[typ] {
		return nil, fmt.Errorf("unknown skill type %q", typ)
	}
	cd := time.Duration(asFloat(m["cooldown"])*1000) * time.Millisecond
	if cd < skillMinCooldown {
		cd = skillMinCooldown
	}
	if cd > skillMaxCooldown {
		cd = skillMaxCooldown
	}

	scaling := map[string]float64{}
	for k, v := range asMap(m["scaling"]) {
		scaling[k] = asFloat(v)
	}

	effects, err := parseEffects(m["effects"])
	if err != nil {
		return nil, err
	}

	name := asString(m["name"])
	if name == "" {
		name = id
	}

	return &Skill{
		ID:       id,
		Name:     name,
		Type:     typ,
		Damage:   clampInt(asInt(m["damage"]), 0, skillMaxValue),
		ManaCost: clampInt(asInt(m["mana_cost"]), 0, skillMaxValue),
		Cooldown: cd,
		Range:    clampInt(asInt(m["range"]), 0, skillMaxRange),
		Radius:   clampInt(asInt(m["radius"]), 0, skillMaxRadius),
		Scaling:  scaling,
		Effects:  effects,
	}, nil
}

func parseEffects(raw interface{}) ([]SkillEffect, error) {
	if raw == nil {
		return nil, nil
	}
	list := asSlice(raw)
	if list == nil {
		return nil, errors.New("effects must be an array")
	}
	out := make([]SkillEffect, 0, len(list))
	for i, item := range list {
		em := asMap(item)
		if em == nil {
			return nil, fmt.Errorf("effect %d: not a table", i)
		}
		op := asString(em["type"])
		if !effectOps[op] {
			return nil, fmt.Errorf("effect %d: unknown type %q", i, op)
		}
		dur := clampInt(asInt(em["duration"]), 0, int(statusMaxDuration/time.Millisecond))
		// Tolerate authors writing duration in seconds (the example in
		// the roadmap does). If it looks like seconds, scale up.
		if rawDur, ok := em["duration"].(float64); ok && rawDur > 0 && rawDur < 60 {
			dur = int(rawDur * 1000)
		}
		out = append(out, SkillEffect{
			Type:     op,
			Value:    clampInt(asInt(em["value"]), 0, skillMaxValue),
			Scale:    asFloat(em["scale"]),
			Status:   asString(em["status"]),
			Duration: dur,
			Power:    clampInt(asInt(em["power"]), 0, skillMaxValue),
		})
	}
	return out, nil
}

func parseEnemyDef(raw interface{}, fallbackID string) (*EnemyDef, error) {
	m := asMap(raw)
	if m == nil {
		return nil, errors.New("enemy must be a table")
	}
	id := asString(m["id"])
	if id == "" {
		id = fallbackID
	}
	hp := asInt(m["hp"])
	if hp <= 0 {
		hp = 30
	}
	speed := asFloat(m["speed"])
	if speed <= 0 {
		speed = 1
	}
	name := asString(m["name"])
	if name == "" {
		name = id
	}
	return &EnemyDef{ID: id, Name: name, HP: hp, Speed: speed}, nil
}

// parseSkillTree fills `out` from a table of the form
//
//	{ fireball = { requires = {}, cost = 1 }, ... }
//
// Unknown skill IDs are *not* an error here — the tree may legitimately
// reference skills that haven't been authored yet. The learn flow is
// the place where we reject invalid IDs.
func parseSkillTree(raw interface{}, out map[string]*SkillTreeNode) {
	m := asMap(raw)
	if m == nil {
		return
	}
	for id, val := range m {
		nm := asMap(val)
		node := &SkillTreeNode{ID: id, Cost: 1}
		if nm != nil {
			node.Cost = asInt(nm["cost"])
			if node.Cost < 0 {
				node.Cost = 0
			}
			if reqs := asSlice(nm["requires"]); reqs != nil {
				for _, r := range reqs {
					if s := asString(r); s != "" {
						node.Requires = append(node.Requires, s)
					}
				}
			}
		}
		out[id] = node
	}
}

// formatSkillDef renders a Skill for the wire so the client can show
// names, costs, and metadata in a UI without needing the Lua source.
// The format mirrors formatSpellDef so existing client code can hold
// both registries side by side.
func formatSkillDef(s *Skill) string {
	return fmt.Sprintf("SKILL_DEF %s %s %d %d %d %d %d %s\n",
		s.ID, s.Type,
		s.Damage, s.ManaCost,
		int(s.Cooldown/time.Millisecond),
		s.Range, s.Radius,
		strings.ReplaceAll(s.Name, " ", "_"))
}
