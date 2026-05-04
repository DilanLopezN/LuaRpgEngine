return {
  id          = "mana_potion",
  name        = "Poção de Mana",
  type        = "consumable",
  stack       = 99,
  rarity      = "common",
  sprite      = "icon_potion_blue",
  description = "Recupera 30 de MP ao beber.",
  value       = 8,
  on_use      = { heal_mp = 30 },
}
