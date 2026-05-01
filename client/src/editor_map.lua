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

local M = {}

local UNDO_LIMIT = 32

local LAYERS = { "ground", "decoration", "collision", "logic" }
local TOOLS  = { "paint", "fill", "erase", "select", "entity" }
local ENTITY_TYPES = { "spawn", "npc", "trigger" }
local ENTITY_KINDS = { "orc", "guard", "merchant", "warp", "marker" }

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

-- ---------------------------------------------------------------------------
-- Layout. The map editor reuses the spells editor's outer panel; it splits
-- the inside into a left toolbar/palette and a right hint area.
-- ---------------------------------------------------------------------------

local function panelRect()
    local W, H = love.graphics.getDimensions()
    local margin = 30
    local skillBarReserved = 96
    return margin, margin, W - 2 * margin, H - 2 * margin - skillBarReserved
end

local function paletteRect()
    local px, py, _, ph = panelRect()
    return px + 16, py + 64, 320, ph - 80
end

local function toolbarRect()
    local px, py, pw, ph = panelRect()
    local _, _, lw, _ = paletteRect()
    return px + 16 + lw + 16, py + 64, pw - lw - 48, ph - 80
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
        State.mapEditor.saveStatus = "offline (not connected)"
        return
    end
    local payload = JSON.encode(Map.current)
    Network.send("SAVE_MAP " .. payload)
    State.mapEditor.saveStatus = "save sent"
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
        love.graphics.printf("Tile palette is hidden for non-visual layers."
            .. "\nLeft-click world: set marker. Right-click: clear.",
            lx + 8, ly + 70, lw - 16, "left")
        return
    end

    local ts = tilesets[me.tilesetIndex]
    if not ts or not ts.image then
        love.graphics.setColor(0.85, 0.4, 0.4)
        love.graphics.printf("Tileset image missing or not loaded.",
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
end

local function drawToolbar()
    local fx, fy, fw, fh = toolbarRect()
    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", fx, fy, fw, fh, 4, 4)

    local me = State.mapEditor
    love.graphics.setFont(State.fonts.ui)

    local y = fy + 12
    local function row(title, items, current, getLabel)
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.print(title, fx + 12, y + 6)
        local x = fx + 110
        for _, it in ipairs(items) do
            local label = getLabel and getLabel(it) or it
            local w = State.fonts.ui:getWidth(label) + 16
            if it == current then
                love.graphics.setColor(0.25, 0.42, 0.65)
            else
                love.graphics.setColor(0.13, 0.15, 0.20)
            end
            love.graphics.rectangle("fill", x, y, w, 24, 4, 4)
            love.graphics.setColor(0.4, 0.5, 0.6)
            love.graphics.rectangle("line", x, y, w, 24, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(label, x + 8, y + 5)
            x = x + w + 6
        end
        y = y + 32
    end

    row("Tool", TOOLS, me.tool)
    row("Layer", LAYERS, me.layer)
    if me.tool == "entity" then
        row("Entity", ENTITY_TYPES, me.entityType)
        row("Kind", ENTITY_KINDS, me.entityKind)
    end

    -- Action buttons row
    local actions = {
        { id = "undo",  label = "Undo (Ctrl+Z)" },
        { id = "redo",  label = "Redo (Ctrl+Y)" },
        { id = "copy",  label = "Copy Sel" },
        { id = "grid",  label = me.showGrid and "Grid: ON" or "Grid: OFF" },
        { id = "save",  label = "Save Map" },
    }
    local x = fx + 12
    for _, a in ipairs(actions) do
        local w = State.fonts.ui:getWidth(a.label) + 18
        if a.id == "save" then
            love.graphics.setColor(0.20, 0.45, 0.25)
        else
            love.graphics.setColor(0.18, 0.22, 0.30)
        end
        love.graphics.rectangle("fill", x, y, w, 26, 4, 4)
        love.graphics.setColor(0.4, 0.5, 0.6)
        love.graphics.rectangle("line", x, y, w, 26, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(a.label, x + 9, y + 6)
        x = x + w + 6
    end
    y = y + 36

    love.graphics.setColor(0.65, 0.75, 0.9)
    local m = Map.current
    if m then
        love.graphics.print(string.format(
            "map: %s   %dx%d   entities: %d   layer: %s",
            m.name, m.width, m.height, #m.entities, me.layer),
            fx + 12, y)
        y = y + 22
    end
    if me.saveStatus and me.saveStatus ~= "" then
        love.graphics.setColor(0.95, 0.85, 0.40)
        love.graphics.print("save: " .. me.saveStatus, fx + 12, y)
        y = y + 22
    end

    love.graphics.setColor(0.6, 0.7, 0.85)
    love.graphics.printf(
        "Click on the world to use the active tool. Right-click erases. "
        .. "F1 toggles editor. While editing, the map renders live; press "
        .. "Save Map to persist on the server (creates a .bak of the previous "
        .. "version). Use Layer=collision to define walkable areas.",
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
    local function rowHit(items, current, setter)
        local xx = fx + 110
        for _, it in ipairs(items) do
            local label = it
            local w = State.fonts.ui:getWidth(label) + 16
            if pointIn(x, y, xx, yy, w, 24) then
                setter(it)
                return true
            end
            xx = xx + w + 6
        end
        return false
    end

    if rowHit(TOOLS,  me.tool,  function(v) me.tool  = v end) then return true end
    yy = yy + 32
    if rowHit(LAYERS, me.layer, function(v) me.layer = v end) then return true end
    yy = yy + 32
    if me.tool == "entity" then
        if rowHit(ENTITY_TYPES, me.entityType,
                function(v) me.entityType = v end) then return true end
        yy = yy + 32
        if rowHit(ENTITY_KINDS, me.entityKind,
                function(v) me.entityKind = v end) then return true end
        yy = yy + 32
    end

    -- action buttons
    local actions = {
        { id = "undo",  label = "Undo (Ctrl+Z)" },
        { id = "redo",  label = "Redo (Ctrl+Y)" },
        { id = "copy",  label = "Copy Sel" },
        { id = "grid",  label = me.showGrid and "Grid: ON" or "Grid: OFF" },
        { id = "save",  label = "Save Map" },
    }
    local xx = fx + 12
    for _, a in ipairs(actions) do
        local w = State.fonts.ui:getWidth(a.label) + 18
        if pointIn(x, y, xx, yy, w, 26) then
            if a.id == "undo" then undo()
            elseif a.id == "redo" then redo()
            elseif a.id == "copy" then copySelection()
            elseif a.id == "grid" then me.showGrid = not me.showGrid
            elseif a.id == "save" then saveToServer()
            end
            return true
        end
        xx = xx + w + 6
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
