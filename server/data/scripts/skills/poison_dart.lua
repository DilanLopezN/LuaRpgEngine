-- Poison Dart: low up-front damage, heavy DoT. Demonstrates the
-- "debuff" handler (single-target, no friendly fire surface).
return {
  id        = "poison_dart",
  name      = "Poison Dart",
  type      = "debuff",
  mana_cost = 15,
  cooldown  = 3.0,
  range     = 5,
  effects = {
    { type = "damage", value = 8 },
    { type = "apply_status", status = "poison", duration = 6, power = 6 },
  },
}
