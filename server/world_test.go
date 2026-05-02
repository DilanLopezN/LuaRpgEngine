package main

import (
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

// TestMapRoundTripDefault is the regression guard the roadmap calls out:
// the engine's stock map must serialise → reload → match itself
// byte-for-structure. If a field is dropped from the JSON tags or the
// validateMap normalisation mutates state on read, this test trips.
func TestMapRoundTripDefault(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("MAPS_DIR", dir)

	m := DefaultMap("world")
	// Add an entity to exercise the entity round-trip too — the default
	// map ships with none.
	m.Entities = append(m.Entities, MapEntity{Type: "spawn", Kind: "player", X: 1, Y: 2})
	m.Layers.Collision[3][4] = 1
	m.Layers.Logic[5][6] = 7

	if err := SaveMap(m); err != nil {
		t.Fatalf("SaveMap: %v", err)
	}
	loaded, err := LoadMap("world")
	if err != nil {
		t.Fatalf("LoadMap: %v", err)
	}

	if loaded.Width != m.Width || loaded.Height != m.Height {
		t.Fatalf("dimensions changed: got %dx%d want %dx%d",
			loaded.Width, loaded.Height, m.Width, m.Height)
	}
	if loaded.SchemaVersion != m.SchemaVersion {
		t.Fatalf("schema_version drift: got %d want %d",
			loaded.SchemaVersion, m.SchemaVersion)
	}
	if !reflect.DeepEqual(loaded.Entities, m.Entities) {
		t.Fatalf("entities drift\n got=%#v\nwant=%#v", loaded.Entities, m.Entities)
	}
	if !reflect.DeepEqual(loaded.Tilesets, m.Tilesets) {
		t.Fatalf("tilesets drift")
	}
	if !reflect.DeepEqual(loaded.Layers, m.Layers) {
		t.Fatalf("layers drift")
	}
}

// TestMapRejectsFutureSchemaVersion: future-versioned maps must be
// refused with a clear, actionable error — not a silent fallback.
func TestMapRejectsFutureSchemaVersion(t *testing.T) {
	m := DefaultMap("world")
	m.SchemaVersion = MapSchemaVersion + 99
	err := validateMap(m)
	if err == nil {
		t.Fatalf("expected validateMap to reject future schema_version")
	}
	if !strings.Contains(err.Error(), "schema_version") {
		t.Fatalf("error must mention schema_version: %v", err)
	}
	if !strings.Contains(err.Error(), "upgrade") {
		t.Fatalf("error should hint at upgrading the server: %v", err)
	}
}

// TestMapRejectsNegativeSchemaVersion: a negative version is corrupt
// data, not a downgrade.
func TestMapRejectsNegativeSchemaVersion(t *testing.T) {
	m := DefaultMap("world")
	m.SchemaVersion = -1
	if err := validateMap(m); err == nil {
		t.Fatalf("expected validateMap to reject negative schema_version")
	}
}

// TestMapMissingSchemaVersionDefaults: legacy map files (predating the
// version field) must still load — promoted to v1 transparently.
func TestMapMissingSchemaVersionDefaults(t *testing.T) {
	m := DefaultMap("world")
	m.SchemaVersion = 0
	if err := validateMap(m); err != nil {
		t.Fatalf("validateMap promoted=0: %v", err)
	}
	if m.SchemaVersion != 1 {
		t.Fatalf("missing schema_version should default to 1, got %d", m.SchemaVersion)
	}
}

// TestSaveMapBackupSibling: SaveMap must drop a .bak alongside an
// existing file before overwriting it.
func TestSaveMapBackupSibling(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("MAPS_DIR", dir)

	m := DefaultMap("world")
	if err := SaveMap(m); err != nil {
		t.Fatalf("SaveMap initial: %v", err)
	}
	m.Layers.Ground[0][0] = 42
	if err := SaveMap(m); err != nil {
		t.Fatalf("SaveMap second: %v", err)
	}
	matches, err := filepath.Glob(filepath.Join(dir, "world.json.*.bak"))
	if err != nil {
		t.Fatalf("glob: %v", err)
	}
	if len(matches) == 0 {
		t.Fatalf("expected at least one .bak file after rewrite, got none")
	}
}
