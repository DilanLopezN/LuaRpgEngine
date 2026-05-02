package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// TestScriptEngineLoadsAllDomains verifies the bundled data/ tree
// parses without warnings — items, npcs, quests, progression.
func TestScriptEngineLoadsAllDomains(t *testing.T) {
	e := NewScriptEngine("data/scripts")
	e.LoadAll()

	if len(e.Items()) == 0 {
		t.Fatal("expected items to load from data/scripts/items")
	}
	if len(e.NPCs()) == 0 {
		t.Fatal("expected npcs to load from data/scripts/npcs")
	}
	if len(e.Quests()) == 0 {
		t.Fatal("expected quests to load from data/scripts/quests")
	}
	pd := e.Progression()
	if pd.XPBase <= 0 {
		t.Fatalf("progression should be loaded, got %+v", pd)
	}

	// Spot-check shapes the rest of the engine relies on.
	if it, ok := e.Item("orc_tooth"); !ok || !it.Bound {
		t.Fatalf("orc_tooth should load and be bound: %+v", it)
	}
	if it, ok := e.Item("rusty_sword"); !ok || it.Slot != "weapon" {
		t.Fatalf("rusty_sword should equip in weapon slot: %+v", it)
	}
	if q, ok := e.Quest("orc_hunt"); !ok || q.KillTarget != "orc" || q.KillCount != 3 {
		t.Fatalf("orc_hunt malformed: %+v", q)
	}
	if def, ok := e.NPC("elder"); !ok || def.Nodes["start"] == nil {
		t.Fatalf("elder npc missing start node: %+v", def)
	}
}

// Phase 2 hardening — the sandbox must refuse every escape hatch we
// know about: filesystem (`io.open`, `dofile`, `loadfile`), process
// (`os.execute`), reflection (`debug`), and hot-loading (`require`,
// `loadstring`/`load`). Adding a new escape vector should ship with
// a new entry here.
func TestSandboxBlocksDangerousAPIs(t *testing.T) {
	cases := []struct {
		name string
		body string
	}{
		{"os.execute", `os.execute("echo pwn")`},
		{"os.exit", `os.exit(0)`},
		{"os.getenv", `local _ = os.getenv("PATH")`},
		{"io.open", `local _ = io.open("/etc/passwd", "r")`},
		{"io.write", `io.write("nope")`},
		{"require", `require("os")`},
		{"loadstring", `local f = loadstring("return 1") f()`},
		{"load", `local f = load("return 1") f()`},
		{"dofile", `dofile("/etc/passwd")`},
		{"loadfile", `loadfile("/etc/passwd")`},
		{"debug.getinfo", `local _ = debug.getinfo(1)`},
		{"package.loadlib", `package.loadlib("foo", "bar")`},
	}
	dir := t.TempDir()
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			path := filepath.Join(dir, "probe.lua")
			body := c.body + "\nreturn { ok = true }\n"
			if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
				t.Fatalf("write: %v", err)
			}
			_, err := evalScript(path)
			if err == nil {
				t.Fatalf("expected sandbox to reject %s but it returned nil", c.name)
			}
			// Most failures surface as "attempt to index a nil value"
			// or "attempt to call a nil value" — anything except a
			// clean execution counts.
			if strings.Contains(err.Error(), "deadline") {
				t.Fatalf("sandbox timed out (loop?) instead of rejecting %s: %v", c.name, err)
			}
		})
	}
}

// TestSandboxStillRunsSafeAPIs guards against over-zealous lock-down:
// every API the data scripts actually use must keep working.
func TestSandboxAllowsSafeAPIs(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "ok.lua")
	body := `
		local s = string.format("hi %d", 42)
		local t = {1, 2, 3}
		table.insert(t, 4)
		local m = math.floor(3.7)
		return { s = s, n = #t, m = m }
	`
	if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
		t.Fatalf("write: %v", err)
	}
	val, err := evalScript(path)
	if err != nil {
		t.Fatalf("evalScript: %v", err)
	}
	if val == nil {
		t.Fatalf("expected a table from script")
	}
}

// Phase 2.5 hardening — cyclic skill-tree prerequisites must be caught
// at load time. A typo like "A requires B, B requires A" should fail
// loud, not break the learn flow at runtime.
func TestValidateSkillTreeRejectsCycle(t *testing.T) {
	tree := map[string]*SkillTreeNode{
		"a": {ID: "a", Requires: []string{"b"}},
		"b": {ID: "b", Requires: []string{"a"}},
	}
	err := validateSkillTree(tree)
	if err == nil {
		t.Fatal("expected validateSkillTree to detect a 2-node cycle")
	}
	if !strings.Contains(err.Error(), "cycle") {
		t.Fatalf("error must mention 'cycle': %v", err)
	}
}

func TestValidateSkillTreeRejectsSelfReference(t *testing.T) {
	tree := map[string]*SkillTreeNode{
		"a": {ID: "a", Requires: []string{"a"}},
	}
	if err := validateSkillTree(tree); err == nil {
		t.Fatal("expected validateSkillTree to detect a self-reference")
	}
}

func TestValidateSkillTreeAcceptsLinearChain(t *testing.T) {
	tree := map[string]*SkillTreeNode{
		"a": {ID: "a", Requires: nil},
		"b": {ID: "b", Requires: []string{"a"}},
		"c": {ID: "c", Requires: []string{"b"}},
	}
	if err := validateSkillTree(tree); err != nil {
		t.Fatalf("linear chain should be valid: %v", err)
	}
}

func TestValidateSkillTreeAcceptsDiamond(t *testing.T) {
	// A diamond (a → b, a → c, b → d, c → d) is a DAG, not a cycle.
	tree := map[string]*SkillTreeNode{
		"a": {ID: "a"},
		"b": {ID: "b", Requires: []string{"a"}},
		"c": {ID: "c", Requires: []string{"a"}},
		"d": {ID: "d", Requires: []string{"b", "c"}},
	}
	if err := validateSkillTree(tree); err != nil {
		t.Fatalf("diamond DAG should be valid: %v", err)
	}
}

func TestParseNPCDefRequiresStart(t *testing.T) {
	bad := map[string]interface{}{
		"id": "x",
		"dialog": map[string]interface{}{
			"hi": map[string]interface{}{"text": "hello"},
		},
	}
	if _, err := parseNPCDef(bad, "x"); err == nil {
		t.Fatal("expected error when start node is missing")
	}
	good := map[string]interface{}{
		"id": "x",
		"dialog": map[string]interface{}{
			"start": map[string]interface{}{
				"text": "hi",
				"options": []interface{}{
					map[string]interface{}{"text": "bye", "next_node": "end"},
				},
			},
		},
	}
	def, err := parseNPCDef(good, "x")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(def.Nodes["start"].Options) != 1 {
		t.Fatalf("options not parsed: %+v", def.Nodes["start"])
	}
}
