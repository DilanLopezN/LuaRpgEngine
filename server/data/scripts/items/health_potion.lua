-- Stackable consumable. The "stack" cap controls how many copies fit
-- in a single inventory slot; 99 is the convention for potions.
return {
  id     = "health_potion",
  name   = "Health Potion",
  slot   = "none",
  stack  = 99,
  rarity = "common",
  bound  = false,
  attrs  = { hp = 25 },
}
