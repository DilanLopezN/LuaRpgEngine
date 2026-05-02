-- Phase 6 — feedback visual de combate (FX layer).
--
-- Floating combat text (FCT): cada HIT/PHIT/heal vira um número que sobe
-- e some. Estado vive em State.fctEntries; este módulo só desenha e
-- gerencia o ciclo de vida.
--
-- Tipos suportados:
--   "dmg"  → laranja-vermelho, números maiores para dano
--   "heal" → verde claro, "+N"
--   "mana" → azul, "+N"
--   "txt"  → texto livre (status applied: "Poison", etc.)

local State = require("src.state")

local M = {}

local DEFAULT_DURATION = 0.9
local RISE_PX = 36

-- spawn injeta um número/texto flutuante no mundo.
-- (worldX, worldY) são coordenadas de tile (com fração ok).
function M.spawn(kind, worldX, worldY, value, opts)
    opts = opts or {}
    local entry = {
        kind = kind,
        x = worldX,
        y = worldY,
        value = value,
        start = love.timer.getTime(),
        duration = opts.duration or DEFAULT_DURATION,
        offset = (math.random() - 0.5) * 0.4,
    }
    State.fctEntries = State.fctEntries or {}
    State.fctEntries[#State.fctEntries + 1] = entry
end

function M.update(dt)
    local list = State.fctEntries
    if not list or #list == 0 then return end
    local now = love.timer.getTime()
    local kept = {}
    for _, e in ipairs(list) do
        if now - e.start < e.duration then
            kept[#kept + 1] = e
        end
    end
    State.fctEntries = kept
end

local function colorFor(kind)
    if kind == "heal" then return 0.50, 1.00, 0.55
    elseif kind == "mana" then return 0.50, 0.70, 1.00
    elseif kind == "txt" then return 0.95, 0.85, 0.55
    end
    return 1.00, 0.55, 0.30  -- dano (default)
end

-- draw é chamado já dentro do espaço-mundo do Render (camera applied).
-- TILE_W / TILE_H são fornecidos pelo render.lua.
function M.draw(TILE_W, TILE_H)
    local list = State.fctEntries
    if not list or #list == 0 then return end
    local now = love.timer.getTime()
    love.graphics.setFont(State.fonts.name)
    for _, e in ipairs(list) do
        local t = (now - e.start) / e.duration
        if t > 1 then t = 1 end
        local alpha = 1 - t
        local sx = (e.x + 0.5 + e.offset) * TILE_W
        local sy = (e.y + 0.5) * TILE_H - RISE_PX * t - 28
        local r, g, b = colorFor(e.kind)
        local txt
        if e.kind == "heal" or e.kind == "mana" then
            txt = "+" .. tostring(e.value)
        elseif e.kind == "txt" then
            txt = tostring(e.value)
        else
            txt = "-" .. tostring(e.value)
        end
        love.graphics.setColor(0, 0, 0, 0.55 * alpha)
        love.graphics.print(txt, sx + 1, sy + 1)
        love.graphics.setColor(r, g, b, alpha)
        love.graphics.print(txt, sx, sy)
    end
end

return M
