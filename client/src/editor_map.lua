-- Map editor tab. Lives inside the unified F1 engine editor: it draws its
-- own toolbar/palette in the editor panel and edits the world tilemap
-- directly through `Map`. The renderer (render.lua) draws the live map in
-- the world; this module owns the tooling around it (tile palette, tool
-- selection, layer toggles, undo/redo, save).

local State    = require("src.state")
local World    = require("src.world")
local Map      = require("src.map")
local Tilesets = require("src.tilesets")
local Network  = require("src.network")
local JSON     = require("src.json")
local Layout   = require("src.editor_layout")
local Tooltip  = require("src.tooltip")

local M = {}

local UNDO_LIMIT = 32

local LAYERS = { "ground", "decoration", "collision", "logic" }
local TOOLS  = { "paint", "fill", "erase", "select", "entity" }
local ENTITY_TYPES = { "spawn", "npc", "trigger" }
local ENTITY_KINDS = { "orc", "guard", "merchant", "warp", "marker" }

-- Labels exibidos no painel; os IDs internos seguem em inglês porque são
-- chave em código e na rede.
local TOOL_LABELS = {
    paint  = "Pintar",
    fill   = "Preencher",
    erase  = "Apagar",
    select = "Selecionar",
    entity = "Entidade",
}
local LAYER_LABELS = {
    ground     = "Chão",
    decoration = "Decoração",
    collision  = "Colisão",
    logic      = "Lógica",
}
local ENTITY_TYPE_LABELS = {
    spawn   = "Spawn",
    npc     = "NPC",
    trigger = "Gatilho",
}
local ENTITY_KIND_LABELS = {
    orc      = "Orc",
    guard    = "Guarda",
    merchant = "Mercador",
    warp     = "Portal",
    marker   = "Marcador",
}

local TOOL_TIPS = {
    paint  = "Pinta o tile selecionado da paleta na camada atual.",
    fill   = "Preenche por inundação a área de mesmo valor (tipo balde de tinta).",
    erase  = "Apaga (zera) o tile da camada atual. Botão direito também apaga.",
    select = "Marca uma seleção retangular para copiar (Ctrl+C) e colar (Ctrl+V).",
    entity = "Adiciona/remove entidades (spawns, NPCs, gatilhos) no tile clicado.",
}
local LAYER_TIPS = {
    ground     = "Camada visual de chão. Clique em um tile da paleta e pinte.",
    decoration = "Camada visual sobreposta ao chão (objetos, detritos, etc).",
    collision  = "Tiles bloqueiam movimento. Clique para alternar bloqueio.",
    logic      = "Tiles de lógica/gatilho usados pelo gameplay.",
}

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

-- ---------------------------------------------------------------------------
-- Layout. The map editor reuses the spells editor's outer panel; it splits
-- the inside into a left toolbar/palette and a right hint area.
-- ---------------------------------------------------------------------------

local panelRect = Layout.panelRect

local function paletteRect()
    local cx, cy, _, ch = Layout.contentRect()
    return cx + 16, cy + 12, 320, ch - 28
end

local function toolbarRect()
    local cx, cy, cw, ch = Layout.contentRect()
    local lw = 320
    return cx + 16 + lw + 16, cy + 12, cw - lw - 48, ch - 28
end

M.panelRect = panelRect

-- ---------------------------------------------------------------------------
-- History (undo / redo)
-- ---------------------------------------------------------------------------

local function pushUndo()
    local me = State.mapEditor
    if not Map.current then return end
    local snap = Map.snapshot()
    if not snap then return end
    me.history[#me.history + 1] = snap
    if #me.history > UNDO_LIMIT then
        table.remove(me.history, 1)
    end
    me.redo = {}
end

local function undo()
    local me = State.mapEditor
    if #me.history == 0 then return end
    local current = Map.snapshot()
    me.redo[#me.redo + 1] = current
    local snap = table.remove(me.history)
    Map.restore(snap)
end

local function redo()
    local me = State.mapEditor
    if #me.redo == 0 then return end
    local current = Map.snapshot()
    me.history[#me.history + 1] = current
    local snap = table.remove(me.redo)
    Map.restore(snap)
end

M.pushUndo = pushUndo
M.undo     = undo
M.redo     = redo

-- ---------------------------------------------------------------------------
-- World ↔ screen conversion
-- ---------------------------------------------------------------------------

local function worldTileFromScreen(sx, sy)
    local wx = sx + State.camera.x
    local wy = sy + State.camera.y
    local tx = math.floor(wx / World.TILE_W) + 1
    local ty = math.floor(wy / World.TILE_H) + 1
    return tx, ty
end

-- ---------------------------------------------------------------------------
-- Tile painting
-- ---------------------------------------------------------------------------

local function currentTileValue()
    local me = State.mapEditor
    if me.layer == "ground" or me.layer == "decoration" then
        local tilesets = Tilesets.list()
        local ts = tilesets[me.tilesetIndex]
        if not ts then return 0 end
        return Tilesets.pack(ts.id, me.tileIndex)
    elseif me.layer == "collision" then
        return 1
    elseif me.layer == "logic" then
        return 1
    end
    return 0
end

local function paintTile(x, y, value)
    if not Map.inBounds(x, y) then return end
    Map.set(State.mapEditor.layer, x, y, value)
end

local function floodFill(x, y, value)
    local m = Map.current
    if not m or not Map.inBounds(x, y) then return end
    local layer = State.mapEditor.layer
    local target = Map.get(layer, x, y)
    if target == value then return end
    local stack = { { x, y } }
    while #stack > 0 do
        local p = table.remove(stack)
        local cx, cy = p[1], p[2]
        if Map.inBounds(cx, cy) and Map.get(layer, cx, cy) == target then
            Map.set(layer, cx, cy, value)
            stack[#stack + 1] = { cx + 1, cy }
            stack[#stack + 1] = { cx - 1, cy }
            stack[#stack + 1] = { cx, cy + 1 }
            stack[#stack + 1] = { cx, cy - 1 }
        end
    end
end

local function copySelection()
    local me = State.mapEditor
    local s = me.selection
    if not s or not Map.current then return end
    local x1, y1 = math.min(s.x1, s.x2), math.min(s.y1, s.y2)
    local x2, y2 = math.max(s.x1, s.x2), math.max(s.y1, s.y2)
    local clip = { w = x2 - x1 + 1, h = y2 - y1 + 1, layers = {} }
    for _, name in ipairs(LAYERS) do
        local grid = {}
        for y = y1, y2 do
            local row = {}
            for x = x1, x2 do
                row[x - x1 + 1] = Map.get(name, x, y)
            end
            grid[y - y1 + 1] = row
        end
        clip.layers[name] = grid
    end
    me.clipboard = clip
end

local function pasteAt(x, y)
    local me = State.mapEditor
    local clip = me.clipboard
    if not clip then return false end
    pushUndo()
    for _, name in ipairs(LAYERS) do
        local grid = clip.layers[name]
        if grid then
            for j = 1, clip.h do
                for i = 1, clip.w do
                    Map.set(name, x + i - 1, y + j - 1, grid[j][i] or 0)
                end
            end
        end
    end
    return true
end

M.copySelection = copySelection
M.pasteAt       = pasteAt

-- ---------------------------------------------------------------------------
-- Save (SAVE_MAP)
-- ---------------------------------------------------------------------------

local function saveToServer()
    if not Map.current then return end
    if Network.connected and not Network.connected() then
        State.mapEditor.saveStatus = "offline (sem conexão)"
        return
    end
    local payload = JSON.encode(Map.current)
    Network.send("SAVE_MAP " .. payload)
    State.mapEditor.saveStatus = "envio realizado"
end

M.save = saveToServer

-- ---------------------------------------------------------------------------
-- World drag interaction (called by input.lua)
-- ---------------------------------------------------------------------------

-- worldClick is invoked when the user clicks anywhere outside the editor
-- panel: it interprets the click as a tile-tool action against the world.
function M.worldClick(sx, sy, button)
    local me = State.mapEditor
    local tx, ty = worldTileFromScreen(sx, sy)
    if not Map.inBounds(tx, ty) then return end
    if me.tool == "select" then
        me.selection = { x1 = tx, y1 = ty, x2 = tx, y2 = ty }
        me.selectionStart = { x = tx, y = ty }
        return
    end
    if me.tool == "fill" then
        pushUndo()
        local v = (button == 2) and 0 or currentTileValue()
        floodFill(tx, ty, v)
        return
    end
    if me.tool == "entity" then
        pushUndo()
        if button == 2 then
            for i, e in ipairs(Map.current.entities) do
                if e.x == tx - 1 and e.y == ty - 1 then
                    table.remove(Map.current.entities, i)
                    return
                end
            end
        else
            Map.current.entities[#Map.current.entities + 1] = {
                type = me.entityType,
                kind = me.entityKind,
                x    = tx - 1,
                y    = ty - 1,
            }
        end
        return
    end
    pushUndo()
    me.activeStroke = true
    me.paintingButton = button
    if me.tool == "erase" or button == 2 then
        paintTile(tx, ty, 0)
    else
        paintTile(tx, ty, currentTileValue())
    end
end

function M.worldDrag(sx, sy)
    local me = State.mapEditor
    local tx, ty = worldTileFromScreen(sx, sy)
    if me.tool == "select" and me.selectionStart and me.selection then
        me.selection.x2 = math.max(1, math.min(Map.current.width,  tx))
        me.selection.y2 = math.max(1, math.min(Map.current.height, ty))
        return
    end
    if not me.activeStroke then return end
    if not Map.inBounds(tx, ty) then return end
    if me.tool == "erase" or me.paintingButton == 2 then
        paintTile(tx, ty, 0)
    elseif me.tool == "paint" then
        paintTile(tx, ty, currentTileValue())
    end
end

function M.worldRelease()
    local me = State.mapEditor
    me.activeStroke = false
    me.paintingButton = nil
    me.selectionStart = nil
end

-- ---------------------------------------------------------------------------
-- Drawing
-- ---------------------------------------------------------------------------

local function drawPalette()
    local lx, ly, lw, lh = paletteRect()
    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", lx, ly, lw, lh, 4, 4)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Tileset", lx + 8, ly + 8)

    local me = State.mapEditor
    local tilesets = Tilesets.list()
    -- tileset selector buttons
    local btnY = ly + 30
    local btnX = lx + 8
    for i, ts in ipairs(tilesets) do
        local label = string.format("#%d", ts.id)
        local w = State.fonts.ui:getWidth(label) + 16
        if i == me.tilesetIndex then
            love.graphics.setColor(0.25, 0.42, 0.65)
        else
            love.graphics.setColor(0.13, 0.15, 0.20)
        end
        love.graphics.rectangle("fill", btnX, btnY, w, 22, 4, 4)
        love.graphics.setColor(0.4, 0.5, 0.6)
        love.graphics.rectangle("line", btnX, btnY, w, 22, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(label, btnX + 8, btnY + 4)
        btnX = btnX + w + 6
    end

    if me.layer == "collision" or me.layer == "logic" then
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.printf("A paleta fica oculta em camadas não visuais."
            .. "\nClique esquerdo no mundo: marcar. Botão direito: limpar.",
            lx + 8, ly + 70, lw - 16, "left")
        return
    end

    local ts = tilesets[me.tilesetIndex]
    if not ts or not ts.image then
        love.graphics.setColor(0.85, 0.4, 0.4)
        love.graphics.printf("Imagem do tileset ausente ou não carregada.",
            lx + 8, ly + 70, lw - 16, "left")
        return
    end

    -- tile grid
    local tilesArea = { x = lx + 8, y = ly + 60, w = lw - 16, h = lh - 80 }
    love.graphics.setScissor(tilesArea.x, tilesArea.y, tilesArea.w, tilesArea.h)

    local cellSize = 28
    local cols = math.max(1, math.floor(tilesArea.w / cellSize))
    local idx = 0
    for r = 0, ts.rows - 1 do
        for c = 0, ts.columns - 1 do
            local i = r * ts.columns + c
            local cx = tilesArea.x + (idx % cols) * cellSize
            local cy = tilesArea.y + math.floor(idx / cols) * cellSize - me.paletteScroll
            if cy + cellSize >= tilesArea.y and cy <= tilesArea.y + tilesArea.h then
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(ts.image, ts.quads[i],
                    cx, cy, 0,
                    (cellSize - 2) / ts.tileW, (cellSize - 2) / ts.tileH)
                if i == me.tileIndex then
                    love.graphics.setColor(1, 1, 0.4)
                    love.graphics.setLineWidth(2)
                    love.graphics.rectangle("line", cx, cy, cellSize - 2, cellSize - 2)
                    love.graphics.setLineWidth(1)
                end
            end
            idx = idx + 1
        end
    end
    love.graphics.setScissor()

    love.graphics.setColor(0.7, 0.75, 0.85)
    love.graphics.print(string.format("tile %d  (%dx%d)",
        me.tileIndex, ts.columns, ts.rows), lx + 8, ly + lh - 18)
    if pointIn(State.mouse.x or 0, State.mouse.y or 0,
               tilesArea.x, tilesArea.y, tilesArea.w, tilesArea.h) then
        Tooltip.hover("Paleta do tileset. Clique para escolher um tile, role o mouse para rolar.")
    end
end

-- ACTIONS é tabela de ação para os botões inferiores. O label é resolvido
-- por closure para refletir o estado atual (ex.: "Grade: ON/OFF").
local function buildActions(me)
    return {
        { id = "undo",  label = "Desfazer (Ctrl+Z)",
          tip = "Desfaz a última alteração no mapa." },
        { id = "redo",  label = "Refazer (Ctrl+Y)",
          tip = "Refaz a alteração que acabou de ser desfeita." },
        { id = "copy",  label = "Copiar Seleção (Ctrl+C)",
          tip = "Copia a seleção atual. Use Ctrl+V no mundo para colar." },
        { id = "grid",  label = me.showGrid and "Grade: ON" or "Grade: OFF",
          tip = "Mostra/esconde a grade de tiles sobre o mundo." },
        { id = "save",  label = "Salvar Mapa (Ctrl+S)",
          tip = "Envia o mapa atual ao servidor (cria um .bak da versão anterior)." },
    }
end

-- Layout fluido para a linha de ações: quebra para a próxima linha quando
-- a próxima ação não couber. Retorna o último y + altura usada.
local function layoutActionRow(actions, fx, fw, y, btnH)
    local positions = {}
    local x = fx + 12
    local rightLimit = fx + fw - 12
    for _, a in ipairs(actions) do
        local w = State.fonts.ui:getWidth(a.label) + 18
        if x ~= fx + 12 and x + w > rightLimit then
            x = fx + 12
            y = y + btnH + 6
        end
        positions[#positions + 1] = { a = a, x = x, y = y, w = w, h = btnH }
        x = x + w + 6
    end
    return positions, y + btnH
end

local function drawToolbar()
    local fx, fy, fw, fh = toolbarRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", fx, fy, fw, fh, 4, 4)

    local me = State.mapEditor
    love.graphics.setFont(State.fonts.ui)

    local y = fy + 12
    local function row(title, items, current, labelMap, tipMap)
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.print(title, fx + 12, y + 6)
        local x = fx + 110
        for _, it in ipairs(items) do
            local label = labelMap and labelMap[it] or it
            local w = State.fonts.ui:getWidth(label) + 16
            local hover = pointIn(mx, my, x, y, w, 24)
            if it == current then
                love.graphics.setColor(0.25, 0.42, 0.65)
            elseif hover then
                love.graphics.setColor(0.18, 0.22, 0.30)
            else
                love.graphics.setColor(0.13, 0.15, 0.20)
            end
            love.graphics.rectangle("fill", x, y, w, 24, 4, 4)
            love.graphics.setColor(0.4, 0.5, 0.6)
            love.graphics.rectangle("line", x, y, w, 24, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(label, x + 8, y + 5)
            if hover and tipMap and tipMap[it] then
                Tooltip.hover(tipMap[it])
            end
            x = x + w + 6
        end
        y = y + 32
    end

    row("Ferramenta", TOOLS,  me.tool,  TOOL_LABELS,  TOOL_TIPS)
    row("Camada",     LAYERS, me.layer, LAYER_LABELS, LAYER_TIPS)
    if me.tool == "entity" then
        row("Entidade", ENTITY_TYPES, me.entityType, ENTITY_TYPE_LABELS)
        row("Tipo",     ENTITY_KINDS, me.entityKind, ENTITY_KIND_LABELS)
    end

    -- Linha de ações (com wrap)
    local positions, newY = layoutActionRow(buildActions(me), fx, fw, y, 26)
    for _, p in ipairs(positions) do
        local hover = pointIn(mx, my, p.x, p.y, p.w, p.h)
        if p.a.id == "save" then
            love.graphics.setColor(hover and 0.26 or 0.20, hover and 0.55 or 0.45,
                                   hover and 0.32 or 0.25)
        else
            love.graphics.setColor(hover and 0.22 or 0.18,
                                   hover and 0.27 or 0.22,
                                   hover and 0.36 or 0.30)
        end
        love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 4, 4)
        love.graphics.setColor(0.4, 0.5, 0.6)
        love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(p.a.label, p.x + 9, p.y + 6)
        if hover and p.a.tip then Tooltip.hover(p.a.tip) end
    end
    y = newY + 10

    love.graphics.setColor(0.65, 0.75, 0.9)
    local m = Map.current
    if m then
        love.graphics.print(string.format(
            "mapa: %s   %dx%d   entidades: %d   camada: %s",
            m.name, m.width, m.height, #m.entities,
            LAYER_LABELS[me.layer] or me.layer),
            fx + 12, y)
        y = y + 22
    end
    if me.saveStatus and me.saveStatus ~= "" then
        love.graphics.setColor(0.95, 0.85, 0.40)
        love.graphics.print("salvar: " .. me.saveStatus, fx + 12, y)
        y = y + 22
    end

    love.graphics.setColor(0.6, 0.7, 0.85)
    love.graphics.printf(
        "Clique no mundo para usar a ferramenta ativa. Botão direito apaga. "
        .. "F1 alterna o editor. Enquanto edita, o mapa é renderizado ao vivo; "
        .. "use Salvar Mapa (Ctrl+S) para persistir no servidor (gera um .bak "
        .. "da versão anterior). Use Camada=Colisão para definir áreas onde "
        .. "personagens podem ou não andar.",
        fx + 12, y, fw - 24, "left")
end

function M.drawContent()
    drawPalette()
    drawToolbar()
end

function M.drawCursor()
    if State.editorTab ~= "map" or not State.editorOpen then return end
    if not Map.current then return end
    local me = State.mapEditor
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local px, py, pw, ph = panelRect()
    if pointIn(mx, my, px, py, pw, ph) then return end
    local tx, ty = worldTileFromScreen(mx, my)
    if not Map.inBounds(tx, ty) then return end
    local sx = (tx - 1) * World.TILE_W - State.camera.x
    local sy = (ty - 1) * World.TILE_H - State.camera.y
    love.graphics.setColor(1, 1, 0.4, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", sx, sy, World.TILE_W, World.TILE_H)
    love.graphics.setLineWidth(1)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0, 0, 0, 0.7)
    local label = string.format("(%d,%d) %s/%s", tx - 1, ty - 1, me.tool, me.layer)
    local lw = State.fonts.name:getWidth(label) + 8
    love.graphics.rectangle("fill", mx + 12, my + 12, lw, 18)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, mx + 16, my + 14)
end

-- ---------------------------------------------------------------------------
-- Input dispatch (called by editor.lua)
-- ---------------------------------------------------------------------------

local function paletteClick(x, y, button)
    local lx, ly, lw, lh = paletteRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end

    local me = State.mapEditor
    local tilesets = Tilesets.list()

    -- tileset selector (top row, see drawPalette)
    local btnY = ly + 30
    local btnX = lx + 8
    for i, ts in ipairs(tilesets) do
        local label = string.format("#%d", ts.id)
        local w = State.fonts.ui:getWidth(label) + 16
        if pointIn(x, y, btnX, btnY, w, 22) then
            me.tilesetIndex = i
            me.tileIndex = 0
            return true
        end
        btnX = btnX + w + 6
    end

    if me.layer == "collision" or me.layer == "logic" then
        return true
    end
    local ts = tilesets[me.tilesetIndex]
    if not ts or not ts.image then return true end

    local tilesArea = { x = lx + 8, y = ly + 60, w = lw - 16, h = lh - 80 }
    if not pointIn(x, y, tilesArea.x, tilesArea.y, tilesArea.w, tilesArea.h) then
        return true
    end
    local cellSize = 28
    local cols = math.max(1, math.floor(tilesArea.w / cellSize))
    local rx = x - tilesArea.x
    local ry = y - tilesArea.y + me.paletteScroll
    local col = math.floor(rx / cellSize)
    local row = math.floor(ry / cellSize)
    if col < 0 or col >= cols or row < 0 then return true end
    local idx = row * cols + col
    if idx >= 0 and idx < ts.rows * ts.columns then
        me.tileIndex = idx
    end
    return true
end

local function toolbarClick(x, y, button)
    local fx, fy, fw, fh = toolbarRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end
    local me = State.mapEditor

    local yy = fy + 12
    local function rowHit(items, current, setter, labelMap)
        local xx = fx + 110
        for _, it in ipairs(items) do
            local label = labelMap and labelMap[it] or it
            local w = State.fonts.ui:getWidth(label) + 16
            if pointIn(x, y, xx, yy, w, 24) then
                setter(it)
                return true
            end
            xx = xx + w + 6
        end
        return false
    end

    if rowHit(TOOLS,  me.tool,  function(v) me.tool  = v end, TOOL_LABELS) then
        return true
    end
    yy = yy + 32
    if rowHit(LAYERS, me.layer, function(v) me.layer = v end, LAYER_LABELS) then
        return true
    end
    yy = yy + 32
    if me.tool == "entity" then
        if rowHit(ENTITY_TYPES, me.entityType,
                function(v) me.entityType = v end, ENTITY_TYPE_LABELS) then
            return true
        end
        yy = yy + 32
        if rowHit(ENTITY_KINDS, me.entityKind,
                function(v) me.entityKind = v end, ENTITY_KIND_LABELS) then
            return true
        end
        yy = yy + 32
    end

    -- Hit-test usa o MESMO layout fluido do desenho, então os botões nunca
    -- ficam clicáveis num ponto onde não estão renderizados.
    local positions = layoutActionRow(buildActions(me), fx, fw, yy, 26)
    for _, p in ipairs(positions) do
        if pointIn(x, y, p.x, p.y, p.w, p.h) then
            local id = p.a.id
            if id == "undo" then undo()
            elseif id == "redo" then redo()
            elseif id == "copy" then copySelection()
            elseif id == "grid" then me.showGrid = not me.showGrid
            elseif id == "save" then saveToServer()
            end
            return true
        end
    end

    return true
end

function M.mousepressedContent(x, y, button)
    if paletteClick(x, y, button) then return true end
    if toolbarClick(x, y, button) then return true end
    return true
end

function M.wheelmoved(_, dy)
    local me = State.mapEditor
    me.paletteScroll = math.max(0, me.paletteScroll - dy * 24)
end

function M.keypressed(key)
    local me = State.mapEditor
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    if ctrl and key == "z" then undo(); return true end
    if ctrl and key == "y" then redo(); return true end
    if ctrl and key == "s" then saveToServer(); return true end
    if ctrl and key == "c" then copySelection(); return true end
    if ctrl and key == "v" then
        local mx, my = State.mouse.x or 0, State.mouse.y or 0
        local tx, ty = worldTileFromScreen(mx, my)
        pasteAt(tx, ty)
        return true
    end
    if key == "g" then me.showGrid = not me.showGrid; return true end
    if key == "1" then me.layer = "ground"; return true end
    if key == "2" then me.layer = "decoration"; return true end
    if key == "3" then me.layer = "collision"; return true end
    if key == "4" then me.layer = "logic"; return true end
    return false
end

return M
