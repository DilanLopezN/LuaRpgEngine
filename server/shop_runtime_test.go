package main

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

// shopTestSetup wires a Game with a single-shop fixture: one entry
// (potion @5g, qty=3, restock 60s) and an item def in the script
// engine. Returns the player, shop id, and a cleanup hook.
func shopTestSetup(t *testing.T, def *ItemDef, shop *ShopDef) (*Game, *Player, string) {
	t.Helper()
	root := t.TempDir()
	t.Setenv("SCRIPTS_DIR", root)

	g := newTestGame(t)
	g.scripts = NewScriptEngine(root)
	g.scripts.items[def.ID] = def

	if err := SaveUserShopDef(root, shop); err != nil {
		t.Fatalf("save shop: %v", err)
	}
	if _, err := os.Stat(filepath.Join(root, "shops_user",
		sanitizeNPCID(shop.ID)+".json")); err != nil {
		t.Fatalf("shop file missing: %v", err)
	}
	p := newInventoryTestPlayer(g)
	p.Gold = 100
	p.OpenShop = shop.ID
	return g, p, shop.ID
}

func TestShopBuyDeductsGoldAndAddsItem(t *testing.T) {
	def := &ItemDef{ID: "potion", Stack: 99, Value: 4}
	shop := &ShopDef{
		ID: "village_shop", Name: "Vila",
		BuyMultiplier: 0.5,
		Items: []ShopItem{{ItemID: "potion", Qty: 3, Price: 10}},
	}
	g, p, sid := shopTestSetup(t, def, shop)

	g.handleShopBuy(p, sid, 0, 2)

	if p.Gold != 80 {
		t.Fatalf("gold: want 80, got %d", p.Gold)
	}
	if len(p.Entity.Inventory.Items) != 1 ||
		p.Entity.Inventory.Items[0].Qty != 2 {
		t.Fatalf("inventory not credited: %+v", p.Entity.Inventory.Items)
	}
	r := g.shopStocks[sid]
	if r == nil || r.stock[0] != 1 {
		t.Fatalf("stock should drop to 1, got %+v", r)
	}
}

func TestShopBuyRejectsInsufficientGold(t *testing.T) {
	def := &ItemDef{ID: "potion", Stack: 99, Value: 4}
	shop := &ShopDef{
		ID: "village_shop", Name: "Vila",
		BuyMultiplier: 0.5,
		Items: []ShopItem{{ItemID: "potion", Qty: 3, Price: 200}},
	}
	g, p, sid := shopTestSetup(t, def, shop)
	p.Gold = 50

	g.handleShopBuy(p, sid, 0, 1)

	if p.Gold != 50 {
		t.Fatalf("gold should not change, got %d", p.Gold)
	}
	if len(p.Entity.Inventory.Items) != 0 {
		t.Fatalf("no item should be added")
	}
}

func TestShopBuyRejectsClosedShop(t *testing.T) {
	def := &ItemDef{ID: "potion", Stack: 99, Value: 4}
	shop := &ShopDef{
		ID: "village_shop", Name: "Vila",
		Items: []ShopItem{{ItemID: "potion", Qty: 3, Price: 10}},
	}
	g, p, sid := shopTestSetup(t, def, shop)
	p.OpenShop = "" // simulate "shop never opened"

	g.handleShopBuy(p, sid, 0, 1)

	if p.Gold != 100 {
		t.Fatalf("gold must not move when shop is closed, got %d", p.Gold)
	}
	if len(p.Entity.Inventory.Items) != 0 {
		t.Fatalf("must not credit inventory when shop is closed")
	}
}

func TestShopBuyEmptyStockRefuses(t *testing.T) {
	def := &ItemDef{ID: "potion", Stack: 99, Value: 4}
	shop := &ShopDef{
		ID: "shop", Name: "X",
		Items: []ShopItem{{ItemID: "potion", Qty: 1, Price: 10}},
	}
	g, p, sid := shopTestSetup(t, def, shop)

	g.handleShopBuy(p, sid, 0, 1) // empties stock
	if p.Gold != 90 {
		t.Fatalf("first buy: gold=%d want 90", p.Gold)
	}
	g.handleShopBuy(p, sid, 0, 1) // should refuse
	if p.Gold != 90 {
		t.Fatalf("empty stock buy must not charge, gold=%d", p.Gold)
	}
}

func TestShopRestockRefillsAfterTimer(t *testing.T) {
	def := &ItemDef{ID: "potion", Stack: 99, Value: 4}
	shop := &ShopDef{
		ID: "shop", Name: "X",
		Items: []ShopItem{{ItemID: "potion", Qty: 2, Price: 10, RestockSec: 1}},
	}
	g, p, sid := shopTestSetup(t, def, shop)
	g.handleShopBuy(p, sid, 0, 2) // empty stock

	r := g.shopStocks[sid]
	if r.stock[0] != 0 {
		t.Fatalf("stock should be 0 after buy, got %d", r.stock[0])
	}
	// Force the restock timer into the past and trigger applyRestock.
	r.mu.Lock()
	r.restockAt[0] = time.Now().Add(-2 * time.Second)
	r.applyRestock(time.Now())
	got := r.stock[0]
	r.mu.Unlock()
	if got != 2 {
		t.Fatalf("restock should refill to 2, got %d", got)
	}
}

func TestShopSellAppliesBuyMultiplier(t *testing.T) {
	def := &ItemDef{ID: "potion", Stack: 99, Value: 10}
	shop := &ShopDef{
		ID: "shop", Name: "X",
		BuyMultiplier: 0.4,
		Items:         []ShopItem{{ItemID: "potion", Qty: 0, Price: 10}},
	}
	g, p, sid := shopTestSetup(t, def, shop)
	g.addItem(p, def, 5)

	g.handleShopSell(p, 0, 5)
	_ = sid

	// 5 × 10 × 0.4 = 20 gold
	if p.Gold != 120 {
		t.Fatalf("sell pay: want 120, got %d", p.Gold)
	}
	if len(p.Entity.Inventory.Items) != 0 {
		t.Fatalf("inventory should be drained after sell")
	}
}

func TestShopSellRefusesBoundItems(t *testing.T) {
	def := &ItemDef{ID: "soulbind", Stack: 1, Value: 100, Bound: true}
	shop := &ShopDef{
		ID: "shop", Name: "X",
		Items: []ShopItem{{ItemID: "soulbind", Qty: 0, Price: 10}},
	}
	g, p, _ := shopTestSetup(t, def, shop)
	g.addItem(p, def, 1)

	g.handleShopSell(p, 0, 1)

	if p.Gold != 100 {
		t.Fatalf("bound item must not pay out, gold=%d", p.Gold)
	}
	if len(p.Entity.Inventory.Items) != 1 {
		t.Fatalf("bound item must stay in inventory")
	}
}
