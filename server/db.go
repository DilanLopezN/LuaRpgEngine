package main

import (
	"database/sql"
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
	HP, MaxHP int
	MP, MaxMP int
	Kills     int
	X, Y      int
}

func (d *DB) LoadOrCreate(name string) PlayerRecord {
	rec := PlayerRecord{
		HP: 100, MaxHP: 100,
		MP: 100, MaxMP: 100,
		Kills: 0, X: 10, Y: 10,
	}
	if d.conn == nil {
		return rec
	}
	err := d.conn.QueryRow(
		`SELECT hp, max_hp, mp, max_mp, kills, last_x, last_y
		   FROM players WHERE name=$1`, name,
	).Scan(&rec.HP, &rec.MaxHP, &rec.MP, &rec.MaxMP, &rec.Kills, &rec.X, &rec.Y)
	if err == sql.ErrNoRows {
		_, _ = d.conn.Exec(`INSERT INTO players(name) VALUES($1)`, name)
		return rec
	}
	if err != nil {
		log.Printf("postgres load %s: %v", name, err)
	}
	return rec
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
