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
	if _, err := conn.Exec(`
		CREATE TABLE IF NOT EXISTS players (
			name        TEXT PRIMARY KEY,
			hp          INTEGER NOT NULL DEFAULT 100,
			kills       INTEGER NOT NULL DEFAULT 0,
			last_x      INTEGER NOT NULL DEFAULT 10,
			last_y      INTEGER NOT NULL DEFAULT 10,
			created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)
	`); err != nil {
		log.Printf("postgres schema init failed: %v", err)
	}
	log.Printf("postgres connected")
	return &DB{conn: conn}
}

type PlayerRecord struct {
	HP    int
	Kills int
	X, Y  int
}

func (d *DB) LoadOrCreate(name string) PlayerRecord {
	rec := PlayerRecord{HP: 100, Kills: 0, X: 10, Y: 10}
	if d.conn == nil {
		return rec
	}
	err := d.conn.QueryRow(
		`SELECT hp, kills, last_x, last_y FROM players WHERE name=$1`, name,
	).Scan(&rec.HP, &rec.Kills, &rec.X, &rec.Y)
	if err == sql.ErrNoRows {
		_, _ = d.conn.Exec(`INSERT INTO players(name) VALUES($1)`, name)
		return rec
	}
	if err != nil {
		log.Printf("postgres load %s: %v", name, err)
	}
	return rec
}

func (d *DB) Save(name string, hp, kills, x, y int) {
	if d.conn == nil {
		return
	}
	_, err := d.conn.Exec(`
		UPDATE players SET hp=$2, kills=$3, last_x=$4, last_y=$5, updated_at=NOW()
		WHERE name=$1
	`, name, hp, kills, x, y)
	if err != nil {
		log.Printf("postgres save %s: %v", name, err)
	}
}
