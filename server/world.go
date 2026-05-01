package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// MapSchemaVersion is incremented whenever the on-disk format changes in a
// way that requires a migration. Loaders should refuse maps with a higher
// version they don't understand.
const MapSchemaVersion = 1

const (
	defaultMapName    = "world"
	defaultMapWidth   = 20
	defaultMapHeight  = 20
	defaultMapTileW   = 16
	defaultMapTileH   = 16
	maxMapWidth       = 256
	maxMapHeight      = 256
	maxMapEntities    = 4096
	saveMapMaxPayload = 4 * 1024 * 1024 // 4 MiB
)

// Tileset declares a sprite sheet referenced by the map. Paths are stored
// relative to the project root and must be resolvable by the client; the
// server only persists them.
type Tileset struct {
	ID    int    `json:"id"`
	Path  string `json:"path"`
	TileW int    `json:"tile_w"`
	TileH int    `json:"tile_h"`
}

// MapEntity is anything the map editor can drop on a tile: spawn points,
// NPCs, triggers. Phase 1 stores raw values; later phases will hand these
// over to the gameplay/scripting systems.
type MapEntity struct {
	Type string `json:"type"`
	Kind string `json:"kind,omitempty"`
	X    int    `json:"x"`
	Y    int    `json:"y"`
}

// Map is the in-memory representation of a single tilemap. All access goes
// through Game.mu — Map itself is dumb data.
type Map struct {
	SchemaVersion int         `json:"schema_version"`
	Name          string      `json:"name"`
	Width         int         `json:"width"`
	Height        int         `json:"height"`
	TileW         int         `json:"tile_w"`
	TileH         int         `json:"tile_h"`
	Tilesets      []Tileset   `json:"tilesets"`
	Layers        MapLayers   `json:"layers"`
	Entities      []MapEntity `json:"entities"`
}

// MapLayers bundles the four canonical layers. Visual layers (ground,
// decoration) hold packed tile IDs. Collision is 0/1. Logic stores arbitrary
// integer markers consumed by gameplay systems (Phase 2+).
type MapLayers struct {
	Ground     [][]int `json:"ground"`
	Collision  [][]int `json:"collision"`
	Decoration [][]int `json:"decoration"`
	Logic      [][]int `json:"logic"`
}

func mapsDir() string {
	if d := os.Getenv("MAPS_DIR"); d != "" {
		return d
	}
	return filepath.Join("data", "maps")
}

func emptyLayer(w, h int) [][]int {
	rows := make([][]int, h)
	for i := range rows {
		rows[i] = make([]int, w)
	}
	return rows
}

// DefaultMap builds a blank map with the engine's stock tilesets registered
// so a brand new install has something to paint with.
func DefaultMap(name string) *Map {
	w, h := defaultMapWidth, defaultMapHeight
	return &Map{
		SchemaVersion: MapSchemaVersion,
		Name:          name,
		Width:         w,
		Height:        h,
		TileW:         defaultMapTileW,
		TileH:         defaultMapTileH,
		Tilesets: []Tileset{
			{ID: 1, Path: "assets/Pixel Crawler - Free Pack/Environment/Tilesets/Floors_Tiles.png", TileW: 16, TileH: 16},
			{ID: 2, Path: "assets/Pixel Crawler - Free Pack/Environment/Tilesets/Wall_Tiles.png", TileW: 16, TileH: 16},
			{ID: 3, Path: "assets/Pixel Crawler - Free Pack/Environment/Tilesets/Dungeon_Tiles.png", TileW: 16, TileH: 16},
		},
		Layers: MapLayers{
			Ground:     emptyLayer(w, h),
			Collision:  emptyLayer(w, h),
			Decoration: emptyLayer(w, h),
			Logic:      emptyLayer(w, h),
		},
		Entities: []MapEntity{},
	}
}

func sanitizeMapName(name string) string {
	var b strings.Builder
	for _, r := range name {
		if (r >= 'a' && r <= 'z') ||
			(r >= 'A' && r <= 'Z') ||
			(r >= '0' && r <= '9') ||
			r == '_' || r == '-' {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// LoadMap reads <mapsDir>/<name>.json, falling back to a blank default if
// the file is missing. Validation is strict: malformed bounds, mismatched
// layer dimensions, or an unknown schema version are returned as errors.
func LoadMap(name string) (*Map, error) {
	clean := sanitizeMapName(name)
	if clean == "" {
		return nil, errors.New("invalid map name")
	}
	p := filepath.Join(mapsDir(), clean+".json")
	data, err := os.ReadFile(p)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			m := DefaultMap(clean)
			return m, nil
		}
		return nil, err
	}
	var m Map
	if err := json.Unmarshal(data, &m); err != nil {
		return nil, fmt.Errorf("parse map: %w", err)
	}
	if err := validateMap(&m); err != nil {
		return nil, err
	}
	return &m, nil
}

func validateMap(m *Map) error {
	if m.SchemaVersion == 0 {
		m.SchemaVersion = 1
	}
	if m.SchemaVersion > MapSchemaVersion {
		return fmt.Errorf("unsupported schema_version %d", m.SchemaVersion)
	}
	if m.Width <= 0 || m.Height <= 0 || m.Width > maxMapWidth || m.Height > maxMapHeight {
		return fmt.Errorf("invalid map bounds %dx%d", m.Width, m.Height)
	}
	if m.TileW <= 0 {
		m.TileW = defaultMapTileW
	}
	if m.TileH <= 0 {
		m.TileH = defaultMapTileH
	}
	if m.Name == "" {
		m.Name = defaultMapName
	}
	m.Layers.Ground = ensureLayer(m.Layers.Ground, m.Width, m.Height)
	m.Layers.Collision = ensureLayer(m.Layers.Collision, m.Width, m.Height)
	m.Layers.Decoration = ensureLayer(m.Layers.Decoration, m.Width, m.Height)
	m.Layers.Logic = ensureLayer(m.Layers.Logic, m.Width, m.Height)
	if len(m.Entities) > maxMapEntities {
		return fmt.Errorf("too many entities (%d)", len(m.Entities))
	}
	for i := range m.Entities {
		e := &m.Entities[i]
		if e.X < 0 || e.X >= m.Width || e.Y < 0 || e.Y >= m.Height {
			return fmt.Errorf("entity %d out of bounds", i)
		}
	}
	if m.Tilesets == nil {
		m.Tilesets = []Tileset{}
	}
	return nil
}

// ensureLayer normalises a layer grid so the runtime never has to bounds
// check against a ragged matrix: missing rows/columns are zero-padded,
// extras are clipped.
func ensureLayer(in [][]int, w, h int) [][]int {
	out := make([][]int, h)
	for y := 0; y < h; y++ {
		row := make([]int, w)
		if y < len(in) {
			src := in[y]
			n := len(src)
			if n > w {
				n = w
			}
			copy(row, src[:n])
		}
		out[y] = row
	}
	return out
}

// SaveMap atomically writes the map to disk. If the destination already
// exists its contents are copied to a timestamped .bak first so a botched
// save can be rolled back by hand.
func SaveMap(m *Map) error {
	if err := validateMap(m); err != nil {
		return err
	}
	dir := mapsDir()
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	p := filepath.Join(dir, m.Name+".json")
	if existing, err := os.ReadFile(p); err == nil {
		bp := p + "." + time.Now().Format("20060102-150405") + ".bak"
		if werr := os.WriteFile(bp, existing, 0o644); werr != nil {
			log.Printf("map backup failed: %v", werr)
		}
	}
	data, err := json.MarshalIndent(m, "", "  ")
	if err != nil {
		return err
	}
	tmp := p + ".tmp"
	if err := os.WriteFile(tmp, data, 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, p)
}

func (m *Map) InBounds(x, y int) bool {
	return x >= 0 && x < m.Width && y >= 0 && y < m.Height
}

// IsWalkable reports whether a player or enemy is allowed to stand on
// (x, y). Out-of-bounds tiles are never walkable; in-bounds tiles consult
// the collision layer (0 = walkable, anything else blocked).
func (m *Map) IsWalkable(x, y int) bool {
	if !m.InBounds(x, y) {
		return false
	}
	if y >= len(m.Layers.Collision) {
		return true
	}
	row := m.Layers.Collision[y]
	if x >= len(row) {
		return true
	}
	return row[x] == 0
}

// Marshal returns the canonical (compact) JSON used on the wire.
func (m *Map) Marshal() ([]byte, error) {
	return json.Marshal(m)
}
