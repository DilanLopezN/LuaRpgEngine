-- Phase 6 — Minimapa.
--
-- Pequena visão top-down do mapa atual no canto superior direito da
-- tela. Mostra:
--   - tiles de chão (cinza), colisão (preto), logic (azul translúcido)
--   - posição do player (amarelo)
--   - inimigos (vermelho)
--   - NPCs (verde-claro)
--
-- Renderiza para um Canvas só quando o mapa muda; o draw da tela só
-- estampa o canvas e os pontos vivos por cima. Sem isso o frame rate
-- afundava com mapas 80x80 (~6400 cells redesenhados por frame).

local State = require("src.state")
local Map   = require("src.map")

local M = {}

local PADDING = 12
local SIZE_PX = 180   -- lado máximo da minimapa em pixels
local CELL_MIN = 2    -- piso para mapas pequenos não virarem invisíveis

local canvas
local cachedMap   -- referência usada para detectar troca de mapa
local cellSize    -- pixels por tile do mapa atual
local mapPxW, mapPxH

local function pickCellSize(m)
    local maxDim = math.max(m.width, m.height, 1)
    local px = math.floor(SIZE_PX / maxDim)
    if px < CELL_MIN then px = CELL_MIN end
    return px
end

local function rebuild(m)
    cellSize = pickCellSize(m)
    mapPxW = cellSize * m.width
    mapPxH = cellSize * m.height
    canvas = love.graphics.newCanvas(mapPxW, mapPxH)
    local prev = love.graphics.getCanvas()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.05, 0.06, 0.10, 0.92)

    -- Ground/decoration painted como uma única camada acinzentada.
    local hasGround = m.layers and m.layers.ground
    for y = 1, m.height do
        for x = 1, m.width do
            local id = hasGround and m.layers.ground[y] and m.layers.ground[y][x] or 0
            if id ~= 0 then
                love.graphics.setColor(0.30, 0.32, 0.36)
                love.graphics.rectangle("fill",
                    (x - 1) * cellSize, (y - 1) * cellSize, cellSize, cellSize)
            end
        end
    end

    -- Collision em preto.
    local hasColl = m.layers and m.layers.collision
    if hasColl then
        love.graphics.setColor(0, 0, 0, 0.85)
        for y = 1, m.height do
            local row = m.layers.collision[y]
            if row then
                for x = 1, m.width do
                    if (row[x] or 0) ~= 0 then
                        love.graphics.rectangle("fill",
                            (x - 1) * cellSize, (y - 1) * cellSize,
                            cellSize, cellSize)
                    end
                end
            end
        end
    end

    -- Logic em azul translúcido (gatilhos, áreas).
    local hasLogic = m.layers and m.layers.logic
    if hasLogic then
        love.graphics.setColor(0.30, 0.55, 1.0, 0.45)
        for y = 1, m.height do
            local row = m.layers.logic[y]
            if row then
                for x = 1, m.width do
                    if (row[x] or 0) ~= 0 then
                        love.graphics.rectangle("fill",
                            (x - 1) * cellSize, (y - 1) * cellSize,
                            cellSize, cellSize)
                    end
                end
            end
        end
    end

    love.graphics.setCanvas(prev)
end

local function ensureCanvas()
    local m = Map.current
    if not m then
        canvas = nil
        cachedMap = nil
        return false
    end
    if cachedMap ~= m then
        rebuild(m)
        cachedMap = m
    end
    return canvas ~= nil
end

function M.draw()
    if State.scene ~= State.SCENE_PLAYING then return end
    if not ensureCanvas() then return end

    local sw = love.graphics.getWidth()
    local ox = sw - mapPxW - PADDING
    local oy = PADDING

    -- Backdrop / borda.
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", ox - 4, oy - 4, mapPxW + 8, mapPxH + 8, 4, 4)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, ox, oy)

    love.graphics.setColor(0.6, 0.7, 0.9, 0.7)
    love.graphics.rectangle("line", ox, oy, mapPxW, mapPxH, 2, 2)

    -- Pontos vivos.
    local function plot(x, y, r, g, b, size)
        if x == nil or y == nil then return end
        local px = ox + x * cellSize
        local py = oy + y * cellSize
        love.graphics.setColor(r, g, b)
        local s = math.max(size or cellSize, 2)
        love.graphics.rectangle("fill", px - s/2, py - s/2, s, s)
    end

    for id, p in pairs(State.players or {}) do
        if p.x and p.y then
            local me = (id == State.myId)
            if me then
                plot(p.x, p.y, 1.0, 0.95, 0.35, math.max(cellSize + 2, 4))
            else
                plot(p.x, p.y, 0.45, 0.75, 1.0, math.max(cellSize, 3))
            end
        end
    end
    for _, e in pairs(State.enemies or {}) do
        if e.x and e.y then
            plot(e.x, e.y, 0.95, 0.35, 0.30, math.max(cellSize, 3))
        end
    end
    for _, n in pairs(State.npcs or {}) do
        if n.x and n.y then
            plot(n.x, n.y, 0.55, 0.95, 0.55, math.max(cellSize, 3))
        end
    end
end

-- Permite invalidar o canvas manualmente (ex.: após /reload do mapa).
function M.invalidate()
    cachedMap = nil
end

return M
