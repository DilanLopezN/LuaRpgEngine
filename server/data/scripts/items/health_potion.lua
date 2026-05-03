-- Stackable consumable. Drinking restores HP via the on_use payload —
-- handleUseItem runs server-side and replies with a fresh STATS frame.
return {
  id          = "health_potion",
  name        = "Poção de Vida",
  type        = "consumable",
  stack       = 99,
  rarity      = "common",
  bound       = false,
  sprite      = "icon_potion_red",
  description = "Recupera 25 de HP ao beber.",
  value       = 5,
  on_use      = { heal_hp = 25 },
}
