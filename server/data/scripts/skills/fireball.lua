-- Fireball: ranged projectile that lands burn DoT on impact.
-- Damage and burn power are tunable here without recompiling Go.
return {
  id        = "fireball",
  name      = "Fireball",
  type      = "projectile",
  damage    = 50,
  mana_cost = 20,
  cooldown  = 2.0,
  range     = 6,
  scaling   = { int = 1.2 },
  effects = {
    { type = "damage", value = 50 },
    { type = "apply_status", status = "burn", duration = 3, power = 5 },
  },
}
