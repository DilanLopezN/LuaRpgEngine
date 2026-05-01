-- Skill tree. Each entry maps a skill ID to its prerequisites and
-- point cost. A skill listed here without a Lua file is harmless;
-- the learn flow simply rejects unknown IDs.
return {
  strike      = { requires = {},                 cost = 1 },
  heal        = { requires = {},                 cost = 1 },
  fireball    = { requires = { "strike" },       cost = 2 },
  poison_dart = { requires = { "strike" },       cost = 2 },
  meteor      = { requires = { "fireball" },     cost = 3 },
}
