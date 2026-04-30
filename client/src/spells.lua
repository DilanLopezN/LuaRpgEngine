-- Spell registry. Must mirror the server-side definitions in game.go so the
-- client can run animations and validate input optimistically.

local M = {}

M.list = {
    { id = "fireball",  kind = "line", range = 6,  manaCost = 15, cooldown = 0.7,
      color = { 0.95, 0.35, 0.10 }, label = "Fire" },
    { id = "frostbolt", kind = "line", range = 5,  manaCost = 10, cooldown = 0.5,
      color = { 0.40, 0.80, 1.00 }, label = "Frost" },
    { id = "lightning", kind = "line", range = 8,  manaCost = 25, cooldown = 1.0,
      color = { 1.00, 0.95, 0.20 }, label = "Bolt" },
    { id = "explosion", kind = "area", radius = 2, manaCost = 30, cooldown = 1.5,
      color = { 1.00, 0.55, 0.00 }, label = "Boom" },
    { id = "icenova",   kind = "area", radius = 1, manaCost = 20, cooldown = 0.8,
      color = { 0.65, 0.85, 1.00 }, label = "Nova" },
}

M.byId = {}
for _, s in ipairs(M.list) do M.byId[s.id] = s end

return M
