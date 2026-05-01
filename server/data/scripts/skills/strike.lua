-- Strike: cheap melee opener available from level 1. Acts as the
-- default starting node in the skill tree.
return {
  id        = "strike",
  name      = "Strike",
  type      = "melee",
  damage    = 18,
  mana_cost = 0,
  cooldown  = 0.6,
  range     = 1,
  effects = {
    { type = "damage", value = 18 },
  },
}
