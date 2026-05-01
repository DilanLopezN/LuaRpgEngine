-- Self-heal. Useful both as a gameplay tool and as a smoke test for
-- the heal handler / mana cost validation path.
return {
  id        = "heal",
  name      = "Heal",
  type      = "heal",
  mana_cost = 25,
  cooldown  = 4.0,
  effects = {
    { type = "heal", value = 40 },
  },
}
