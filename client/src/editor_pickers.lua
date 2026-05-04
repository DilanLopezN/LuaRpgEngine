-- Phase 1 — Pickers de Conteúdo.
--
-- Overlay modal reutilizável para selecionar IDs de item / quest / NPC a
-- partir do catálogo (State.itemDefs, State.questDefs, State.npcDefs) em
-- vez de digitar à mão. Os editores chamam `Pickers.openItem(currentId,
-- onPick)`, `Pickers.openQuest(...)` ou `Pickers.openNPC(filter, currentId,
-- onPick)`; quando o usuário clica numa célula, `onPick(id)` é chamado e
-- o overlay fecha. Esc ou clique fora também fecham.
--
-- Estado vive em `State.activePicker = {...}`. O editor.lua dá ao módulo
-- prioridade absoluta sobre input enquanto algum picker está aberto, para
-- que o overlay sempre fique por cima das abas.

local State   = require("src.state")
local Items   = require("src.items")
local Sprites = require("src.sprites")
local Tooltip = require("src.tooltip")

local M = {}

-- ---------------------------------------------------------------------------
-- Layout constants ----------------------------------------------------------
-- ---------------------------------------------------------------------------

local OVERLAY_PAD     = 80    -- distância das bordas da tela
local SEARCH_H        = 32
local CELL_W          = 132
local CELL_H          = 96
local CELL_GAP        = 8
local FOOTER_H        = 30

local TYPE_LABELS = {
    item  = "Selecionar Item",
    quest = "Selecionar Quest",
    npc   = "Selecionar NPC",
}

-- ---------------------------------------------------------------------------
-- Helpers -------------------------------------------------------------------
-- ---------------------------------------------------------------------------

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local function overlayRect()
    local sw, sh = love.graphics.getDimensions()
    local w = math.min(sw - OVERLAY_PAD * 2, 880)
    local h = math.min(sh - OVERLAY_PAD * 2, 620)
    local x = math.floor((sw - w) / 2)
    local y = math.floor((sh - h) / 2)
    return x, y, w, h
end

local function gridRect()
    local x, y, w, h = overlayRect()
    local gx = x + 16
    local gy = y + 16 + SEARCH_H + 10
    local gw = w - 32
    local gh = h - (gy - y) - FOOTER_H - 16
    return gx, gy, gw, gh
end

local function searchRect()
    local x, y, w = overlayRect()
    return x + 16, y + 16, w - 32, SEARCH_H
end

local function footerRect()
    local x, y, w, h = overlayRect()
    return x + 16, y + h - FOOTER_H - 8, w - 32, FOOTER_H
end

-- ---------------------------------------------------------------------------
-- Catálogo loaders ----------------------------------------------------------
-- ---------------------------------------------------------------------------

-- Cada entrada vira { id, name, def, kind, roles } para a busca. Mantemos
-- a tabela cacheada na sessão do picker — recriar a cada frame seria
-- aceitável (catálogos têm dezenas de itens), mas isso evita garbage.
local function loadItems()
    local out = {}
    for id, def in pairs(State.itemDefs or {}) do
        out[#out + 1] = {
            id = id, name = def.name or id, def = def, kind = "item",
        }
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

local function loadQuests()
    local out = {}
    for id, def in pairs(State.questDefs or {}) do
        out[#out + 1] = {
            id = id, name = def.name or id, def = def, kind = "quest",
        }
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

-- Filtro de NPC: aceita string (single role), tabela (lista de roles
-- aceitos) ou nil (qualquer role).
local function npcMatchesFilter(def, filter)
    if filter == nil then return true end
    local role = def.role or "friendly"
    if type(filter) == "string" then return role == filter end
    if type(filter) == "table" then
        for _, r in ipairs(filter) do
            if r == role then return true end
        end
        return false
    end
    return true
end

local function loadNPCs(filter)
    local out = {}
    for id, def in pairs(State.npcDefs or {}) do
        if npcMatchesFilter(def, filter) then
            out[#out + 1] = {
                id = id, name = def.name or id, def = def, kind = "npc",
            }
        end
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

-- ---------------------------------------------------------------------------
-- API pública ---------------------------------------------------------------
-- ---------------------------------------------------------------------------

local function open(kind, currentId, onPick, opts)
    opts = opts or {}
    local entries
    if kind == "item"  then entries = loadItems()
    elseif kind == "quest" then entries = loadQuests()
    elseif kind == "npc"   then entries = loadNPCs(opts.filter)
    else return end

    State.activePicker = {
        kind       = kind,
        entries    = entries,
        currentId  = currentId or "",
        onPick     = onPick,
        search     = "",
        scroll     = 0,
        title      = opts.title or TYPE_LABELS[kind] or "Selecionar",
        allowClear = opts.allowClear ~= false, -- default true
        filter     = opts.filter,
    }
end

function M.openItem(currentId, onPick, opts)
    open("item", currentId, onPick, opts)
end

function M.openQuest(currentId, onPick, opts)
    open("quest", currentId, onPick, opts)
end

-- A assinatura segue o spec do roadmap: filter primeiro, currentId depois.
-- Quando o filter for nil, qualquer NPC entra. Filter pode ser string ou
-- lista de roles ("enemy", "guardian", "quest_giver", ...).
function M.openNPC(filter, currentId, onPick, opts)
    opts = opts or {}
    opts.filter = filter
    open("npc", currentId, onPick, opts)
end

function M.isOpen()
    return State.activePicker ~= nil
end

function M.close()
    State.activePicker = nil
end

-- ---------------------------------------------------------------------------
-- Filtrar entradas pela busca ------------------------------------------------
-- ---------------------------------------------------------------------------

local function filteredEntries(p)
    local q = (p.search or ""):lower()
    if q == "" then return p.entries end
    local out = {}
    for _, e in ipairs(p.entries) do
        local hay = (e.name or ""):lower() .. " " .. (e.id or ""):lower()
        if hay:find(q, 1, true) then out[#out + 1] = e end
    end
    return out
end

local function entriesPerRow(gw)
    return math.max(1, math.floor((gw + CELL_GAP) / (CELL_W + CELL_GAP)))
end

-- ---------------------------------------------------------------------------
-- Drawing -------------------------------------------------------------------
-- ---------------------------------------------------------------------------

-- Reused gradient helper (mesma estética do editor.lua).
local function drawVerticalGradient(x, y, w, h, top, bot, steps)
    steps = steps or 12
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        love.graphics.setColor(
            top[1] + (bot[1] - top[1]) * t,
            top[2] + (bot[2] - top[2]) * t,
            top[3] + (bot[3] - top[3]) * t,
            (top[4] or 1) + ((bot[4] or 1) - (top[4] or 1)) * t)
        local ys = y + math.floor(h * i / steps)
        local ye = y + math.floor(h * (i + 1) / steps)
        love.graphics.rectangle("fill", x, ys, w, ye - ys)
    end
end

-- Desenha o ícone/preview de um entry. Para item usa Items.draw com a
-- raridade do def (borda colorida); para NPC usa o sprite do def via
-- Sprites.frame; para quest usa um glifo simples.
local function drawEntryIcon(entry, x, y, size)
    if entry.kind == "item" then
        local id = Items.iconForItem(entry.def)
        Items.draw(id, x, y, size, { rarity = entry.def.rarity })
        return
    end
    if entry.kind == "npc" then
        local sp = entry.def.sprite and Sprites.npcSprite(entry.def.sprite) or nil
        if sp then
            local img, quad, fw, fh = Sprites.frame(sp.animName, love.timer.getTime())
            if img then
                love.graphics.setColor(0.10, 0.13, 0.18)
                love.graphics.rectangle("fill", x, y, size, size, 4, 4)
                local scale = math.min((size - 4) / fw, (size - 4) / fh) * 1.4
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(img, quad,
                    x + size / 2, y + size - 2,
                    0, scale, scale, fw / 2, fh)
                love.graphics.setColor(0.45, 0.55, 0.78, 0.55)
                love.graphics.rectangle("line", x, y, size, size, 4, 4)
                return
            end
        end
        love.graphics.setColor(0.30, 0.32, 0.38)
        love.graphics.rectangle("fill", x, y, size, size, 4, 4)
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.printf("?", x, y + size / 2 - 8, size, "center")
        return
    end
    -- quest
    love.graphics.setColor(0.40, 0.30, 0.50)
    love.graphics.rectangle("fill", x, y, size, size, 4, 4)
    love.graphics.setColor(1.0, 0.85, 0.4)
    love.graphics.setFont(State.fonts.title or State.fonts.ui)
    love.graphics.printf("⚔", x, y + size / 2 - (State.fonts.title:getHeight()) / 2,
        size, "center")
    love.graphics.setColor(0.55, 0.65, 0.90, 0.55)
    love.graphics.rectangle("line", x, y, size, size, 4, 4)
end

-- Texto curto de meta para a célula (raridade/role/kill count etc).
local function entryMeta(entry)
    if entry.kind == "item" then
        local typ = entry.def.type or "?"
        local rar = entry.def.rarity or "common"
        return typ .. " · " .. rar
    end
    if entry.kind == "npc" then
        return entry.def.role or "?"
    end
    if entry.kind == "quest" then
        return string.format("%d obj", #(entry.def.objectives or {}))
    end
    return ""
end

local function drawCell(entry, cx, cy, cw, ch, current, hover)
    if current then
        love.graphics.setColor(0.22, 0.42, 0.66)
    elseif hover then
        love.graphics.setColor(0.16, 0.22, 0.30)
    else
        love.graphics.setColor(0.10, 0.13, 0.18)
    end
    love.graphics.rectangle("fill", cx, cy, cw, ch, 6, 6)
    love.graphics.setColor(0.45, 0.55, 0.78, current and 0.95 or 0.45)
    love.graphics.rectangle("line", cx, cy, cw, ch, 6, 6)

    local iconSize = 40
    drawEntryIcon(entry, cx + (cw - iconSize) / 2, cy + 8, iconSize)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(entry.name or entry.id,
        cx + 4, cy + iconSize + 12, cw - 8, "center")

    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.55, 0.70, 0.92)
    love.graphics.printf(entry.id, cx + 4, cy + iconSize + 28, cw - 8, "center")

    love.graphics.setColor(0.85, 0.65, 0.40)
    love.graphics.printf(entryMeta(entry), cx + 4, cy + iconSize + 44,
        cw - 8, "center")

    if hover then
        local meta = entryMeta(entry)
        Tooltip.hover(string.format("%s\nID: %s\n%s",
            entry.name or entry.id, entry.id, meta))
    end
end

local function drawSearch(p)
    local x, y, w, h = searchRect()
    love.graphics.setColor(0.10, 0.13, 0.18)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(0.55, 0.65, 0.90, 0.85)
    love.graphics.rectangle("line", x, y, w, h, 6, 6)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.65, 0.78, 0.95)
    love.graphics.print("🔎", x + 8, y + 5)
    love.graphics.setColor(1, 1, 1)
    local txt = p.search or ""
    if txt == "" then
        love.graphics.setColor(0.55, 0.65, 0.78)
        love.graphics.print("Buscar por nome ou id...", x + 32, y + 6)
    else
        if (math.floor(love.timer.getTime() * 2) % 2) == 0 then
            txt = txt .. "_"
        end
        love.graphics.print(txt, x + 32, y + 6)
    end
end

local function drawFooter(p, total, shown)
    local x, y, w, h = footerRect()
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.65, 0.78, 0.92)
    local info = string.format("%d de %d", shown, total)
    if p.currentId and p.currentId ~= "" then
        info = info .. "  ·  atual: " .. p.currentId
    end
    love.graphics.print(info, x, y + 8)

    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    if p.allowClear then
        local btnW = 100
        local btnX = x + w - btnW
        local hover = pointIn(mx, my, btnX, y, btnW, h)
        love.graphics.setColor(hover and 0.45 or 0.30, 0.20, 0.20)
        love.graphics.rectangle("fill", btnX, y, btnW, h, 4, 4)
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.rectangle("line", btnX, y, btnW, h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(State.fonts.ui)
        love.graphics.printf("Limpar", btnX, y + 6, btnW, "center")
        if hover then
            Tooltip.hover("Esvazia o campo (volta a ficar sem seleção).")
        end
    end

    -- Botão fechar.
    local closeW = 100
    local closeX = x + w - (p.allowClear and (100 + 8 + closeW) or closeW)
    local closeHover = pointIn(mx, my, closeX, y, closeW, h)
    love.graphics.setColor(closeHover and 0.32 or 0.22,
                           closeHover and 0.36 or 0.25,
                           closeHover and 0.45 or 0.35)
    love.graphics.rectangle("fill", closeX, y, closeW, h, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.rectangle("line", closeX, y, closeW, h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.printf("Cancelar", closeX, y + 6, closeW, "center")
    if closeHover then
        Tooltip.hover("Fecha o picker sem alterar o campo (Esc).")
    end
end

local function isClearHover(p, mx, my)
    if not p.allowClear then return false end
    local x, y, w, h = footerRect()
    local btnW = 100
    return pointIn(mx, my, x + w - btnW, y, btnW, h)
end

local function isCancelHover(p, mx, my)
    local x, y, w, h = footerRect()
    local closeW = 100
    local closeX = x + w - (p.allowClear and (100 + 8 + closeW) or closeW)
    return pointIn(mx, my, closeX, y, closeW, h)
end

function M.draw()
    local p = State.activePicker
    if not p then return end

    local sw, sh = love.graphics.getDimensions()
    -- Backdrop bloqueia o que está atrás.
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    local x, y, w, h = overlayRect()
    -- Painel.
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", x + 6, y + 8, w, h, 12, 12)
    drawVerticalGradient(x, y, w, h,
        { 0.11, 0.13, 0.18, 0.99 }, { 0.06, 0.07, 0.11, 0.99 }, 16)
    love.graphics.setColor(0.45, 0.78, 1.00, 0.85)
    love.graphics.rectangle("line", x, y, w, h, 12, 12)

    -- Título.
    love.graphics.setFont(State.fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(p.title, x + 16, y + 16 - State.fonts.title:getHeight() - 4)

    drawSearch(p)

    local list = filteredEntries(p)
    local gx, gy, gw, gh = gridRect()
    local cols = entriesPerRow(gw)

    love.graphics.setScissor(gx, gy, gw, gh)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    if #list == 0 then
        love.graphics.setFont(State.fonts.ui)
        love.graphics.setColor(0.85, 0.65, 0.40)
        local msg = "Catálogo vazio. Crie entradas na aba correspondente."
        if (p.search or "") ~= "" then
            msg = "Nenhum resultado para \"" .. p.search .. "\"."
        end
        love.graphics.printf(msg, gx, gy + 40, gw, "center")
    else
        for i, entry in ipairs(list) do
            local col = (i - 1) % cols
            local rrow = math.floor((i - 1) / cols)
            local cx = gx + col * (CELL_W + CELL_GAP)
            local cy = gy + rrow * (CELL_H + CELL_GAP) - p.scroll
            if cy + CELL_H >= gy and cy <= gy + gh then
                local hover = pointIn(mx, my, cx, cy, CELL_W, CELL_H)
                local current = (entry.id == p.currentId)
                drawCell(entry, cx, cy, CELL_W, CELL_H, current, hover)
            end
        end
    end
    love.graphics.setScissor()

    drawFooter(p, #p.entries, #list)
end

-- ---------------------------------------------------------------------------
-- Input ---------------------------------------------------------------------
-- ---------------------------------------------------------------------------

local function pickEntry(entry)
    local p = State.activePicker
    if not p then return end
    local cb = p.onPick
    M.close()
    if cb then cb(entry and entry.id or "") end
end

function M.mousepressed(x, y, button)
    local p = State.activePicker
    if not p then return false end
    button = button or 1

    if isCancelHover(p, x, y) then
        M.close()
        return true
    end
    if isClearHover(p, x, y) then
        pickEntry(nil)
        return true
    end

    local ox, oy, ow, oh = overlayRect()
    if not pointIn(x, y, ox, oy, ow, oh) then
        -- Clique fora fecha (mas absorve o evento para não cair na cena).
        M.close()
        return true
    end

    local sx, sy, sw, sh = searchRect()
    if pointIn(x, y, sx, sy, sw, sh) then
        -- foco fica implícito enquanto picker estiver aberto
        return true
    end

    local gx, gy, gw, gh = gridRect()
    if pointIn(x, y, gx, gy, gw, gh) then
        local list = filteredEntries(p)
        local cols = entriesPerRow(gw)
        for i, entry in ipairs(list) do
            local col = (i - 1) % cols
            local rrow = math.floor((i - 1) / cols)
            local cx = gx + col * (CELL_W + CELL_GAP)
            local cy = gy + rrow * (CELL_H + CELL_GAP) - p.scroll
            if pointIn(x, y, cx, cy, CELL_W, CELL_H) then
                pickEntry(entry)
                return true
            end
        end
    end
    return true
end

function M.wheelmoved(_, dy)
    local p = State.activePicker
    if not p then return false end
    p.scroll = math.max(0, (p.scroll or 0) - dy * 40)
    return true
end

function M.textinput(t)
    local p = State.activePicker
    if not p then return false end
    if #(p.search or "") >= 48 then return true end
    if t:match("[%w%s_%-%.]") then
        p.search = (p.search or "") .. t
        p.scroll = 0
    end
    return true
end

function M.keypressed(key)
    local p = State.activePicker
    if not p then return false end
    if key == "escape" then
        M.close()
        return true
    end
    if key == "backspace" then
        p.search = (p.search or ""):sub(1, -2)
        p.scroll = 0
        return true
    end
    if key == "return" or key == "kpenter" then
        -- Atalho: se há exatamente um resultado, escolhe.
        local list = filteredEntries(p)
        if #list == 1 then pickEntry(list[1]) end
        return true
    end
    return true
end

return M
