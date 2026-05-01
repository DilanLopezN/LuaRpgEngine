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
}

// ScriptEngine owns the data-driven content loaded from disk and the
// long-lived sandboxed VM that executes hook callbacks.
type ScriptEngine struct {
	mu      sync.Mutex
	rootDir string
	host    ScriptHost

	skills  map[string]*Skill
	tree    map[string]*SkillTreeNode
	enemies map[string]*EnemyDef

	// hooksVM holds parsed hook callbacks keyed by event name. It lives
	// across the server's lifetime and is rebuilt on /reload hooks.
	hooksVM *lua.LState
	hooks   map[string]*lua.LFunction
}

// EnemyDef is a data-driven enemy template loaded from
// data/scripts/enemies/<id>.lua.
type EnemyDef struct {
	ID    string
	Name  string
	HP    int
	Speed float64
}

// NewScriptEngine returns an engine rooted at data/scripts/. It does
// not load anything; call LoadAll once a host is wired.
func NewScriptEngine(root string) *ScriptEngine {
	return &ScriptEngine{
		rootDir: root,
		skills:  make(map[string]*Skill),
		tree:    make(map[string]*SkillTreeNode),
		enemies: make(map[string]*EnemyDef),
		hooks:   make(map[string]*lua.LFunction),
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
	for _, d := range []string{"skills", "enemies", "items", "hooks"} {
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
		// Reserved for Phase 4 — accept the command so /reload items
		// is forward-compatible without lying about what happened.
		log.Printf("scripts: items domain reserved for Phase 4")
		return nil
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

// FireHook invokes the hook function registered under name with a
// single Lua table built from args. Missing hooks are a no-op so
// gameplay code can call FireHook unconditionally.
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

	e.mu.Lock()
	defer e.mu.Unlock()

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
