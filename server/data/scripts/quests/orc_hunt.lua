-- "Orc Hunt": kill 3 orcs and turn in 3 teeth for XP + gold + loot.
-- The objective fields are read by the quest tracker in npc_runtime.go;
-- the kill counter advances in trackKillForQuests when an enemy whose
-- kind matches `objective.kill` is slain.
return {
  id   = "orc_hunt",
  name = "Caça aos Orcs",
  description = "Os orcs voltaram da floresta — caçar 3 deles e trazer 3 dentes prova que a vila está protegida.",
  giver = "elder",
  objective = {
    kill        = "orc",
    count       = 3,
    item        = "orc_tooth",
    item_count  = 3,
  },
  reward = {
    xp    = 150,
    gold  = 50,
    items = {
      { id = "rusty_sword",   qty = 1 },
      { id = "leather_boots", qty = 1 },
      { id = "health_potion", qty = 3 },
    },
  },
  intro       = "A vila conta com você. Boa sorte na caçada.",
  in_progress = "Os orcs ainda rondam o limite da floresta.",
  complete    = "A vila te honra. Aceite estes itens como prova.",
}
