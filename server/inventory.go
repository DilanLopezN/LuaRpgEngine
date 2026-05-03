package main

import (
	"fmt"
	"math/rand"
	"strings"
	"time"
)

// Phase 4 — Inventário.
//
// The runtime inventory is a slice of ItemRef stored on the player's
// CInventory component. Stack rules are enforced on insert, slot
// equipping is enforced on EQUIP, and bound items refuse to be
// dropped/traded.
//
// Drops come from Lua: enemy scripts can call drop_item(target, id, qty,
// chance) inside the enemy_killed hook to spawn loot at the kill site.
// The host shovels the loot directly into the killer's inventory; we
// don't model on-ground drops yet (would require a "loot" entity kind),
// the explicit goal at this stage is closing the matar→loot→equip loop.

const (
	inventoryDefaultCap = 32
	dropChanceDenom     = 1000
)

// EquippedSet maps slot → ItemRef the player has equipped. It lives on
// the Player struct (legacy gameplay hub) for now; the ECS Entity
// mirror could absorb it later if equipment ever influences AI.
type EquippedSet map[string]ItemRef

// addItem inserts qty of itemID into p's inventory respecting stack
// caps. Caller must hold g.mu. Returns the actual quantity added (may
// be less than qty if the inventory hits capacity).
func (g *Game) addItem(p *Player, def *ItemDef, qty int) int {
	if def == nil || qty <= 0 || p.Entity == nil || p.Entity.Inventory == nil {
		return 0
	}
	inv := p.Entity.Inventory
	added := 0
	if def.Stack > 1 {
		for i := range inv.Items {
			if inv.Items[i].ID != def.ID {
				continue
			}
			room := def.Stack - inv.Items[i].Qty
			if room <= 0 {
				continue
			}
			take := qty - added
			if take > room {
				take = room
			}
			inv.Items[i].Qty += take
			added += take
			if added >= qty {
				return added
			}
		}
	}
	for added < qty {
		if len(inv.Items) >= inv.Capacity {
			break
		}
		take := qty - added
		if take > def.Stack {
			take = def.Stack
		}
		inv.Items = append(inv.Items, ItemRef{ID: def.ID, Qty: take})
		added += take
	}
	return added
}

// removeItem subtracts qty of itemID. Caller must hold g.mu. Returns
// the actual quantity removed.
func (g *Game) removeItem(p *Player, itemID string, qty int) int {
	if p.Entity == nil || p.Entity.Inventory == nil || qty <= 0 {
		return 0
	}
	inv := p.Entity.Inventory
	removed := 0
	for i := 0; i < len(inv.Items); {
		if inv.Items[i].ID != itemID {
			i++
			continue
		}
		take := qty - removed
		if take > inv.Items[i].Qty {
			take = inv.Items[i].Qty
		}
		inv.Items[i].Qty -= take
		removed += take
		if inv.Items[i].Qty <= 0 {
			inv.Items = append(inv.Items[:i], inv.Items[i+1:]...)
		} else {
			i++
		}
		if removed >= qty {
			break
		}
	}
	return removed
}

// inventoryWire renders the full inventory as a single INV_SET frame
// the client can consume to rebuild its UI. Caller must hold g.mu.
func inventoryWire(p *Player) string {
	if p.Entity == nil || p.Entity.Inventory == nil {
		return "INV_SET 0\n"
	}
	inv := p.Entity.Inventory
	var b strings.Builder
	fmt.Fprintf(&b, "INV_SET %d", len(inv.Items))
	for _, it := range inv.Items {
		fmt.Fprintf(&b, " %s:%d", it.ID, it.Qty)
	}
	b.WriteByte('\n')
	return b.String()
}

// equippedWire ships the equipped set so the UI can paint it on join /
// after EQUIP/UNEQUIP. Caller must hold g.mu.
func equippedWire(p *Player) string {
	var b strings.Builder
	b.WriteString("EQUIP_SET")
	for slot, ref := range p.Equipped {
		fmt.Fprintf(&b, " %s:%s", slot, ref.ID)
	}
	b.WriteByte('\n')
	return b.String()
}

// handleEquip moves an inventory item into the matching slot. If the
// slot is occupied the previous item swaps back into the inventory.
// Two-handed weapons additionally vacate the offhand slot so a player
// can't dual-wield a greatsword and a shield.
func (g *Game) handleEquip(p *Player, itemID string) {
	if g.scripts == nil {
		return
	}
	def, ok := g.scripts.Item(itemID)
	if !ok || !def.IsEquippable() {
		return
	}
	g.mu.Lock()
	if p.Name == "" {
		g.mu.Unlock()
		return
	}
	// Level gate. Mirrors the client's UI hint so a malicious EQUIP
	// cannot bypass it.
	if def.LevelReq > 0 && (p.Stats == nil || p.Stats.Level < def.LevelReq) {
		out := p.Out
		g.mu.Unlock()
		sendNow(out, fmt.Sprintf("SYS Você precisa do nível %d para equipar %s.\n",
			def.LevelReq, def.Name))
		return
	}
	if g.removeItem(p, itemID, 1) <= 0 {
		g.mu.Unlock()
		return
	}
	if p.Equipped == nil {
		p.Equipped = make(EquippedSet)
	}
	// Slots that conflict with the new item — same slot, plus the
	// offhand if the new piece is two-handed (or the new piece IS the
	// offhand and the equipped weapon is two-handed).
	conflicts := []string{def.Slot}
	if def.TwoHanded && def.Slot == "weapon" {
		conflicts = append(conflicts, "offhand")
	}
	if def.Slot == "offhand" {
		if w, has := p.Equipped["weapon"]; has {
			if wdef, ok := g.scripts.Item(w.ID); ok && wdef.TwoHanded {
				conflicts = append(conflicts, "weapon")
			}
		}
	}
	for _, slot := range conflicts {
		if prev, hasPrev := p.Equipped[slot]; hasPrev {
			if pdef, ok := g.scripts.Item(prev.ID); ok {
				g.addItem(p, pdef, prev.Qty)
			}
			delete(p.Equipped, slot)
		}
	}
	p.Equipped[def.Slot] = ItemRef{ID: itemID, Qty: 1}
	invWire := inventoryWire(p)
	eqWire := equippedWire(p)
	statsWire := characterStatsLocked(p)
	out := p.Out
	character := p.Name
	g.mu.Unlock()

	if g.db != nil {
		g.db.SaveInventory(character, p)
	}
	sendNow(out, invWire)
	sendNow(out, eqWire)
	sendNow(out, statsWire)
}

// handleUnequip moves an equipped item back into inventory.
func (g *Game) handleUnequip(p *Player, slot string) {
	g.mu.Lock()
	if p.Name == "" || p.Equipped == nil {
		g.mu.Unlock()
		return
	}
	ref, ok := p.Equipped[slot]
	if !ok {
		g.mu.Unlock()
		return
	}
	delete(p.Equipped, slot)
	if g.scripts != nil {
		if def, ok := g.scripts.Item(ref.ID); ok {
			g.addItem(p, def, ref.Qty)
		}
	}
	invWire := inventoryWire(p)
	eqWire := equippedWire(p)
	statsWire := characterStatsLocked(p)
	out := p.Out
	character := p.Name
	g.mu.Unlock()

	if g.db != nil {
		g.db.SaveInventory(character, p)
	}
	sendNow(out, invWire)
	sendNow(out, eqWire)
	sendNow(out, statsWire)
}

// handleDropItem is the player-facing /drop command counterpart. Since
// the engine doesn't yet model ground items, dropping currently just
// destroys the stack. The wire shape exists so a future "loot bag"
// entity can use it without protocol churn.
func (g *Game) handleDropItem(p *Player, itemID string, qty int) {
	g.mu.Lock()
	if g.scripts != nil {
		if def, ok := g.scripts.Item(itemID); ok && def.Bound {
			g.mu.Unlock()
			return
		}
	}
	removed := g.removeItem(p, itemID, qty)
	if removed <= 0 {
		g.mu.Unlock()
		return
	}
	wire := inventoryWire(p)
	out := p.Out
	character := p.Name
	g.mu.Unlock()
	if g.db != nil && character != "" {
		g.db.SaveInventory(character, p)
	}
	sendNow(out, wire)
}

// handleUseItem consumes one stack of an item and applies its OnUse
// payload (heal HP/MP, apply buff). Non-consumable items silently no-op.
func (g *Game) handleUseItem(p *Player, itemID string) {
	if g.scripts == nil {
		return
	}
	def, ok := g.scripts.Item(itemID)
	if !ok || !def.IsConsumable() {
		return
	}
	g.mu.Lock()
	if p.Name == "" || p.HP <= 0 {
		g.mu.Unlock()
		return
	}
	if def.LevelReq > 0 && (p.Stats == nil || p.Stats.Level < def.LevelReq) {
		out := p.Out
		g.mu.Unlock()
		sendNow(out, fmt.Sprintf("SYS Você precisa do nível %d para usar %s.\n",
			def.LevelReq, def.Name))
		return
	}
	if g.removeItem(p, itemID, 1) <= 0 {
		g.mu.Unlock()
		return
	}
	healHP := def.OnUse.HealHP
	healMP := def.OnUse.HealMP
	if healHP > 0 {
		p.HP += healHP
		if p.HP > p.MaxHP {
			p.HP = p.MaxHP
		}
	}
	if healMP > 0 {
		p.MP += healMP
		if p.MP > p.MaxMP {
			p.MP = p.MaxMP
		}
	}
	pid := p.ID
	buffID := def.OnUse.Buff
	buffMs := def.OnUse.BuffMs
	invWire := inventoryWire(p)
	statsWire := characterStatsLocked(p)
	out := p.Out
	character := p.Name
	g.mu.Unlock()

	if g.db != nil {
		g.db.SaveInventory(character, p)
	}
	sendNow(out, invWire)
	sendNow(out, statsWire)
	if buffID != "" && buffMs > 0 {
		// ApplyStatus reaches gameplay state through its own locks —
		// safe to fire after dropping g.mu.
		g.ApplyStatus(pid, buffID, buffMs, 0)
	}
}

// rollDrop is the host-side primitive Lua scripts call to grant loot.
// Chance is in 1/1000 (so 250 = 25%). Returns true when the drop hit.
// Caller must NOT hold g.mu — this acquires the lock internally.
func (g *Game) rollDrop(killerID int, itemID string, qty, chance int) bool {
	if qty <= 0 || chance <= 0 || g.scripts == nil {
		return false
	}
	def, ok := g.scripts.Item(itemID)
	if !ok {
		return false
	}
	if chance < dropChanceDenom {
		if rand.Intn(dropChanceDenom) >= chance {
			return false
		}
	}
	g.mu.Lock()
	p, ok := g.players[killerID]
	if !ok || p.Name == "" {
		g.mu.Unlock()
		return false
	}
	added := g.addItem(p, def, qty)
	wire := inventoryWire(p)
	out := p.Out
	character := p.Name
	g.mu.Unlock()
	if added <= 0 {
		return false
	}
	if g.db != nil {
		g.db.SaveInventory(character, p)
	}
	sendNow(out, wire)
	sendNow(out, fmt.Sprintf("LOOT %s %d\n", itemID, added))
	return true
}

// sendNow blocks briefly to deliver a one-shot state message instead of
// dropping it on a full channel. The 250ms ceiling matches the
// character-state path so behaviour is consistent.
func sendNow(out chan<- string, msg string) {
	select {
	case out <- msg:
	case <-time.After(250 * time.Millisecond):
	}
}
