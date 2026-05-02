package main

import "testing"

func newInventoryTestPlayer(g *Game) *Player {
	p := addNamedPlayerAt(g, "tester", 5, 5)
	p.Entity = &Entity{
		Kind:      KindPlayer,
		Inventory: &CInventory{Capacity: 4},
	}
	return p
}

func TestAddItemStacks(t *testing.T) {
	g := newTestGame(t)
	p := newInventoryTestPlayer(g)
	def := &ItemDef{ID: "potion", Stack: 99}

	if added := g.addItem(p, def, 50); added != 50 {
		t.Fatalf("first add: want 50, got %d", added)
	}
	if added := g.addItem(p, def, 30); added != 30 {
		t.Fatalf("second add: want 30 (stacks into existing slot), got %d", added)
	}
	if got := len(p.Entity.Inventory.Items); got != 1 {
		t.Fatalf("expected single stacked slot, got %d", got)
	}
	if got := p.Entity.Inventory.Items[0].Qty; got != 80 {
		t.Fatalf("stack qty=%d, want 80", got)
	}
}

func TestAddItemRespectsCapacity(t *testing.T) {
	g := newTestGame(t)
	p := newInventoryTestPlayer(g)
	def := &ItemDef{ID: "sword", Stack: 1}

	for i := 0; i < 4; i++ {
		if added := g.addItem(p, def, 1); added != 1 {
			t.Fatalf("slot %d: add failed", i)
		}
	}
	if added := g.addItem(p, def, 1); added != 0 {
		t.Fatalf("over-cap add should refuse, got %d", added)
	}
	if got := len(p.Entity.Inventory.Items); got != 4 {
		t.Fatalf("inventory should be full at 4, got %d", got)
	}
}

func TestRemoveItemDrainsStacks(t *testing.T) {
	g := newTestGame(t)
	p := newInventoryTestPlayer(g)
	def := &ItemDef{ID: "potion", Stack: 99}
	g.addItem(p, def, 100) // forces a second stack since cap = 99

	if removed := g.removeItem(p, "potion", 60); removed != 60 {
		t.Fatalf("partial remove: want 60, got %d", removed)
	}
	total := 0
	for _, it := range p.Entity.Inventory.Items {
		total += it.Qty
	}
	if total != 40 {
		t.Fatalf("after remove total=%d, want 40", total)
	}

	if removed := g.removeItem(p, "potion", 999); removed != 40 {
		t.Fatalf("drain remove: want 40, got %d", removed)
	}
	if got := len(p.Entity.Inventory.Items); got != 0 {
		t.Fatalf("inventory should be empty, got %d entries", got)
	}
}
