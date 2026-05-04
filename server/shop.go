package main

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"strings"
)

type ShopItem struct {
	ItemID     string `json:"item_id"`
	Qty        int    `json:"qty"`
	Price      int    `json:"price"`
	RestockSec int    `json:"restock_sec,omitempty"`
}
type ShopDef struct {
	ID            string     `json:"id"`
	Name          string     `json:"name"`
	Items         []ShopItem `json:"items"`
	BuyMultiplier float64    `json:"buy_multiplier,omitempty"`
}

func userShopDir(root string) string { return filepath.Join(root, "shops_user") }

func LoadUserShopJSON(path string) (*ShopDef, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var d ShopDef
	if err := json.Unmarshal(b, &d); err != nil {
		return nil, err
	}
	if d.ID == "" {
		d.ID = strings.TrimSuffix(filepath.Base(path), ".json")
	}
	if d.BuyMultiplier <= 0 {
		d.BuyMultiplier = 0.5
	}
	return &d, nil
}
func SaveUserShopDef(root string, d *ShopDef) error {
	if d == nil || d.ID == "" {
		return errors.New("shop id required")
	}
	c := sanitizeNPCID(d.ID)
	if c == "" {
		return errors.New("invalid shop id")
	}
	if d.BuyMultiplier <= 0 {
		d.BuyMultiplier = 0.5
	}
	dir := userShopDir(root)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	b, err := json.MarshalIndent(d, "", "  ")
	if err != nil {
		return err
	}
	p := filepath.Join(dir, c+".json")
	tmp := p + ".tmp"
	if err := os.WriteFile(tmp, b, 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, p)
}
