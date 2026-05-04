package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"

	lua "github.com/yuin/gopher-lua"
)

// Phase 2 — Scripting (Lua server-side).
//
// The engine loads content definitions and game hooks from
//
//	server/data/scripts/
//	  enemies/
//	  skills/
//	  items/
//	  hooks/
//
// Files are sandboxed: `os`, `io`, `debug`, and `package` are not
// available, dangerous base functions are stripped, and every script
// invocation is bounded by a context with a timeout. A faulty script
// logs an error and is skipped — it never panics the server.

const (
	// scriptLoadTimeout caps how long a single .lua file is allowed to
	// run during load. It exists so a runaway require loop or accidental
	// `while true do end` cannot wedge the server.
	scriptLoadTimeout = 2 * time.Second
	// scriptHookTimeout bounds a single hook invocation triggered by
	// gameplay events.
	scriptHookTimeout = 50 * time.Millisecond
	// scriptRegistryMax limits the size of each VM's registry table to
	// keep buggy scripts from allocating unbounded memory.
	scriptRegistryMax = 1024 * 1024
)

// ScriptHost is the surface the Lua API can call back into. The Game
// implements it. Anything outside this interface is unreachable from
// scripts.
type ScriptHost interface {
	BroadcastSystem(msg string)
	SpawnEnemy(kind string, x, y int) int
	DamageEntity(id, amount int) bool
	FindEntitiesInRange(x, y, radius int) []int
	GetPlayerInfo(name string) (id, x, y, hp int, ok bool)
	ApplyStatus(targetID int, status string, durationMs int, power int)
	ScheduleEvent(name string, delayMs int, payload string)
	// Phase 4 — inventory + progression hooks reachable from Lua.
	DropItem(killerID int, itemID string, qty, chance int) bool
	GiveItem(playerID int, itemID string, qty int) int
	GiveXP(playerID int, amount int) int
	GiveGold(playerID int, amount int) int
}

// globalScripts is the singleton view used by helpers that don't have
// a Game pointer (item lookups in stats.go, etc.). It's set by NewGame
// once the engine has loaded.
var globalScripts *ScriptEngine

// ScriptEngine owns the data-driven content loaded from disk and the
// long-lived sandboxed VM that executes hook callbacks.
type ScriptEngine struct {
	mu      sync.Mutex
	 vmMu    sync.Mutex  
	rootDir string
	host    ScriptHost

	skills      map[string]*Skill
	tree        map[string]*SkillTreeNode
	enemies     map[string]*EnemyDef
	items       map[string]*ItemDef
	npcs        map[string]*NPCDef
	quests      map[string]*QuestDef
	progression *ProgressionDef

	// hooksVM holds parsed hook callbacks keyed by event name. It lives
	// across the server's lifetime and is rebuilt on /reload hooks.
	hooksVM *lua.LState
	hooks   map[string]*lua.LFunction
}

// EnemyDef is a data-driven enemy template loaded from
// data/scripts/enemies/<id>.lua.
type EnemyDef struct {
	ID     string
	Name   string
	HP     int
	Speed  float64
	XP     int // award on kill (Phase 4)
	Damage int // contact damage tick (Phase 4 AI)
}

// NewScriptEngine returns an engine rooted at data/scripts/. It does
// not load anything; call LoadAll once a host is wired.
func NewScriptEngine(root string) *ScriptEngine {
	return &ScriptEngine{
		rootDir:     root,
		skills:      make(map[string]*Skill),
		tree:        make(map[string]*SkillTreeNode),
		enemies:     make(map[string]*EnemyDef),
		items:       make(map[string]*ItemDef),
		npcs:        make(map[string]*NPCDef),
		quests:      make(map[string]*QuestDef),
		progression: defaultProgression(),
		hooks:       make(map[string]*lua.LFunction),
	}
}

// SetHost wires the gameplay surface. It is safe to call before LoadAll;
// changing the host after scripts are loaded is a no-op for already
// captured upvalues but applies to subsequent invocations.
func (e *ScriptEngine) SetHost(h ScriptHost) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.host = h
}

// LoadAll reloads every domain. Errors are logged but never returned —
// the server keeps running with whatever loaded successfully.
func (e *ScriptEngine) LoadAll() {
	for _, d := range []string{"skills", "enemies", "items", "npcs", "quests", "progression", "hooks"} {
		if err := e.LoadDomain(d); err != nil {
			log.Printf("scripts: load %s: %v", d, err)
		}
	}
}

// LoadDomain reloads a single bucket. Use "all" to reload everything.
func (e *ScriptEngine) LoadDomain(domain string) error {
	switch domain {
	case "all":
		e.LoadAll()
		return nil
	case "skills":
		return e.loadSkills()
	case "enemies":
		return e.loadEnemies()
	case "items":
		return e.loadItems()
	case "npcs":
		return e.loadNPCs()
	case "quests":
		return e.loadQuests()
	case "progression":
		return e.loadProgression()
	case "hooks":
		return e.loadHooks()
	}
	return fmt.Errorf("unknown script domain %q", domain)
}

// Skills returns a snapshot of the registry. The caller must not
// mutate the returned pointers.
func (e *ScriptEngine) Skills() map[string]*Skill {
	e.mu.Lock()
	defer e.mu.Unlock()
	out := make(map[string]*Skill, len(e.skills))
	for k, v := range e.skills {
		out[k] = v
	}
	return out
}

func (e *ScriptEngine) Skill(id string) (*Skill, bool) {
	e.mu.Lock()
	defer e.mu.Unlock()
	s, ok := e.skills[id]
	return s, ok
}

func (e *ScriptEngine) Tree() map[string]*SkillTreeNode {
	e.mu.Lock()
	defer e.mu.Unlock()
	out := make(map[string]*SkillTreeNode, len(e.tree))
	for k, v := range e.tree {
		out[k] = v
	}
	return out
}

func (e *ScriptEngine) Enemy(id string) (*EnemyDef, bool) {
	e.mu.Lock()
	defer e.mu.Unlock()
	d, ok := e.enemies[id]
	return d, ok
}

func (e *ScriptEngine) Item(id string) (*ItemDef, bool) {
	e.mu.Lock()
	defer e.mu.Unlock()
	d, ok := e.items[id]
	return d, ok
}

func (e *ScriptEngine) Items() map[string]*ItemDef {
	e.mu.Lock()
	defer e.mu.Unlock()
	out := make(map[string]*ItemDef, len(e.items))
	for k, v := range e.items {
		out[k] = v
	}
	return out
}

func (e *ScriptEngine) NPC(id string) (*NPCDef, bool) {
	e.mu.Lock()
	defer e.mu.Unlock()
	d, ok := e.npcs[id]
	return d, ok
}

// RootDir exposes the scripts directory so callers (handlers writing
// user-authored NPCs) can compose paths without re-deriving the root.
func (e *ScriptEngine) RootDir() string {
	return e.rootDir
}

// SaveUserNPC persists def to data/scripts/npcs_user/<id>.json AND
// updates the in-memory registry so the next snapshot tick sees the
// new behaviour without forcing a /reload. Hostile NPCs also re-enter
// the enemy registry. Returns the resolved id (sanitised) and any
// write error.
func (e *ScriptEngine) SaveUserNPC(def *NPCDef) error {
	if err := SaveUserNPCDef(e.rootDir, def); err != nil {
		return err
	}
	e.mu.Lock()
	e.npcs[def.ID] = def
	if def.IsHostile() {
		e.enemies[def.ID] = npcDefToEnemyDef(def)
	} else {
		delete(e.enemies, def.ID)
	}
	e.mu.Unlock()
	return nil
}

// DeleteUserNPC removes the JSON file AND drops the def from the live
// registry. After this returns, NPC lookups for the id miss as if the
// file had never existed.
func (e *ScriptEngine) DeleteUserNPC(id string) error {
	if err := DeleteUserNPCDef(e.rootDir, id); err != nil {
		return err
	}
	e.mu.Lock()
	delete(e.npcs, id)
	delete(e.enemies, id)
	e.mu.Unlock()
	return nil
}

func (e *ScriptEngine) NPCs() map[string]*NPCDef {
	e.mu.Lock()
	defer e.mu.Unlock()
	out := make(map[string]*NPCDef, len(e.npcs))
	for k, v := range e.npcs {
		out[k] = v
	}
	return out
}

func (e *ScriptEngine) Quest(id string) (*QuestDef, bool) {
	e.mu.Lock()
	defer e.mu.Unlock()
	d, ok := e.quests[id]
	return d, ok
}

func (e *ScriptEngine) Quests() map[string]*QuestDef {
	e.mu.Lock()
	defer e.mu.Unlock()
	out := make(map[string]*QuestDef, len(e.quests))
	for k, v := range e.quests {
		out[k] = v
	}
	return out
}

func (e *ScriptEngine) Progression() *ProgressionDef {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.progression == nil {
		return defaultProgression()
	}
	cp := *e.progression
	return &cp
}

// FireHook invokes the hook function registered under name with a
// single Lua table built from args. Missing hooks are a no-op so
// gameplay code can call FireHook unconditionally.
//
// Concurrency contract (see roadmap §🔒):
//   - Callers MUST NOT hold Game.mu when invoking FireHook. The hook
//     body can call host-exposed APIs (damage_entity, give_item, ...)
//     that themselves acquire Game.mu — re-entering it from inside
//     the lock deadlocks the world.
//   - The implementation only takes ScriptEngine.mu briefly to look
//     up the registered function, then drops it before grabbing
//     vmMu. The two locks never overlap.
//   - vmMu is the serialiser of the shared hooks VM; it is never
//     held across host callbacks (gopher-lua reentry into Go runs
//     synchronously from inside PCall, but those Go callbacks each
//     acquire their own locks and never reach vmMu).
//
// If you find a callsite that needs to fire a hook while inside the
// tick loop, dispatch via `go FireHook(...)` — the AI tick already
// does this for player_join via bindName.
func (e *ScriptEngine) FireHook(name string, args map[string]interface{}) {
    e.mu.Lock()
    fn := e.hooks[name]
    L := e.hooksVM
    e.mu.Unlock()
    if fn == nil || L == nil {
        return
    }

    ctx, cancel := context.WithTimeout(context.Background(), scriptHookTimeout)
    defer cancel()

    e.vmMu.Lock()
    defer e.vmMu.Unlock()

    L.SetContext(ctx)
    defer L.RemoveContext()

    tbl := L.NewTable()
    for k, v := range args {
        tbl.RawSetString(k, goToLua(L, v))
    }
    L.Push(fn)
    L.Push(tbl)
    if err := L.PCall(1, 0, nil); err != nil {
        log.Printf("scripts: hook %s: %v", name, err)
    }
}
// --- domain loaders ---------------------------------------------------------

func (e *ScriptEngine) loadSkills() error {
	dir := filepath.Join(e.rootDir, "skills")
	files, err := listLuaFiles(dir)
	if err != nil {
		return err
	}
	skills := make(map[string]*Skill)
	tree := make(map[string]*SkillTreeNode)
	for _, f := range files {
		base := strings.TrimSuffix(filepath.Base(f), ".lua")
		val, err := evalScript(f)
		if err != nil {
			log.Printf("scripts: skill %s: %v", base, err)
			continue
		}
		if base == "tree" {
			parseSkillTree(val, tree)
			continue
		}
		sk, err := parseSkill(val, base)
		if err != nil {
			log.Printf("scripts: skill %s invalid: %v", base, err)
			continue
		}
		skills[sk.ID] = sk
	}
	// Phase 2.5 hardening: refuse cyclic prerequisites at load time so
	// a designer's typo surfaces in the boot log instead of silently
	// breaking learn flow at runtime.
	if err := validateSkillTree(tree); err != nil {
		log.Printf("scripts: skill tree invalid: %v", err)
		return err
	}
	e.mu.Lock()
	e.skills = skills
	e.tree = tree
	e.mu.Unlock()
	log.Printf("scripts: loaded %d skills, %d tree nodes", len(skills), len(tree))
	return nil
}

func (e *ScriptEngine) loadEnemies() error {
	dir := filepath.Join(e.rootDir, "enemies")
	files, err := listLuaFiles(dir)
	if err != nil {
		return err
	}
	enemies := make(map[string]*EnemyDef)
	for _, f := range files {
		base := strings.TrimSuffix(filepath.Base(f), ".lua")
		val, err := evalScript(f)
		if err != nil {
			log.Printf("scripts: enemy %s: %v", base, err)
			continue
		}
		def, err := parseEnemyDef(val, base)
		if err != nil {
			log.Printf("scripts: enemy %s invalid: %v", base, err)
			continue
		}
		enemies[def.ID] = def
	}
	e.mu.Lock()
	e.enemies = enemies
	e.mu.Unlock()
	log.Printf("scripts: loaded %d enemy defs", len(enemies))
	return nil
}

func (e *ScriptEngine) loadItems() error {
	dir := filepath.Join(e.rootDir, "items")
	files, err := listLuaFiles(dir)
	if err != nil {
		return err
	}
	items := make(map[string]*ItemDef)
	for _, f := range files {
		base := strings.TrimSuffix(filepath.Base(f), ".lua")
		val, err := evalScript(f)
		if err != nil {
			log.Printf("scripts: item %s: %v", base, err)
			continue
		}
		def, err := parseItemDef(val, base)
		if err != nil {
			log.Printf("scripts: item %s invalid: %v", base, err)
			continue
		}
		items[def.ID] = def
	}
	// User-authored JSON items, mirroring the npcs_user/quests_user
	// flow. The editor writes here; reload picks them up. Same id
	// from both surfaces: the user file wins so the editor can
	// override a stock item without touching the canonical Lua.
	jsonFiles, err := listUserItemFiles(e.rootDir)
	if err != nil {
		log.Printf("scripts: items_user: %v", err)
	}
	for _, f := range jsonFiles {
		def, err := LoadUserItemJSON(f)
		if err != nil {
			log.Printf("scripts: user item %s: %v", filepath.Base(f), err)
			continue
		}
		items[def.ID] = def
	}
	e.mu.Lock()
	e.items = items
	e.mu.Unlock()
	log.Printf("scripts: loaded %d items (%d user)", len(items), len(jsonFiles))
	return nil
}

// SaveUserItem persists def to data/scripts/items_user/<id>.json AND
// updates the in-memory registry so the next snapshot reflects the new
// definition without forcing a /reload.
func (e *ScriptEngine) SaveUserItem(def *ItemDef) error {
	if err := SaveUserItemDef(e.rootDir, def); err != nil {
		return err
	}
	e.mu.Lock()
	e.items[def.ID] = def
	e.mu.Unlock()
	return nil
}

// DeleteUserItem removes the JSON file AND drops the def from the live
// registry.
func (e *ScriptEngine) DeleteUserItem(id string) error {
	if err := DeleteUserItemDef(e.rootDir, id); err != nil {
		return err
	}
	e.mu.Lock()
	delete(e.items, id)
	e.mu.Unlock()
	return nil
}

func (e *ScriptEngine) loadNPCs() error {
	dir := filepath.Join(e.rootDir, "npcs")
	files, err := listLuaFiles(dir)
	if err != nil {
		return err
	}
	npcs := make(map[string]*NPCDef)
	for _, f := range files {
		base := strings.TrimSuffix(filepath.Base(f), ".lua")
		val, err := evalScript(f)
		if err != nil {
			log.Printf("scripts: npc %s: %v", base, err)
			continue
		}
		def, err := parseNPCDef(val, base)
		if err != nil {
			log.Printf("scripts: npc %s invalid: %v", base, err)
			continue
		}
		npcs[def.ID] = def
	}
	// User-authored JSON NPCs (data/scripts/npcs_user/) sit alongside the
	// canonical Lua bucket. The editor writes here, so reloading picks
	// up the freshly-saved content immediately. If both surfaces define
	// the same id, the user file wins so live edits are not blocked
	// by a Lua file with the same name.
	jsonFiles, err := listUserNPCFiles(e.rootDir)
	if err != nil {
		log.Printf("scripts: npcs_user: %v", err)
	}
	for _, f := range jsonFiles {
		def, err := LoadUserNPCJSON(f)
		if err != nil {
			log.Printf("scripts: user npc %s: %v", filepath.Base(f), err)
			continue
		}
		npcs[def.ID] = def
	}
	e.mu.Lock()
	e.npcs = npcs
	// Promote hostile NPCs into the enemy registry so spawnEnemy can
	// look them up by ID without the gameplay layer needing to know
	// whether the kind came from data/scripts/enemies/ or from an
	// authored NPC. The synthetic def is regenerated on every reload
	// so live edits to HP/Damage/Speed land without a server restart.
	for id, def := range npcs {
		if !def.IsHostile() {
			delete(e.enemies, id)
			continue
		}
		e.enemies[id] = npcDefToEnemyDef(def)
	}
	e.mu.Unlock()
	log.Printf("scripts: loaded %d npcs (%d user)", len(npcs), len(jsonFiles))
	return nil
}

// npcDefToEnemyDef projects an NPCDef onto the EnemyDef shape so a
// hostile NPC fights with the existing enemy AI code path. HP/Damage
// fall back to sane defaults so the editor doesn't have to remember
// to fill them in for every guardian.
func npcDefToEnemyDef(def *NPCDef) *EnemyDef {
	hp := def.HP
	if hp <= 0 {
		hp = 30
	}
	dmg := def.Damage
	if dmg <= 0 {
		dmg = 5
	}
	sp := def.Speed
	if sp <= 0 {
		sp = 1
	}
	return &EnemyDef{
		ID:     def.ID,
		Name:   def.Name,
		HP:     hp,
		Speed:  sp,
		XP:     def.XP,
		Damage: dmg,
	}
}

func (e *ScriptEngine) loadQuests() error {
	dir := filepath.Join(e.rootDir, "quests")
	files, err := listLuaFiles(dir)
	if err != nil {
		return err
	}
	quests := make(map[string]*QuestDef)
	for _, f := range files {
		base := strings.TrimSuffix(filepath.Base(f), ".lua")
		val, err := evalScript(f)
		if err != nil {
			log.Printf("scripts: quest %s: %v", base, err)
			continue
		}
		def, err := parseQuestDef(val, base)
		if err != nil {
			log.Printf("scripts: quest %s invalid: %v", base, err)
			continue
		}
		quests[def.ID] = def
	}
	// User-authored JSON quests, mirroring the npcs_user/ flow. Editor
	// writes here; reload picks them up. Same id from both surfaces:
	// the user file wins so the editor can override a stock quest.
	jsonFiles, err := listUserQuestFiles(e.rootDir)
	if err != nil {
		log.Printf("scripts: quests_user: %v", err)
	}
	for _, f := range jsonFiles {
		def, err := LoadUserQuestJSON(f)
		if err != nil {
			log.Printf("scripts: user quest %s: %v", filepath.Base(f), err)
			continue
		}
		quests[def.ID] = def
	}
	e.mu.Lock()
	e.quests = quests
	e.mu.Unlock()
	log.Printf("scripts: loaded %d quests (%d user)", len(quests), len(jsonFiles))
	return nil
}

// SaveUserQuest persists a quest to data/scripts/quests_user/<id>.json
// AND updates the live registry so the next snapshot reflects the new
// definition without forcing a /reload.
func (e *ScriptEngine) SaveUserQuest(def *QuestDef) error {
	if err := SaveUserQuestDef(e.rootDir, def); err != nil {
		return err
	}
	e.mu.Lock()
	e.quests[def.ID] = def
	e.mu.Unlock()
	return nil
}

// DeleteUserQuest removes the JSON file AND drops the def from the
// live registry.
func (e *ScriptEngine) DeleteUserQuest(id string) error {
	if err := DeleteUserQuestDef(e.rootDir, id); err != nil {
		return err
	}
	e.mu.Lock()
	delete(e.quests, id)
	e.mu.Unlock()
	return nil
}

func (e *ScriptEngine) loadProgression() error {
	p := filepath.Join(e.rootDir, "progression.lua")
	if _, err := os.Stat(p); err != nil {
		if errors.Is(err, os.ErrNotExist) {
			e.mu.Lock()
			e.progression = defaultProgression()
			e.mu.Unlock()
			return nil
		}
		return err
	}
	val, err := evalScript(p)
	if err != nil {
		return err
	}
	pd := parseProgressionDef(val)
	e.mu.Lock()
	e.progression = pd
	e.mu.Unlock()
	log.Printf("scripts: loaded progression (xp_base=%d curve=%.2f)", pd.XPBase, pd.XPCurve)
	return nil
}

func (e *ScriptEngine) loadHooks() error {
	dir := filepath.Join(e.rootDir, "hooks")
	files, err := listLuaFiles(dir)
	if err != nil {
		return err
	}

	// Build a fresh VM so a previous bad load can't poison the env.
	L := newSandbox()
	e.installAPI(L)
	registered := make(map[string]*lua.LFunction)

	registerFn := func(name string, fn *lua.LFunction) {
		registered[name] = fn
	}
	L.SetGlobal("on", L.NewFunction(func(L *lua.LState) int {
		name := L.CheckString(1)
		fn := L.CheckFunction(2)
		registerFn(name, fn)
		return 0
	}))

	for _, f := range files {
		base := strings.TrimSuffix(filepath.Base(f), ".lua")
		ctx, cancel := context.WithTimeout(context.Background(), scriptLoadTimeout)
		L.SetContext(ctx)
		err := L.DoFile(f)
		L.RemoveContext()
		cancel()
		if err != nil {
			log.Printf("scripts: hook file %s: %v", base, err)
			continue
		}
	}

	e.mu.Lock()
	if e.hooksVM != nil {
		e.hooksVM.Close()
	}
	e.hooksVM = L
	e.hooks = registered
	e.mu.Unlock()
	log.Printf("scripts: loaded %d hooks", len(registered))
	return nil
}

// --- sandbox + script execution -------------------------------------------

func newSandbox() *lua.LState {
	L := lua.NewState(lua.Options{
		SkipOpenLibs:        true,
		IncludeGoStackTrace: false,
		RegistrySize:        scriptRegistryMax,
	})
	// Open only the safe libraries. `os`, `io`, `debug`, and the
	// loader/package machinery stay closed so scripts cannot touch
	// the filesystem, the network, or hook into the runtime.
	for _, pair := range []struct {
		name string
		fn   lua.LGFunction
	}{
		{lua.BaseLibName, lua.OpenBase},
		{lua.TabLibName, lua.OpenTable},
		{lua.StringLibName, lua.OpenString},
		{lua.MathLibName, lua.OpenMath},
	} {
		L.Push(L.NewFunction(pair.fn))
		L.Push(lua.LString(pair.name))
		_ = L.PCall(1, 0, nil)
	}
	// Strip the few dangerous base functions that OpenBase brings in.
	for _, name := range []string{
		"dofile", "loadfile", "load", "loadstring",
		"collectgarbage", "_printregs", "module", "require",
	} {
		L.SetGlobal(name, lua.LNil)
	}
	return L
}

// evalScript runs a single .lua file in a fresh sandbox and returns
// the value the chunk evaluated to (the table returned by `return ...`).
// The VM is closed before returning, so the result is converted to
// plain Go values.
func evalScript(path string) (interface{}, error) {
	if _, err := os.Stat(path); err != nil {
		return nil, err
	}
	L := newSandbox()
	defer L.Close()

	ctx, cancel := context.WithTimeout(context.Background(), scriptLoadTimeout)
	defer cancel()
	L.SetContext(ctx)

	if err := L.DoFile(path); err != nil {
		return nil, err
	}
	if L.GetTop() == 0 {
		return nil, errors.New("script did not return a value")
	}
	v := L.Get(-1)
	return luaToGo(v, 0), nil
}

func listLuaFiles(dir string) ([]string, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil, nil
		}
		return nil, err
	}
	var files []string
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		if !strings.HasSuffix(e.Name(), ".lua") {
			continue
		}
		files = append(files, filepath.Join(dir, e.Name()))
	}
	sort.Strings(files)
	return files, nil
}

// --- Lua <-> Go conversion --------------------------------------------------

const luaConvertMaxDepth = 16

func luaToGo(v lua.LValue, depth int) interface{} {
	if depth > luaConvertMaxDepth {
		return nil
	}
	switch t := v.(type) {
	case *lua.LNilType:
		return nil
	case lua.LBool:
		return bool(t)
	case lua.LNumber:
		f := float64(t)
		if f == float64(int64(f)) {
			return int64(f)
		}
		return f
	case lua.LString:
		return string(t)
	case *lua.LTable:
		// Decide if the table is array-like (1..n integer keys) or a
		// map by sniffing the first key.
		isArray := true
		t.ForEach(func(k lua.LValue, _ lua.LValue) {
			if _, ok := k.(lua.LNumber); !ok {
				isArray = false
			}
		})
		if isArray && t.Len() > 0 {
			out := make([]interface{}, 0, t.Len())
			for i := 1; i <= t.Len(); i++ {
				out = append(out, luaToGo(t.RawGetInt(i), depth+1))
			}
			return out
		}
		out := make(map[string]interface{})
		t.ForEach(func(k lua.LValue, val lua.LValue) {
			ks, ok := k.(lua.LString)
			if !ok {
				return
			}
			out[string(ks)] = luaToGo(val, depth+1)
		})
		return out
	}
	return nil
}

func goToLua(L *lua.LState, v interface{}) lua.LValue {
	switch t := v.(type) {
	case nil:
		return lua.LNil
	case bool:
		return lua.LBool(t)
	case int:
		return lua.LNumber(t)
	case int64:
		return lua.LNumber(t)
	case float64:
		return lua.LNumber(t)
	case string:
		return lua.LString(t)
	case []interface{}:
		tbl := L.NewTable()
		for i, item := range t {
			tbl.RawSetInt(i+1, goToLua(L, item))
		}
		return tbl
	case map[string]interface{}:
		tbl := L.NewTable()
		for k, val := range t {
			tbl.RawSetString(k, goToLua(L, val))
		}
		return tbl
	}
	return lua.LNil
}

// asMap, asInt, asFloat, asString are convenience accessors used by
// the parsers below. They never panic — invalid types produce zero
// values so a malformed script reports as "missing field" rather
// than crashing the loader.
func asMap(v interface{}) map[string]interface{} {
	m, _ := v.(map[string]interface{})
	return m
}

func asSlice(v interface{}) []interface{} {
	s, _ := v.([]interface{})
	return s
}

func asString(v interface{}) string {
	switch t := v.(type) {
	case string:
		return t
	}
	return ""
}

func asInt(v interface{}) int {
	switch t := v.(type) {
	case int64:
		return int(t)
	case float64:
		return int(t)
	case int:
		return t
	}
	return 0
}

func asFloat(v interface{}) float64 {
	switch t := v.(type) {
	case int64:
		return float64(t)
	case float64:
		return t
	case int:
		return float64(t)
	}
	return 0
}

// --- Lua API surface --------------------------------------------------------

// installAPI binds the Phase 2 API onto L's globals. The functions are
// stateless wrappers that read e.host on each call so a SetHost done
// after load still takes effect.
func (e *ScriptEngine) installAPI(L *lua.LState) {
	bind := func(name string, fn lua.LGFunction) {
		L.SetGlobal(name, L.NewFunction(fn))
	}

	bind("broadcast", func(L *lua.LState) int {
		msg := L.CheckString(1)
		host := e.currentHost()
		if host != nil {
			host.BroadcastSystem(msg)
		}
		return 0
	})

	bind("spawn_entity", func(L *lua.LState) int {
		kind := L.CheckString(1)
		x := L.CheckInt(2)
		y := L.CheckInt(3)
		host := e.currentHost()
		if host == nil {
			L.Push(lua.LNil)
			return 1
		}
		id := host.SpawnEnemy(kind, x, y)
		L.Push(lua.LNumber(id))
		return 1
	})

	bind("damage_entity", func(L *lua.LState) int {
		id := L.CheckInt(1)
		amount := L.CheckInt(2)
		host := e.currentHost()
		if host == nil {
			L.Push(lua.LBool(false))
			return 1
		}
		L.Push(lua.LBool(host.DamageEntity(id, amount)))
		return 1
	})

	bind("find_entities_in_range", func(L *lua.LState) int {
		x := L.CheckInt(1)
		y := L.CheckInt(2)
		r := L.CheckInt(3)
		host := e.currentHost()
		tbl := L.NewTable()
		if host != nil {
			for i, id := range host.FindEntitiesInRange(x, y, r) {
				tbl.RawSetInt(i+1, lua.LNumber(id))
			}
		}
		L.Push(tbl)
		return 1
	})

	bind("get_player", func(L *lua.LState) int {
		name := L.CheckString(1)
		host := e.currentHost()
		if host == nil {
			L.Push(lua.LNil)
			return 1
		}
		id, x, y, hp, ok := host.GetPlayerInfo(name)
		if !ok {
			L.Push(lua.LNil)
			return 1
		}
		t := L.NewTable()
		t.RawSetString("id", lua.LNumber(id))
		t.RawSetString("x", lua.LNumber(x))
		t.RawSetString("y", lua.LNumber(y))
		t.RawSetString("hp", lua.LNumber(hp))
		t.RawSetString("name", lua.LString(name))
		L.Push(t)
		return 1
	})

	bind("apply_status", func(L *lua.LState) int {
		id := L.CheckInt(1)
		status := L.CheckString(2)
		duration := L.CheckInt(3)
		power := L.OptInt(4, 0)
		host := e.currentHost()
		if host != nil {
			host.ApplyStatus(id, status, duration, power)
		}
		return 0
	})

	bind("schedule_event", func(L *lua.LState) int {
		name := L.CheckString(1)
		delay := L.CheckInt(2)
		payload := L.OptString(3, "")
		host := e.currentHost()
		if host != nil {
			host.ScheduleEvent(name, delay, payload)
		}
		return 0
	})

	bind("drop_item", func(L *lua.LState) int {
		killer := L.CheckInt(1)
		id := L.CheckString(2)
		qty := L.OptInt(3, 1)
		chance := L.OptInt(4, 1000)
		host := e.currentHost()
		if host == nil {
			L.Push(lua.LBool(false))
			return 1
		}
		L.Push(lua.LBool(host.DropItem(killer, id, qty, chance)))
		return 1
	})

	bind("give_item", func(L *lua.LState) int {
		pid := L.CheckInt(1)
		id := L.CheckString(2)
		qty := L.OptInt(3, 1)
		host := e.currentHost()
		if host == nil {
			L.Push(lua.LNumber(0))
			return 1
		}
		L.Push(lua.LNumber(host.GiveItem(pid, id, qty)))
		return 1
	})

	bind("give_xp", func(L *lua.LState) int {
		pid := L.CheckInt(1)
		amount := L.CheckInt(2)
		host := e.currentHost()
		if host == nil {
			L.Push(lua.LNumber(0))
			return 1
		}
		L.Push(lua.LNumber(host.GiveXP(pid, amount)))
		return 1
	})

	bind("give_gold", func(L *lua.LState) int {
		pid := L.CheckInt(1)
		amount := L.CheckInt(2)
		host := e.currentHost()
		if host == nil {
			L.Push(lua.LNumber(0))
			return 1
		}
		L.Push(lua.LNumber(host.GiveGold(pid, amount)))
		return 1
	})

	// Convenience: log to the server log. Also respects the no-`os`
	// rule because it goes through the host's logger.
	bind("log", func(L *lua.LState) int {
		msg := L.CheckString(1)
		log.Printf("scripts: %s", msg)
		return 0
	})
}

func (e *ScriptEngine) currentHost() ScriptHost {
	e.mu.Lock()
	defer e.mu.Unlock()
	return e.host
}

// Close releases the long-lived hooks VM. Safe to call multiple times.
func (e *ScriptEngine) Close() {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.hooksVM != nil {
		e.hooksVM.Close()
		e.hooksVM = nil
	}
}
