package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"os"

	_ "github.com/lib/pq"
)

type DB struct {
	conn *sql.DB
}

func NewDB() *DB {
	dsn := os.Getenv("POSTGRES_DSN")
	if dsn == "" {
		dsn = "host=localhost port=5432 user=rpg password=rpg dbname=rpg sslmode=disable"
	}
	conn, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Printf("postgres open failed: %v (running without persistence)", err)
		return &DB{}
	}
	if err := conn.Ping(); err != nil {
		log.Printf("postgres ping failed: %v (running without persistence)", err)
		conn.Close()
		return &DB{}
	}
	if err := initSchema(conn); err != nil {
		log.Printf("postgres schema init failed: %v", err)
	}
	log.Printf("postgres connected")
	return &DB{conn: conn}
}

// initSchema runs idempotent DDL for the character entity (players) and the
// spells they have authored (character_spells).
func initSchema(conn *sql.DB) error {
	stmts := []string{
		`CREATE TABLE IF NOT EXISTS players (
			name        TEXT PRIMARY KEY,
			hp          INTEGER NOT NULL DEFAULT 100,
			max_hp      INTEGER NOT NULL DEFAULT 100,
			mp          INTEGER NOT NULL DEFAULT 100,
			max_mp      INTEGER NOT NULL DEFAULT 100,
			kills       INTEGER NOT NULL DEFAULT 0,
			last_x      INTEGER NOT NULL DEFAULT 10,
			last_y      INTEGER NOT NULL DEFAULT 10,
			created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS max_hp INTEGER NOT NULL DEFAULT 100`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS mp     INTEGER NOT NULL DEFAULT 100`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS max_mp INTEGER NOT NULL DEFAULT 100`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS skill_points INTEGER NOT NULL DEFAULT 3`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS level INTEGER NOT NULL DEFAULT 1`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS xp    INTEGER NOT NULL DEFAULT 0`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS str   INTEGER NOT NULL DEFAULT 1`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS dex   INTEGER NOT NULL DEFAULT 1`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS intel INTEGER NOT NULL DEFAULT 1`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS vit   INTEGER NOT NULL DEFAULT 1`,
		`ALTER TABLE players ADD COLUMN IF NOT EXISTS gold  INTEGER NOT NULL DEFAULT 0`,
		`CREATE TABLE IF NOT EXISTS character_inventory (
			character_name TEXT NOT NULL,
			slot_index     INTEGER NOT NULL,
			item_id        TEXT NOT NULL,
			qty            INTEGER NOT NULL,
			PRIMARY KEY (character_name, slot_index)
		)`,
		`CREATE TABLE IF NOT EXISTS character_equipped (
			character_name TEXT NOT NULL,
			slot           TEXT NOT NULL,
			item_id        TEXT NOT NULL,
			PRIMARY KEY (character_name, slot)
		)`,
		`CREATE TABLE IF NOT EXISTS character_quests (
			character_name TEXT NOT NULL,
			quest_id       TEXT NOT NULL,
			stage          TEXT NOT NULL DEFAULT 'active',
			kill_count     INTEGER NOT NULL DEFAULT 0,
			done           BOOLEAN NOT NULL DEFAULT FALSE,
			PRIMARY KEY (character_name, quest_id)
		)`,
		// Multi-objective progress lives in a JSON column. ALTER is
		// idempotent so existing deployments pick it up without a
		// migration step.
		`ALTER TABLE character_quests ADD COLUMN IF NOT EXISTS progress JSONB NOT NULL DEFAULT '[]'::jsonb`,
		`CREATE TABLE IF NOT EXISTS character_learned_skills (
			character_name TEXT NOT NULL,
			skill_id       TEXT NOT NULL,
			learned_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			PRIMARY KEY (character_name, skill_id)
		)`,
		`CREATE TABLE IF NOT EXISTS character_spells (
			character_name TEXT    NOT NULL,
			spell_id       TEXT    NOT NULL,
			name           TEXT    NOT NULL DEFAULT '',
			kind           TEXT    NOT NULL,
			effect         TEXT    NOT NULL,
			range_val      INTEGER NOT NULL DEFAULT 0,
			radius         INTEGER NOT NULL DEFAULT 0,
			power          INTEGER NOT NULL DEFAULT 0,
			mana_cost      INTEGER NOT NULL DEFAULT 0,
			cooldown_ms    INTEGER NOT NULL DEFAULT 0,
			color_r        INTEGER NOT NULL DEFAULT 0,
			color_g        INTEGER NOT NULL DEFAULT 0,
			color_b        INTEGER NOT NULL DEFAULT 0,
			updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			PRIMARY KEY (character_name, spell_id)
		)`,
	}
	for _, s := range stmts {
		if _, err := conn.Exec(s); err != nil {
			return err
		}
	}
	return nil
}

type PlayerRecord struct {
	HP, MaxHP   int
	MP, MaxMP   int
	Kills       int
	X, Y        int
	SkillPoints int
	// Phase 4 — character sheet.
	Level    int
	XP       int
	Str, Dex int
	Int, Vit int
	Gold     int
}

func (d *DB) LoadOrCreate(name string) PlayerRecord {
	rec := PlayerRecord{
		HP: 100, MaxHP: 100,
		MP: 100, MaxMP: 100,
		Kills: 0, X: 10, Y: 10,
		SkillPoints: 3,
		Level:       1,
		Str:         1, Dex: 1, Int: 1, Vit: 1,
	}
	if d.conn == nil {
		return rec
	}
	err := d.conn.QueryRow(
		`SELECT hp, max_hp, mp, max_mp, kills, last_x, last_y, skill_points,
		        level, xp, str, dex, intel, vit, gold
		   FROM players WHERE name=$1`, name,
	).Scan(&rec.HP, &rec.MaxHP, &rec.MP, &rec.MaxMP, &rec.Kills,
		&rec.X, &rec.Y, &rec.SkillPoints,
		&rec.Level, &rec.XP, &rec.Str, &rec.Dex, &rec.Int, &rec.Vit, &rec.Gold)
	if err == sql.ErrNoRows {
		_, _ = d.conn.Exec(`INSERT INTO players(name) VALUES($1)`, name)
		return rec
	}
	if err != nil {
		log.Printf("postgres load %s: %v", name, err)
	}
	return rec
}

func (d *DB) SaveProgression(name string, level, xp, str, dex, intel, vit, gold int) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(
		`UPDATE players SET level=$2, xp=$3, str=$4, dex=$5, intel=$6, vit=$7, gold=$8,
		                    updated_at=NOW()
		   WHERE name=$1`,
		name, level, xp, str, dex, intel, vit, gold)
	if err != nil {
		log.Printf("postgres save progression %s: %v", name, err)
	}
}

// LoadInventory returns the persisted inventory for a character. Slots
// preserve insertion order via slot_index.
func (d *DB) LoadInventory(name string) []ItemRef {
	if d.conn == nil {
		return nil
	}
	rows, err := d.conn.Query(
		`SELECT item_id, qty FROM character_inventory
		  WHERE character_name=$1 ORDER BY slot_index`, name)
	if err != nil {
		log.Printf("postgres load inventory %s: %v", name, err)
		return nil
	}
	defer rows.Close()
	var out []ItemRef
	for rows.Next() {
		var ref ItemRef
		if err := rows.Scan(&ref.ID, &ref.Qty); err == nil && ref.Qty > 0 {
			out = append(out, ref)
		}
	}
	return out
}

// SaveInventory replaces the persisted inventory + equipped set for a
// character with the live snapshot. Cheap to call after every change
// because the dataset is tiny.
func (d *DB) SaveInventory(name string, p *Player) {
	if d.conn == nil || p == nil {
		return
	}
	tx, err := d.conn.Begin()
	if err != nil {
		log.Printf("postgres save inventory tx %s: %v", name, err)
		return
	}
	if _, err := tx.Exec(`DELETE FROM character_inventory WHERE character_name=$1`, name); err != nil {
		_ = tx.Rollback()
		log.Printf("postgres save inventory clear %s: %v", name, err)
		return
	}
	if p.Entity != nil && p.Entity.Inventory != nil {
		for i, it := range p.Entity.Inventory.Items {
			if _, err := tx.Exec(
				`INSERT INTO character_inventory (character_name, slot_index, item_id, qty)
				 VALUES ($1,$2,$3,$4)`,
				name, i, it.ID, it.Qty); err != nil {
				_ = tx.Rollback()
				log.Printf("postgres save inventory item %s: %v", name, err)
				return
			}
		}
	}
	if _, err := tx.Exec(`DELETE FROM character_equipped WHERE character_name=$1`, name); err != nil {
		_ = tx.Rollback()
		log.Printf("postgres save equipped clear %s: %v", name, err)
		return
	}
	for slot, ref := range p.Equipped {
		if _, err := tx.Exec(
			`INSERT INTO character_equipped (character_name, slot, item_id)
			 VALUES ($1,$2,$3)`,
			name, slot, ref.ID); err != nil {
			_ = tx.Rollback()
			log.Printf("postgres save equipped %s: %v", name, err)
			return
		}
	}
	if err := tx.Commit(); err != nil {
		log.Printf("postgres save inventory commit %s: %v", name, err)
	}
}

// LoadEquipped returns the equipped slot map for a character.
func (d *DB) LoadEquipped(name string) map[string]ItemRef {
	out := make(map[string]ItemRef)
	if d.conn == nil {
		return out
	}
	rows, err := d.conn.Query(
		`SELECT slot, item_id FROM character_equipped WHERE character_name=$1`, name)
	if err != nil {
		log.Printf("postgres load equipped %s: %v", name, err)
		return out
	}
	defer rows.Close()
	for rows.Next() {
		var slot, id string
		if err := rows.Scan(&slot, &id); err == nil {
			out[slot] = ItemRef{ID: id, Qty: 1}
		}
	}
	return out
}

// LoadQuests returns the persisted quest states for a character.
// The progress column is a JSONB-encoded []int; missing or malformed
// values fall back to a fresh slice so an old row keeps loading.
func (d *DB) LoadQuests(name string) []*QuestState {
	if d.conn == nil {
		return nil
	}
	rows, err := d.conn.Query(
		`SELECT quest_id, stage, kill_count, done, COALESCE(progress::text, '[]')
		   FROM character_quests WHERE character_name=$1`, name)
	if err != nil {
		log.Printf("postgres load quests %s: %v", name, err)
		return nil
	}
	defer rows.Close()
	var out []*QuestState
	for rows.Next() {
		var qs QuestState
		var progRaw string
		if err := rows.Scan(&qs.ID, &qs.Stage, &qs.KillCount, &qs.Done, &progRaw); err != nil {
			continue
		}
		if progRaw != "" && progRaw != "[]" {
			_ = json.Unmarshal([]byte(progRaw), &qs.Progress)
		}
		cp := qs
		out = append(out, &cp)
	}
	return out
}

// SaveQuest upserts a single quest state including the multi-objective
// progress vector.
func (d *DB) SaveQuest(name string, qs *QuestState) {
	if d.conn == nil || qs == nil {
		return
	}
	progRaw, err := json.Marshal(qs.Progress)
	if err != nil {
		progRaw = []byte("[]")
	}
	_, err = d.conn.Exec(`
		INSERT INTO character_quests (character_name, quest_id, stage, kill_count, done, progress)
		VALUES ($1,$2,$3,$4,$5,$6::jsonb)
		ON CONFLICT (character_name, quest_id) DO UPDATE SET
			stage=$3, kill_count=$4, done=$5, progress=$6::jsonb
	`, name, qs.ID, qs.Stage, qs.KillCount, qs.Done, string(progRaw))
	if err != nil {
		log.Printf("postgres save quest %s/%s: %v", name, qs.ID, err)
	}
}

func (d *DB) LoadLearnedSkills(character string) []string {
	if d.conn == nil {
		return nil
	}
	rows, err := d.conn.Query(
		`SELECT skill_id FROM character_learned_skills WHERE character_name=$1`,
		character)
	if err != nil {
		log.Printf("postgres load learned %s: %v", character, err)
		return nil
	}
	defer rows.Close()
	var out []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err == nil {
			out = append(out, id)
		}
	}
	return out
}

func (d *DB) LearnSkill(character, skillID string) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(
		`INSERT INTO character_learned_skills (character_name, skill_id)
		 VALUES ($1, $2)
		 ON CONFLICT DO NOTHING`,
		character, skillID)
	if err != nil {
		log.Printf("postgres learn %s/%s: %v", character, skillID, err)
	}
}

func (d *DB) ResetLearnedSkills(character string) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(
		`DELETE FROM character_learned_skills WHERE character_name=$1`,
		character)
	if err != nil {
		log.Printf("postgres reset learned %s: %v", character, err)
	}
}

func (d *DB) SaveSkillPoints(character string, pts int) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(
		`UPDATE players SET skill_points=$2, updated_at=NOW() WHERE name=$1`,
		character, pts)
	if err != nil {
		log.Printf("postgres save skill_points %s: %v", character, err)
	}
}

func (d *DB) Save(name string, hp, maxHp, mp, maxMp, kills, x, y int) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(`
		UPDATE players
		   SET hp=$2, max_hp=$3, mp=$4, max_mp=$5, kills=$6,
		       last_x=$7, last_y=$8, updated_at=NOW()
		 WHERE name=$1
	`, name, hp, maxHp, mp, maxMp, kills, x, y)
	if err != nil {
		log.Printf("postgres save %s: %v", name, err)
	}
}

type SpellRecord struct {
	ID         string
	Name       string
	Kind       string
	Effect     string
	Range      int
	Radius     int
	Power      int
	ManaCost   int
	CooldownMs int
	R, G, B    int
}

func (d *DB) LoadSpells(character string) []SpellRecord {
	if d.conn == nil {
		return nil
	}
	rows, err := d.conn.Query(`
		SELECT spell_id, name, kind, effect, range_val, radius, power,
		       mana_cost, cooldown_ms, color_r, color_g, color_b
		  FROM character_spells
		 WHERE character_name=$1
		 ORDER BY updated_at`, character)
	if err != nil {
		log.Printf("postgres load spells %s: %v", character, err)
		return nil
	}
	defer rows.Close()
	var out []SpellRecord
	for rows.Next() {
		var s SpellRecord
		if err := rows.Scan(&s.ID, &s.Name, &s.Kind, &s.Effect,
			&s.Range, &s.Radius, &s.Power, &s.ManaCost, &s.CooldownMs,
			&s.R, &s.G, &s.B); err != nil {
			log.Printf("postgres scan spell %s: %v", character, err)
			continue
		}
		out = append(out, s)
	}
	return out
}

func (d *DB) UpsertSpell(character string, s SpellRecord) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(`
		INSERT INTO character_spells (
			character_name, spell_id, name, kind, effect,
			range_val, radius, power, mana_cost, cooldown_ms,
			color_r, color_g, color_b, updated_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13, NOW())
		ON CONFLICT (character_name, spell_id) DO UPDATE SET
			name=$3, kind=$4, effect=$5,
			range_val=$6, radius=$7, power=$8, mana_cost=$9, cooldown_ms=$10,
			color_r=$11, color_g=$12, color_b=$13,
			updated_at=NOW()
	`, character, s.ID, s.Name, s.Kind, s.Effect,
		s.Range, s.Radius, s.Power, s.ManaCost, s.CooldownMs,
		s.R, s.G, s.B)
	if err != nil {
		log.Printf("postgres upsert spell %s/%s: %v", character, s.ID, err)
	}
}

func (d *DB) DeleteSpell(character, id string) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(
		`DELETE FROM character_spells WHERE character_name=$1 AND spell_id=$2`,
		character, id)
	if err != nil {
		log.Printf("postgres delete spell %s/%s: %v", character, id, err)
	}
}
