package main

import (
	"encoding/json"
	"fmt"
	"path/filepath"
)

func (g *Game) loadShop(id string) (*ShopDef, error) {
	p := filepath.Join(scriptsRoot(), "shops_user", sanitizeNPCID(id)+".json")
	return LoadUserShopJSON(p)
}

func (g *Game) openShop(p *Player, id string) {
	sh, err := g.loadShop(id)
	if err != nil || sh == nil {
		return
	}
	b, _ := json.Marshal(sh)
	sendNow(p.Out, fmt.Sprintf("SHOP_OPEN %s %s\n", sh.ID, string(b)))
}

func (g *Game) handleShopBuy(p *Player, shopID string, slotIdx, qty int) {
	if qty <= 0 {
		qty = 1
	}
	sh, err := g.loadShop(shopID)
	if err != nil || sh == nil || slotIdx < 0 || slotIdx >= len(sh.Items) {
		return
	}
	it := sh.Items[slotIdx]
	cost := it.Price * qty
	g.mu.Lock()
	if p.Gold < cost {
		g.mu.Unlock()
		return
	}
	if g.scripts == nil {
		g.mu.Unlock()
		return
	}
	def, ok := g.scripts.Item(it.ItemID)
	if !ok {
		g.mu.Unlock()
		return
	}
	p.Gold -= cost
	g.addItem(p, def, qty)
	inv := inventoryWire(p)
	stats := characterStatsLocked(p)
	g.mu.Unlock()
	sendNow(p.Out, inv)
	sendNow(p.Out, stats)
}

func (g *Game) handleShopSell(p *Player, invSlotIdx, qty int) {
	if qty <= 0 {
		qty = 1
	}
	g.mu.Lock()
	if p.Entity == nil || p.Entity.Inventory == nil || invSlotIdx < 0 || invSlotIdx >= len(p.Entity.Inventory.Items) {
		g.mu.Unlock()
		return
	}
	stack := p.Entity.Inventory.Items[invSlotIdx]
	if g.scripts == nil {
		g.mu.Unlock()
		return
	}
	def, ok := g.scripts.Item(stack.ID)
	if !ok {
		g.mu.Unlock()
		return
	}
	if qty > stack.Qty {
		qty = stack.Qty
	}
	removed := g.removeItem(p, stack.ID, qty)
	if removed <= 0 {
		g.mu.Unlock()
		return
	}
	price := def.Value
	if price <= 0 {
		price = 1
	}
	p.Gold += int(float64(price*removed) * 0.5)
	inv := inventoryWire(p)
	stats := characterStatsLocked(p)
	g.mu.Unlock()
	sendNow(p.Out, inv)
	sendNow(p.Out, stats)
}
