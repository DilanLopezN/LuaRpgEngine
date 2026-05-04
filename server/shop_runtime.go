package main

import (
	"encoding/json"
	"fmt"
	"path/filepath"
	"sync"
	"time"
)

// Phase 3 — Shop / Mercador.
//
// A shop is a content piece authored either via the in-game editor
// (data/scripts/shops_user/<id>.json) or hand-crafted JSON. NPCs whose
// Role == merchant point at a shop id; opening a dialog with one fires
// SHOP_OPEN with the catalog. Buy decrements live stock; sell pays the
// player according to BuyMultiplier × ItemDef.Value.
//
// Stock state is per-server-process (not per-player) and lives in
// Game.shopStocks. Restock timers fire opportunistically inside
// handleShopBuy / openShop so the system stays single-tick — no
// dedicated goroutine needed.

// shopRuntime tracks the live stock per shop entry. Index aligns with
// ShopDef.Items. RestockAt is the next time the stock counter should
// be refilled to the def's max for that slot; zero means "no restock
// scheduled" (either Qty == 0 → infinite, or RestockSec == 0 → never).
type shopRuntime struct {
	mu        sync.Mutex
	stock     []int
	restockAt []time.Time
	max       []int
	restock   []time.Duration
}

func newShopRuntime(def *ShopDef) *shopRuntime {
	r := &shopRuntime{
		stock:     make([]int, len(def.Items)),
		restockAt: make([]time.Time, len(def.Items)),
		max:       make([]int, len(def.Items)),
		restock:   make([]time.Duration, len(def.Items)),
	}
	for i, it := range def.Items {
		r.stock[i] = it.Qty
		r.max[i] = it.Qty
		if it.RestockSec > 0 {
			r.restock[i] = time.Duration(it.RestockSec) * time.Second
		}
	}
	return r
}

// applyRestock refills any slot whose RestockAt has elapsed. Caller
// must hold r.mu.
func (r *shopRuntime) applyRestock(now time.Time) {
	for i := range r.stock {
		if r.restock[i] <= 0 {
			continue
		}
		if r.max[i] <= 0 {
			continue
		}
		if r.stock[i] >= r.max[i] {
			r.restockAt[i] = time.Time{}
			continue
		}
		if !r.restockAt[i].IsZero() && now.After(r.restockAt[i]) {
			r.stock[i] = r.max[i]
			r.restockAt[i] = time.Time{}
		}
	}
}

// take attempts to decrement n units from slot i. Returns true on
// success. A slot whose max is zero is treated as infinite stock.
// Caller must hold r.mu.
func (r *shopRuntime) take(i, n int, now time.Time) bool {
	if i < 0 || i >= len(r.stock) || n <= 0 {
		return false
	}
	if r.max[i] <= 0 {
		return true
	}
	if r.stock[i] < n {
		return false
	}
	r.stock[i] -= n
	if r.restock[i] > 0 && r.restockAt[i].IsZero() {
		r.restockAt[i] = now.Add(r.restock[i])
	}
	return true
}

// stockSnapshot returns the slot's current (qty, max) for wire payload.
func (r *shopRuntime) stockSnapshot() ([]int, []int) {
	out := make([]int, len(r.stock))
	mx := make([]int, len(r.max))
	copy(out, r.stock)
	copy(mx, r.max)
	return out, mx
}

func (g *Game) loadShop(id string) (*ShopDef, error) {
	p := filepath.Join(scriptsRoot(), "shops_user", sanitizeNPCID(id)+".json")
	return LoadUserShopJSON(p)
}

// shopRuntimeFor returns (and lazily creates) the live runtime state
// for a shop. The ShopDef is reloaded on every miss so editor saves
// take effect on next open without a server restart. Caller MUST NOT
// hold g.mu.
func (g *Game) shopRuntimeFor(def *ShopDef) *shopRuntime {
	g.mu.Lock()
	if g.shopStocks == nil {
		g.shopStocks = make(map[string]*shopRuntime)
	}
	r, ok := g.shopStocks[def.ID]
	if !ok || len(r.stock) != len(def.Items) {
		r = newShopRuntime(def)
		g.shopStocks[def.ID] = r
	}
	g.mu.Unlock()
	return r
}

// shopWireFrame builds the JSON payload for SHOP_OPEN / SHOP_UPDATE.
// Stock and max are interleaved so the client can render either an
// "X / Y" badge or a plain quantity for infinite-stock entries.
func shopWireFrame(def *ShopDef, r *shopRuntime) string {
	type wireItem struct {
		ItemID string `json:"item_id"`
		Qty    int    `json:"qty"`
		Max    int    `json:"max"`
		Price  int    `json:"price"`
	}
	type wireDef struct {
		ID            string     `json:"id"`
		Name          string     `json:"name"`
		Items         []wireItem `json:"items"`
		BuyMultiplier float64    `json:"buy_multiplier"`
	}
	out := wireDef{
		ID:            def.ID,
		Name:          def.Name,
		BuyMultiplier: def.BuyMultiplier,
	}
	stock, mx := r.stockSnapshot()
	out.Items = make([]wireItem, len(def.Items))
	for i, it := range def.Items {
		out.Items[i] = wireItem{
			ItemID: it.ItemID,
			Qty:    stock[i],
			Max:    mx[i],
			Price:  it.Price,
		}
	}
	b, _ := json.Marshal(out)
	return string(b)
}

func (g *Game) openShop(p *Player, id string) {
	sh, err := g.loadShop(id)
	if err != nil || sh == nil {
		sendNow(p.Out, "SYS shop indisponível: "+id+"\n")
		return
	}
	r := g.shopRuntimeFor(sh)
	now := time.Now()
	r.mu.Lock()
	r.applyRestock(now)
	frame := shopWireFrame(sh, r)
	r.mu.Unlock()

	g.mu.Lock()
	p.OpenShop = sh.ID
	g.mu.Unlock()

	sendNow(p.Out, fmt.Sprintf("SHOP_OPEN %s %s\n", sh.ID, frame))
}

// handleShopClose clears the player's open-shop binding. The server-side
// flag is what gates SHOP_BUY / SHOP_SELL — without it, a malicious
// client could buy from a shop without ever opening it.
func (g *Game) handleShopClose(p *Player) {
	g.mu.Lock()
	p.OpenShop = ""
	g.mu.Unlock()
	sendNow(p.Out, "SHOP_CLOSE\n")
}

// handleShopBuy purchases qty units of slot[slotIdx] from the named
// shop. The transaction is fully validated server-side: the player
// must have the shop open, gold for the cost, the slot must exist,
// the item def must be loadable, and the stock must allow it.
func (g *Game) handleShopBuy(p *Player, shopID string, slotIdx, qty int) {
	if qty <= 0 {
		qty = 1
	}
	sh, err := g.loadShop(shopID)
	if err != nil || sh == nil {
		return
	}
	if slotIdx < 0 || slotIdx >= len(sh.Items) {
		return
	}
	it := sh.Items[slotIdx]
	if it.Price < 0 {
		return
	}
	if g.scripts == nil {
		return
	}
	def, ok := g.scripts.Item(it.ItemID)
	if !ok {
		return
	}
	r := g.shopRuntimeFor(sh)
	now := time.Now()

	g.mu.Lock()
	if p.OpenShop != sh.ID {
		g.mu.Unlock()
		return
	}
	cost := it.Price * qty
	if p.Gold < cost {
		out := p.Out
		g.mu.Unlock()
		sendNow(out, "SYS Gold insuficiente.\n")
		return
	}
	g.mu.Unlock()

	r.mu.Lock()
	r.applyRestock(now)
	if !r.take(slotIdx, qty, now) {
		frame := shopWireFrame(sh, r)
		r.mu.Unlock()
		sendNow(p.Out, "SYS Estoque esgotado.\n")
		sendNow(p.Out, fmt.Sprintf("SHOP_UPDATE %s %s\n", sh.ID, frame))
		return
	}
	r.mu.Unlock()

	g.mu.Lock()
	added := g.addItem(p, def, qty)
	if added < qty {
		// Inventory hit capacity — refund unaccepted units to the shop
		// stock (so the slot doesn't lose product) and to the player's
		// gold delta below. We never partially charge.
		r.mu.Lock()
		if r.max[slotIdx] > 0 {
			r.stock[slotIdx] += (qty - added)
			if r.stock[slotIdx] > r.max[slotIdx] {
				r.stock[slotIdx] = r.max[slotIdx]
			}
		}
		r.mu.Unlock()
		if added <= 0 {
			out := p.Out
			g.mu.Unlock()
			sendNow(out, "SYS Inventário cheio.\n")
			r.mu.Lock()
			frame := shopWireFrame(sh, r)
			r.mu.Unlock()
			sendNow(out, fmt.Sprintf("SHOP_UPDATE %s %s\n", sh.ID, frame))
			return
		}
		cost = it.Price * added
	}
	p.Gold -= cost
	inv := inventoryWire(p)
	stats := characterStatsLocked(p)
	out := p.Out
	g.mu.Unlock()

	r.mu.Lock()
	frame := shopWireFrame(sh, r)
	r.mu.Unlock()

	sendNow(out, inv)
	sendNow(out, stats)
	sendNow(out, fmt.Sprintf("SHOP_UPDATE %s %s\n", sh.ID, frame))
}

// handleShopSell pays the player for qty units of inventory slot
// invSlotIdx, valued at BuyMultiplier × ItemDef.Value. The shop must
// be open server-side to gate "sell into nothing" abuse.
func (g *Game) handleShopSell(p *Player, invSlotIdx, qty int) {
	if qty <= 0 {
		qty = 1
	}
	g.mu.Lock()
	if p.OpenShop == "" {
		g.mu.Unlock()
		return
	}
	shopID := p.OpenShop
	if p.Entity == nil || p.Entity.Inventory == nil ||
		invSlotIdx < 0 || invSlotIdx >= len(p.Entity.Inventory.Items) {
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
	if def.Bound {
		out := p.Out
		g.mu.Unlock()
		sendNow(out, "SYS Item vinculado não pode ser vendido.\n")
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
	g.mu.Unlock()

	// BuyMultiplier lives on the shop def; reload to get the current
	// value (the editor may have tweaked it since last open).
	mult := 0.5
	if sh, err := g.loadShop(shopID); err == nil && sh != nil &&
		sh.BuyMultiplier > 0 {
		mult = sh.BuyMultiplier
	}
	price := def.Value
	if price <= 0 {
		price = 1
	}
	pay := int(float64(price*removed) * mult)
	if pay <= 0 {
		pay = removed // never pay less than 1g per item sold
	}

	g.mu.Lock()
	p.Gold += pay
	inv := inventoryWire(p)
	stats := characterStatsLocked(p)
	out := p.Out
	g.mu.Unlock()

	sendNow(out, inv)
	sendNow(out, stats)
	// Echo SHOP_UPDATE so the UI can refresh the gold badge / stock
	// view in one round-trip.
	if sh, err := g.loadShop(shopID); err == nil && sh != nil {
		r := g.shopRuntimeFor(sh)
		r.mu.Lock()
		frame := shopWireFrame(sh, r)
		r.mu.Unlock()
		sendNow(out, fmt.Sprintf("SHOP_UPDATE %s %s\n", sh.ID, frame))
	}
}
