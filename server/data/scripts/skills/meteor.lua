-- Meteor: high-tier AoE that requires fireball in the tree. Lands a
-- damage tick plus a longer burn so positioning matters.
return {
  id        = "meteor",
  name      = "Meteor",
  type      = "area",
  damage    = 90,
  mana_cost = 60,
  cooldown  = 8.0,
  range     = 5,
  radius    = 2,
  effects = {
    { type = "damage", value = 90 },
    { type = "apply_status", status = "burn", duration = 5, power = 8 },
  },
}
