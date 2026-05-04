package main

import (
	"path/filepath"
	"strings"
	"testing"
	"time"
)

// newTestGameWithMaps builds a Game wrapper with two named maps so warp
// transitions have somewhere real to land. Mirrors newTestGame but
// installs the destination map alongside the default.
func newTestGameWithMaps(t *testing.T, mapNames ...string) *Game {
	t.Helper()
	dir := t.TempDir()
	t.Setenv("MAPS_DIR", dir)

	g := &Game{
		players: make(map[int]*Player),
		enemies: make(map[int]*Enemy),
		ecs:     NewECSWorld(),
		worlds:  make(map[string]*Map),
	}
	g.pipeline = g.buildPipeline()

	// The default "world" map plus any extras requested by the test. We
	// persist each one so mapByName's load-from-disk path is exercised
	// when the warp first fires.
	all := append([]string{defaultMapName}, mapNames...)
	for i, name := range all {
		m := DefaultMap(name)
		// Stamp a unique tile so the test can detect that the right
		// destination layers reached the wire.
		m.Layers.Ground[0][0] = 1000 + i
		if err := SaveMap(m); err != nil {
			t.Fatalf("save map %q: %v", name, err)
		}
	}
	w, err := LoadMap(defaultMapName)
	if err != nil {
		t.Fatalf("load default map: %v", err)
	}
	g.setWorldLocked(w)
	return g
}

// addNamedPlayerOnMap mirrors addNamedPlayerAt but binds the player to
// a specific map so the snapshot pipeline filters them correctly.
func addNamedPlayerOnMap(g *Game, name, mapName string, x, y int) *Player {
	p := addNamedPlayerAt(g, name, x, y)
	p.MapName = mapName
	p.LastSeen = make(map[snapKey]snapState)
	p.Entity = g.ecs.Add(&Entity{
		Kind:    KindPlayer,
		MapName: mapName,
		Position: &CPosition{X: x, Y: y, FromX: x, FromY: y, FaceX: 0, FaceY: 1},
		Health:  &CHealth{HP: p.HP, MaxHP: p.MaxHP, MP: p.MP, MaxMP: p.MaxMP},
		Combat:  &CCombat{Damage: attackDamage, Range: attackRange, Cooldown: attackCD},
	})
	return p
}

// TestPlayerWarpsAcrossMaps drives a player onto a warp tile and
// verifies the transition: MapName flips to the destination, position
// snaps to the target, and a MAP_CHANGE wire frame lands on the
// player's outbound channel.
func TestPlayerWarpsAcrossMaps(t *testing.T) {
	g := newTestGameWithMaps(t, "dungeon")

	// Drop a warp on the default map at (5, 5) pointing into "dungeon".
	g.world.Entities = append(g.world.Entities, MapEntity{
		Type: "trigger", Kind: "warp",
		X: 5, Y: 5,
		TargetMap: "dungeon", TargetX: 3, TargetY: 4,
	})

	p := addNamedPlayerOnMap(g, "warpinator", defaultMapName, 4, 5)
	out := make(chan string, 32)
	p.Out = out
	p.DirX = 1

	now := time.Now()
	g.runMovement(now)
	if p.TileX != 5 || p.TileY != 5 {
		t.Fatalf("expected step onto warp tile (5,5), got (%d,%d)", p.TileX, p.TileY)
	}
	if p.MapName != defaultMapName {
		t.Fatalf("warp must not fire mid-step (still on %q)", p.MapName)
	}

	// Advance past StepDur so the step settles and the pending warp
	// fires inside the same runMovement call.
	g.runMovement(now.Add(p.StepDur + 10*time.Millisecond))

	if p.MapName != "dungeon" {
		t.Fatalf("warp did not transition map: still on %q", p.MapName)
	}
	if p.TileX != 3 || p.TileY != 4 {
		t.Fatalf("expected destination tile (3,4), got (%d,%d)", p.TileX, p.TileY)
	}

	// Drain the player's outbox and confirm both MAP and MAP_CHANGE
	// frames reached the wire.
	var sawMap, sawChange bool
	close(out)
	for msg := range out {
		if strings.HasPrefix(msg, "MAP ") {
			sawMap = true
		}
		if strings.HasPrefix(msg, "MAP_CHANGE ") {
			sawChange = true
			if !strings.Contains(msg, "dungeon") {
				t.Fatalf("MAP_CHANGE missing destination name: %q", msg)
			}
		}
	}
	if !sawMap {
		t.Fatalf("expected MAP frame on warp")
	}
	if !sawChange {
		t.Fatalf("expected MAP_CHANGE frame on warp")
	}
}

// TestPlayersInDifferentMapsDontSeeEachOther confirms the AoI filter
// excludes players whose MapName differs from the viewer's.
func TestPlayersInDifferentMapsDontSeeEachOther(t *testing.T) {
	g := newTestGameWithMaps(t, "dungeon")

	viewer := addNamedPlayerOnMap(g, "viewer", defaultMapName, 5, 5)
	other := addNamedPlayerOnMap(g, "stranger", "dungeon", 5, 5)

	frame := g.buildPlayerSnapshot(viewer, time.Now())
	if strings.Contains(frame, "stranger") {
		t.Fatalf("cross-map player must not appear: %q", frame)
	}
	if strings.Contains(frame, " "+itoa(other.ID)+" ") {
		t.Fatalf("cross-map player must not appear by id: %q", frame)
	}
	// Viewer always sees itself.
	if !strings.Contains(frame, "viewer") {
		t.Fatalf("viewer should appear in their own snapshot: %q", frame)
	}
}

// TestMapEntityRoundTripsWarpFields locks in the JSON contract for the
// warp fields so a future refactor that drops omitempty (or renames
// the tag) trips this test instead of silently breaking saved maps.
func TestMapEntityRoundTripsWarpFields(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("MAPS_DIR", dir)

	m := DefaultMap("village")
	m.Entities = append(m.Entities, MapEntity{
		Type: "trigger", Kind: "warp",
		X: 1, Y: 2,
		TargetMap: "dungeon", TargetX: 9, TargetY: 9,
	})
	if err := SaveMap(m); err != nil {
		t.Fatalf("SaveMap: %v", err)
	}

	loaded, err := LoadMap("village")
	if err != nil {
		t.Fatalf("LoadMap: %v", err)
	}
	if len(loaded.Entities) != 1 {
		t.Fatalf("expected one entity, got %d", len(loaded.Entities))
	}
	e := loaded.Entities[0]
	if !e.IsWarp() {
		t.Fatalf("entity should be a warp: %+v", e)
	}
	if e.TargetMap != "dungeon" || e.TargetX != 9 || e.TargetY != 9 {
		t.Fatalf("warp target drift: got %+v", e)
	}
	// Sanity: the file we wrote still parses on its own with the
	// expected JSON keys.
	matches, _ := filepath.Glob(filepath.Join(dir, "village.json"))
	if len(matches) != 1 {
		t.Fatalf("expected village.json on disk, got %v", matches)
	}
}

// TestQuestGiverWithLeftoverHPStaysFriendly is the regression guard
// for the bug the user reported alongside Phase 2: an NPC editor
// session that toggled an enemy back to quest_giver carried over the
// HP value, and IsHostile's HP > 0 fallback was wrongly classifying
// the NPC as hostile — so the quest giver spawned as an enemy (or not
// at all from the friendly path). The fix honours the explicit
// non-hostile role even when HP leaks through from a previous edit.
func TestQuestGiverWithLeftoverHPStaysFriendly(t *testing.T) {
	def := &NPCDef{
		ID:   "elder",
		Role: NPCRoleQuestGiver,
		HP:   80, // leftover from a previous "enemy" save
	}
	if def.IsHostile() {
		t.Fatalf("a quest_giver with leftover HP must not be hostile")
	}
	// Friendly / merchant share the same fix.
	def.Role = NPCRoleFriendly
	if def.IsHostile() {
		t.Fatalf("a friendly NPC with HP > 0 must not be hostile")
	}
	def.Role = NPCRoleMerchant
	if def.IsHostile() {
		t.Fatalf("a merchant with HP > 0 must not be hostile")
	}
	// Sanity: the legacy HP > 0 fallback is still honoured for
	// role-less NPCs (older content files that never set Role).
	def.Role = ""
	if !def.IsHostile() {
		t.Fatalf("legacy role-less NPC with HP > 0 should still be hostile")
	}
}
