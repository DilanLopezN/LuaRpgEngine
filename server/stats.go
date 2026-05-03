package main

import (
	"fmt"
	"strings"
)

// Phase 4 — Stats & progression.
//
// CStats lives next to CHealth on the entity but holds the character
// sheet (level, xp, primary attributes). The Player struct keeps a
// pointer-friendly mirror so the existing per-tick code stays readable;
// syncECS pushes the values across.
//
// Progression rules (xp-per-level curve, attribute gains per level) are
// authored in data/scripts/progression.lua so designers tune the
// economy without recompiling.

const (
	statMaxLevel    = 100
	statBaseHP      = 100
	statBasePerVit  = 10
	statBasePerInt  = 5  // mana per int point
	statBaseMaxMP   = 50
	statAtkPerStr   = 1
	statDefPerVit   = 1
	statSkillPerLvl = 1
)

// ProgressionDef is the data-driven knobset for level scaling. Loaded
// from data/scripts/progression.lua at boot and on /reload progression.
type ProgressionDef struct {
	XPBase     int     // xp required for level 1 → 2
	XPCurve    float64 // exponent on level for xp-to-next
	HPPerLevel int     // bonus max HP added each level
	MPPerLevel int     // bonus max MP added each level
	StrPerLvl  int     // attribute gain per level
	DexPerLvl  int
	IntPerLvl  int
	VitPerLvl  int
}

// defaultProgression is what's used until progression.lua is loaded.
// Keeping the struct here means tests do not need the script directory.
func defaultProgression() *ProgressionDef {
	return &ProgressionDef{
		XPBase: 100, XPCurve: 1.5,
		HPPerLevel: 5, MPPerLevel: 2,
		StrPerLvl: 1, DexPerLvl: 1, IntPerLvl: 1, VitPerLvl: 1,
	}
}

// parseProgressionDef turns a Lua table into a ProgressionDef. Missing
// fields fall back to the defaults so a partial file is not fatal.
func parseProgressionDef(raw interface{}) *ProgressionDef {
	pd := defaultProgression()
	m := asMap(raw)
	if m == nil {
		return pd
	}
	if v := asInt(m["xp_base"]); v > 0 {
		pd.XPBase = v
	}
	if v := asFloat(m["xp_curve"]); v > 0 {
		pd.XPCurve = v
	}
	if v, ok := m["hp_per_level"]; ok {
		pd.HPPerLevel = asInt(v)
	}
	if v, ok := m["mp_per_level"]; ok {
		pd.MPPerLevel = asInt(v)
	}
	if v, ok := m["str_per_level"]; ok {
		pd.StrPerLvl = asInt(v)
	}
	if v, ok := m["dex_per_level"]; ok {
		pd.DexPerLvl = asInt(v)
	}
	if v, ok := m["int_per_level"]; ok {
		pd.IntPerLvl = asInt(v)
	}
	if v, ok := m["vit_per_level"]; ok {
		pd.VitPerLvl = asInt(v)
	}
	return pd
}

// CStats is the character sheet. Damage reads Str, mana reads Int,
// max-HP reads Vit + level. Skill scaling reuses the same field names.
type CStats struct {
	Level int
	XP    int
	NextX int

	Str, Dex, Int, Vit int
}

// xpForLevel returns how much XP (cumulative from previous level) is
// required to reach `level + 1`. Level 1 → 2 costs XPBase.
func (pd *ProgressionDef) xpForLevel(level int) int {
	if level <= 0 {
		level = 1
	}
	if level >= statMaxLevel {
		return 1<<30 - 1
	}
	x := float64(pd.XPBase)
	for i := 1; i < level; i++ {
		x *= pd.XPCurve
	}
	return int(x)
}

// awardXP grants xp to a player and rolls level-ups while the threshold
// is exceeded. Returns the number of levels gained. Caller must hold
// g.mu.
func (g *Game) awardXP(p *Player, amount int) int {
	if amount <= 0 || p.Stats == nil {
		return 0
	}
	pd := g.progression
	if pd == nil {
		pd = defaultProgression()
	}
	st := p.Stats
	st.XP += amount
	gained := 0
	for st.Level < statMaxLevel && st.NextX > 0 && st.XP >= st.NextX {
		st.XP -= st.NextX
		st.Level++
		st.Str += pd.StrPerLvl
		st.Dex += pd.DexPerLvl
		st.Int += pd.IntPerLvl
		st.Vit += pd.VitPerLvl
		p.MaxHP += pd.HPPerLevel
		p.MaxMP += pd.MPPerLevel
		p.SkillPoints += statSkillPerLvl
		st.NextX = pd.xpForLevel(st.Level)
		gained++
	}
	if gained > 0 {
		p.HP = p.MaxHP
		p.MP = p.MaxMP
		// Level-objective hook: bump every quest watching for the
		// new level. Wire frames are sent best-effort so a wedged
		// peer doesn't block awardXP.
		for _, w := range g.trackLevelForQuests(p) {
			select {
			case p.Out <- w:
			default:
			}
		}
	}
	return gained
}

// derivedAttack returns the damage bonus from Str + equipped weapon.
// Caller must hold g.mu.
func (g *Game) derivedAttack(p *Player) int {
	bonus := 0
	if p.Stats != nil {
		bonus += p.Stats.Str * statAtkPerStr
	}
	bonus += equippedAttr(p, "atk")
	return bonus
}

// derivedDefense is symmetric to derivedAttack but for incoming damage.
func (g *Game) derivedDefense(p *Player) int {
	bonus := 0
	if p.Stats != nil {
		bonus += p.Stats.Vit * statDefPerVit
	}
	bonus += equippedAttr(p, "def")
	return bonus
}

// equippedAttr sums an attribute across every equipped slot. Lookups
// hit the script registry so live-edited items update on reload.
func equippedAttr(p *Player, key string) int {
	if p.Equipped == nil {
		return 0
	}
	total := 0
	for _, ref := range p.Equipped {
		def := equippedItemDef(ref.ID)
		if def == nil {
			continue
		}
		if v, ok := def.Attrs[key]; ok {
			total += v
		}
	}
	return total
}

// equippedItemDef is a tiny indirection so unit tests (no ScriptEngine)
// can override the lookup if needed. Today it just walks the global.
var equippedItemDef = func(id string) *ItemDef {
	if globalScripts == nil {
		return nil
	}
	def, _ := globalScripts.Item(id)
	return def
}

// applyStatScaling multiplies a base value by the relevant attribute
// scaling — used by skill cast paths so authored scaling = { str=1.2 }
// actually pulls Str off the caster.
func applyStatScaling(base int, scaling map[string]float64, st *CStats) int {
	if base <= 0 || st == nil || len(scaling) == 0 {
		return base
	}
	out := float64(base)
	for k, v := range scaling {
		switch strings.ToLower(k) {
		case "str":
			out += float64(st.Str) * v
		case "dex":
			out += float64(st.Dex) * v
		case "int":
			out += float64(st.Int) * v
		case "vit":
			out += float64(st.Vit) * v
		}
	}
	return int(out)
}

// characterStatsLocked is the canonical STATS frame. Caller must hold
// g.mu. The wire shape is backwards-compatible: legacy clients only
// parse the first four numbers (HP/MaxHP/MP/MaxMP); newer clients
// consume the trailing fields.
func characterStatsLocked(p *Player) string {
	level, xp, next := 1, 0, 0
	str, dex, intel, vit := 0, 0, 0, 0
	if p.Stats != nil {
		level = p.Stats.Level
		xp = p.Stats.XP
		next = p.Stats.NextX
		str, dex, intel, vit = p.Stats.Str, p.Stats.Dex, p.Stats.Int, p.Stats.Vit
	}
	gold := p.Gold
	return fmt.Sprintf("STATS %d %d %d %d %d %d %d %d %d %d %d %d\n",
		p.HP, p.MaxHP, p.MP, p.MaxMP,
		level, xp, next,
		str, dex, intel, vit,
		gold)
}
