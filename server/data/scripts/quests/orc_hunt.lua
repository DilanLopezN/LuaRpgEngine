-- "Orc Hunt": kill 3 orcs and turn in 3 teeth for XP + gold + a sword.
-- The objective fields are read by the quest tracker in npc_runtime.go;
-- the kill counter advances in trackKillForQuests when an enemy whose
-- kind matches `objective.kill` is slain.
return {
  id   = "orc_hunt",
  name = "Orc Hunt",
  stages = { "active", "complete" },
  objective = {
    kill        = "orc",
    count       = 3,
    item        = "orc_tooth",
    item_count  = 3,
  },
  reward = {
    xp   = 150,
    gold = 50,
    item = "rusty_sword",
    qty  = 1,
  },
}
