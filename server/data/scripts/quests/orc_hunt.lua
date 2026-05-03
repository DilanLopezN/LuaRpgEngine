-- "Orc Hunt": kill 3 orcs and turn in 3 teeth for XP + gold + a sword.
-- The objective fields are read by the quest tracker in npc_runtime.go;
-- the kill counter advances in trackKillForQuests when an enemy whose
-- kind matches `objective.kill` is slain.
return {
  id   = "orc_hunt",
  name = "Orc Hunt",
  description = "Os orcs voltaram da floresta — caçar 3 deles e trazer 3 dentes prova que a vila está protegida.",
  giver = "elder",
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
  intro       = "A vila conta com você. Boa sorte na caçada.",
  in_progress = "Os orcs ainda rondam o limite da floresta.",
  complete    = "A vila te honra. Aceite esta espada como prova.",
}
