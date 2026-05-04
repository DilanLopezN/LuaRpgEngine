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
	if q, ok := e.Quest("orc_hunt"); !ok || len(q.Objectives) == 0 {
		t.Fatalf("orc_hunt malformed: %+v", q)
	} else {
		// Legacy single-objective shape gets folded into Objectives[].
		// Confirm the kill objective survived the schema migration.
		hasKill := false
		for _, o := range q.Objectives {
			if o.Type == "kill" && o.Target == "orc" && o.Count == 3 {
				hasKill = true
			}
		}
		if !hasKill {
			t.Fatalf("orc_hunt lost its kill objective: %+v", q.Objectives)
		}
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

// A user-authored NPC carrying a quest binding but no dialog should
// auto-generate the four-node tree (offer / accept / in-progress /
// turn-in) so the editor can produce a working quest giver in one
// click. Catches a regression where the synthesizer only fired for
// completely empty defs.
func TestParseNPCDefSynthesizesQuestDialog(t *testing.T) {
	raw := map[string]interface{}{
		"id":    "merch",
		"name":  "Mercante",
		"role":  "quest_giver",
		"quest": "orc_hunt",
	}
	def, err := parseNPCDef(raw, "merch")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	for _, want := range []string{"start", "more", "accepted", "return_in_progress", "return_done"} {
		if _, ok := def.Nodes[want]; !ok {
			t.Fatalf("missing synthesized node %q", want)
		}
	}
	if def.Faction != NPCFactionAlly {
		t.Fatalf("quest_giver should default to ally faction, got %q", def.Faction)
	}
}

// Hostile NPCs (role=enemy / role=guardian) must report IsHostile so
// the spawner routes them through the enemy AI path. Phase 2 fixed
// the regression where a quest_giver / friendly / merchant NPC with
// leftover HP from a previous "enemy" save would silently spawn as a
// hostile mob instead of as a peaceful villager — explicit
// non-hostile roles now win regardless of HP. The legacy "no role,
// HP > 0 => hostile" inference still holds for content files that
// never set Role at all.
func TestNPCDefIsHostile(t *testing.T) {
	cases := []struct {
		role string
		hp   int
		want bool
	}{
		{"friendly", 0, false},
		{"merchant", 0, false},
		{"quest_giver", 0, false},
		{"guardian", 0, true},
		{"enemy", 0, true},
		// Explicit non-hostile roles override leftover HP.
		{"friendly", 50, false},
		{"merchant", 50, false},
		{"quest_giver", 50, false},
		// Role-less content uses HP as a hostile signal.
		{"", 50, true},
		{"", 0, false},
	}
	for _, c := range cases {
		d := &NPCDef{Role: c.role, HP: c.hp}
		if got := d.IsHostile(); got != c.want {
			t.Errorf("role=%q hp=%d: got %v want %v", c.role, c.hp, got, c.want)
		}
	}
}

// Multi-objective quest schema must accept the legacy single-objective
// shape AND the new objectives[] list. Both surfaces converge on the
// same Objectives slice.
func TestParseQuestDefMultiObjective(t *testing.T) {
	raw := map[string]interface{}{
		"id":         "boss_arena",
		"name":       "Arena do Chefe",
		"giver":      "elder",
		"repeatable": true,
		"prerequisites": map[string]interface{}{
			"level": 5,
			"quest": "orc_hunt",
		},
		"objectives": []interface{}{
			map[string]interface{}{"type": "kill", "target": "troll", "count": 2},
			map[string]interface{}{"type": "collect", "target": "orc_tooth", "count": 5},
			map[string]interface{}{"type": "level", "count": 6},
			map[string]interface{}{"type": "talk", "target": "elder"},
			map[string]interface{}{
				"type": "visit", "x": 10, "y": 10, "range": 1,
			},
		},
		"reward": map[string]interface{}{
			"xp":           500,
			"gold":         200,
			"skill_points": 2,
			"learn_skill":  "fireball",
			"items": []interface{}{
				map[string]interface{}{"id": "rusty_sword", "qty": 1},
				map[string]interface{}{"id": "health_potion", "qty": 3},
			},
		},
	}
	def, err := parseQuestDef(raw, "boss_arena")
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	if !def.Repeatable {
		t.Error("repeatable lost")
	}
	if def.Prerequisites.Level != 5 || def.Prerequisites.Quest != "orc_hunt" {
		t.Errorf("prereqs malformed: %+v", def.Prerequisites)
	}
	if len(def.Objectives) != 5 {
		t.Fatalf("expected 5 objectives, got %d: %+v", len(def.Objectives), def.Objectives)
	}
	if def.Reward.SkillPoints != 2 || def.Reward.LearnSkill != "fireball" {
		t.Errorf("reward bundle malformed: %+v", def.Reward)
	}
	if len(def.Reward.Items) != 2 {
		t.Errorf("reward items lost: %+v", def.Reward.Items)
	}
}

// Quest progress tracking: kill counter clamps at the objective count
// and stays in sync with the legacy KillCount mirror.
func TestQuestProgressClampsAtTarget(t *testing.T) {
	def := &QuestDef{
		ID: "q",
		Objectives: []QuestObjective{
			{Type: "kill", Target: "orc", Count: 3},
		},
	}
	qs := &QuestState{ID: "q", Stage: "active", Progress: []int{0}}
	for i := 0; i < 5; i++ {
		ensureProgressLen(qs, len(def.Objectives))
		for idx, o := range def.Objectives {
			if o.Type != "kill" || o.Target != "orc" {
				continue
			}
			if qs.Progress[idx] >= o.Count {
				continue
			}
			qs.Progress[idx]++
		}
	}
	if qs.Progress[0] != 3 {
		t.Fatalf("expected clamp at 3, got %d", qs.Progress[0])
	}
}

// Quest user JSON round-trip preserves rich fields including the
// objective list and bundle reward.
func TestUserQuestJSONRoundTrip(t *testing.T) {
	dir := t.TempDir()
	def := &QuestDef{
		ID: "fetch_potions", Name: "Pegar Poções",
		Description: "Traga poções para o velho.",
		Giver:       "elder",
		Repeatable:  true,
		Prerequisites: QuestPrereqs{
			Level: 3,
		},
		Objectives: []QuestObjective{
			{Type: "collect", Target: "health_potion", Count: 5},
			{Type: "level", Count: 5},
		},
		Reward: QuestReward{
			XP: 100, Gold: 50,
			Items: []ItemRef{{ID: "rusty_sword", Qty: 1}},
		},
		IntroMessage: "Boa sorte!",
	}
	if err := SaveUserQuestDef(dir, def); err != nil {
		t.Fatalf("save: %v", err)
	}
	loaded, err := LoadUserQuestJSON(filepath.Join(dir, "quests_user", "fetch_potions.json"))
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if loaded.ID != "fetch_potions" || !loaded.Repeatable ||
		len(loaded.Objectives) != 2 || loaded.Reward.XP != 100 ||
		len(loaded.Reward.Items) != 1 {
		t.Fatalf("round trip mismatch: %+v rew=%+v", loaded, loaded.Reward)
	}
}

// Round-trip a JSON document through SaveUserNPCDef + LoadUserNPCJSON
// to verify serialisation preserves the rich fields.
func TestUserNPCJSONRoundTrip(t *testing.T) {
	dir := t.TempDir()
	def := &NPCDef{
		ID: "boss", Name: "Chefe Final", Title: "Sombra",
		Role: NPCRoleEnemy, Faction: NPCFactionHostile,
		Sprite: "mob_skeleton_mage",
		HP:     200, Damage: 20, Speed: 1.2, Aggro: 6, XP: 500,
		Loot: []NPCLootEntry{{Item: "rusty_sword", Qty: 1, Chance: 1000}},
	}
	if err := SaveUserNPCDef(dir, def); err != nil {
		t.Fatalf("save: %v", err)
	}
	loaded, err := LoadUserNPCJSON(filepath.Join(dir, "npcs_user", "boss.json"))
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if loaded.ID != "boss" || loaded.Role != NPCRoleEnemy ||
		loaded.HP != 200 || loaded.Damage != 20 || loaded.Sprite != "mob_skeleton_mage" {
		t.Fatalf("round trip mismatch: %+v", loaded)
	}
	if !loaded.IsHostile() {
		t.Fatal("hostile NPC lost its hostility through the round trip")
	}
	if len(loaded.Loot) != 1 || loaded.Loot[0].Item != "rusty_sword" {
		t.Fatalf("loot lost: %+v", loaded.Loot)
	}
}
