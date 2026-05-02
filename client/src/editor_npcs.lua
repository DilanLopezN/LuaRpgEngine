-- Aba "Criar NPCs" do editor unificado. Mantém um picker de sprites à
-- esquerda, um formulário central com kind/preview e a lista de NPCs já
-- posicionados à direita. A colocação é feita clicando no mundo: a tab
-- recebe `worldClick` do dispatcher do editor e grava direto em
-- Map.current.entities (mesmo lugar onde o map editor já guarda spawns e
-- NPCs). Persistência é via SAVE_MAP — compartilhamos o pipeline para não
-- introduzir um segundo formato server-side.

local State   = require("src.state")
local World   = require("src.world")
local Map     = require("src.map")
local Sprites = require("src.sprites")
local Network = require("src.network")
local JSON    = require("src.json")
local Layout  = require("src.editor_layout")
local Tooltip = require("src.tooltip")

local M = {}

local DEFAULT_KIND = "guard"

-- Layout helpers --------------------------------------------------------------

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local function paletteRect()
    local cx, cy, _, ch = Layout.contentRect()
    return cx + 16, cy + 14, 280, ch - 30
end

local function formRect()
    local cx, cy, cw, ch = Layout.contentRect()
    local lx, _, lw = paletteRect()
    local x = lx + lw + 14
    -- Reserve space for the placed-NPC list on the right.
    local listW = 320
    return x, cy + 14, cw - (lx - cx) - lw - listW - 30, ch - 30
end

local function listRect()
    local cx, cy, cw, ch = Layout.contentRect()
    local listW = 320
    return cx + cw - listW - 16, cy + 14, listW, ch - 30
end

M.panelRect = Layout.panelRect

-- ---------------------------------------------------------------------------
-- Helpers around Map.current.entities. Filtering by `type == "npc"` keeps
-- spawns/triggers placed by the map editor invisible to this tab.
-- ---------------------------------------------------------------------------

local function placedNPCs()
    local m = Map.current
    if not m or not m.entities then return {} end
    local out = {}
    for i, e in ipairs(m.entities) do
        if e.type == "npc" then
            out[#out + 1] = { idx = i, entity = e }
        end
    end
    return out
end

local function ensureCursorTile(sx, sy)
    local wx = sx + State.camera.x
    local wy = sy + State.camera.y
    local tx = math.floor(wx / World.TILE_W) + 1
    local ty = math.floor(wy / World.TILE_H) + 1
    return tx, ty
end

local function selectedSprite()
    return Sprites.npcSprite(State.npcEditor.spriteId)
        or Sprites.npcSprites[1]
end

-- ---------------------------------------------------------------------------
-- SAVE — reuses the SAVE_MAP wire path (the server already understands the
-- payload, validates it, and broadcasts MAP back to all clients).
-- ---------------------------------------------------------------------------

local function saveToServer()
    if not Map.current then return end
    if Network.connected and not Network.connected() then
        State.npcEditor.saveStatus = "offline (sem conexão)"
        return
    end
    local payload = JSON.encode(Map.current)
    Network.send("SAVE_MAP " .. payload)
    State.npcEditor.saveStatus = "envio realizado"
end

-- ---------------------------------------------------------------------------
-- Drawing — sprite picker
-- ---------------------------------------------------------------------------

local SPRITE_THUMB = 56  -- px square thumbnail in the picker

local function drawSpriteThumb(sprite, x, y, size)
    local img, quad, fw, fh = Sprites.frame(sprite.animName, love.timer.getTime())
    if not img then
        love.graphics.setColor(0.4, 0.4, 0.5)
        love.graphics.rectangle("fill", x, y, size, size, 4, 4)
        return
    end
    local scale = math.min((size - 6) / fw, (size - 6) / fh)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, quad,
        x + size / 2, y + size - 4,
        0, scale, scale, fw / 2, fh)
end

local function drawPalette()
    local lx, ly, lw, lh = paletteRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", lx, ly, lw, lh, 6, 6)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.95, 0.97, 1.0)
    love.graphics.print("Sprites", lx + 12, ly + 10)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.65, 0.74, 0.88)
    love.graphics.print(string.format("%d disponíveis", #Sprites.npcSprites),
        lx + lw - 100, ly + 12)

    local area = { x = lx + 8, y = ly + 36, w = lw - 16, h = lh - 50 }
    love.graphics.setScissor(area.x, area.y, area.w, area.h)

    local cellW, cellH, gap = 80, 96, 8
    local cols = math.max(1, math.floor((area.w + gap) / (cellW + gap)))
    local scroll = State.npcEditor.paletteScroll
    local i = 0
    for _, sp in ipairs(Sprites.npcSprites) do
        local col = i % cols
        local row = math.floor(i / cols)
        local cx = area.x + col * (cellW + gap)
        local cy = area.y + row * (cellH + gap) - scroll

        if cy + cellH >= area.y - 4 and cy <= area.y + area.h then
            local active = (sp.id == State.npcEditor.spriteId)
            local hover  = pointIn(mx, my, cx, cy, cellW, cellH)
            if active then
                love.graphics.setColor(0.20, 0.36, 0.60)
            elseif hover then
                love.graphics.setColor(0.16, 0.22, 0.32)
            else
                love.graphics.setColor(0.11, 0.14, 0.20)
            end
            love.graphics.rectangle("fill", cx, cy, cellW, cellH, 5, 5)
            love.graphics.setColor(active and 0.55 or 0.32,
                                   active and 0.78 or 0.42,
                                   active and 1.00 or 0.62)
            love.graphics.rectangle("line", cx, cy, cellW, cellH, 5, 5)

            drawSpriteThumb(sp, cx + (cellW - SPRITE_THUMB) / 2, cy + 6, SPRITE_THUMB)

            love.graphics.setFont(State.fonts.name)
            love.graphics.setColor(0.95, 0.97, 1.0)
            local lbl = sp.label or sp.id
            local lblW = State.fonts.name:getWidth(lbl)
            if lblW > cellW - 8 then
                love.graphics.printf(lbl, cx + 4, cy + cellH - 26, cellW - 8, "center")
            else
                love.graphics.print(lbl, cx + (cellW - lblW) / 2, cy + cellH - 18)
            end
            love.graphics.setColor(0.55, 0.65, 0.80)
            local cat = sp.category or ""
            local catW = State.fonts.name:getWidth(cat)
            love.graphics.print(cat, cx + (cellW - catW) / 2, cy + cellH - 32)

            if hover then
                Tooltip.hover(string.format("%s (%s)\nID do sprite: %s\nClique para selecionar.",
                    sp.label or sp.id, sp.category or "?", sp.id))
            end
        end
        i = i + 1
    end
    love.graphics.setScissor()

    -- Show "(scroll)" hint if content overflows the visible area.
    local rows = math.ceil(#Sprites.npcSprites / cols)
    local total = rows * (cellH + gap)
    if total > area.h then
        love.graphics.setColor(0.55, 0.65, 0.85, 0.7)
        love.graphics.setFont(State.fonts.name)
        love.graphics.printf("role o mouse para mais sprites",
            lx + 8, ly + lh - 16, lw - 16, "center")
    end
end

-- ---------------------------------------------------------------------------
-- Drawing — central form (preview + kind + place hint)
-- ---------------------------------------------------------------------------

local function drawForm()
    local fx, fy, fw, fh = formRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", fx, fy, fw, fh, 6, 6)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.95, 0.97, 1.0)
    love.graphics.print("NPC selecionado", fx + 14, fy + 10)

    -- Sprite preview, big, centered. Doubles as the visual feedback that
    -- the picked sprite is the one that will be placed.
    local sprite = selectedSprite()
    local previewSize = math.min(fw - 32, 180)
    local px = fx + (fw - previewSize) / 2
    local py = fy + 38
    love.graphics.setColor(0.10, 0.13, 0.18)
    love.graphics.rectangle("fill", px, py, previewSize, previewSize, 6, 6)
    love.graphics.setColor(0.45, 0.78, 1.0, 0.18)
    love.graphics.rectangle("line", px, py, previewSize, previewSize, 6, 6)
    if sprite then
        local img, quad, sfw, sfh = Sprites.frame(sprite.animName, love.timer.getTime())
        if img then
            local scale = math.min((previewSize - 24) / sfw,
                                   (previewSize - 24) / sfh) * 1.6
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(img, quad,
                px + previewSize / 2, py + previewSize - 18,
                0, scale, scale, sfw / 2, sfh)
        end
        -- Caption.
        love.graphics.setFont(State.fonts.ui)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(sprite.label or sprite.id,
            fx + 14, py + previewSize + 12, fw - 28, "center")
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(0.62, 0.74, 0.92)
        love.graphics.printf("categoria: " .. (sprite.category or "—"),
            fx + 14, py + previewSize + 32, fw - 28, "center")
    else
        love.graphics.setFont(State.fonts.ui)
        love.graphics.setColor(0.85, 0.40, 0.40)
        love.graphics.printf("Nenhum sprite carregado",
            fx + 14, py + previewSize / 2 - 8, fw - 28, "center")
    end

    -- Kind input. Plain text field; same focus pattern as the spells form
    -- ("editorFocus" — set on click, cleared on Esc).
    local kindLabelY = py + previewSize + 60
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print("Tipo (NPC ID)", fx + 14, kindLabelY)
    local txY = kindLabelY + 22
    local txX, txW, txH = fx + 14, fw - 28, 30
    local focused = State.editorFocus == "npcKind"
    love.graphics.setColor(focused and 0.20 or 0.12,
                           focused and 0.27 or 0.16,
                           focused and 0.36 or 0.22)
    love.graphics.rectangle("fill", txX, txY, txW, txH, 5, 5)
    love.graphics.setColor(focused and 0.65 or 0.36, 0.55, 0.78)
    love.graphics.rectangle("line", txX, txY, txW, txH, 5, 5)
    love.graphics.setColor(1, 1, 1)
    local txt = State.npcEditor.npcKind or ""
    if focused and (math.floor(love.timer.getTime() * 2) % 2) == 0 then
        txt = txt .. "_"
    end
    love.graphics.print(txt, txX + 8, txY + 7)
    if pointIn(mx, my, txX, txY, txW, txH) then
        Tooltip.hover("ID do NPC (ex.: guard, merchant). Casa com data/scripts/npcs/<id>.lua para diálogo.")
    end

    -- Place / save buttons.
    local btnY = txY + txH + 16
    local hint = "Clique no mapa para posicionar. Botão direito remove o NPC sob o cursor."
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.62, 0.74, 0.92)
    love.graphics.printf(hint, fx + 14, btnY, fw - 28, "left")

    local saveX, saveY, saveW, saveH = fx + 14, fy + fh - 44, fw - 28, 30
    local hover = pointIn(mx, my, saveX, saveY, saveW, saveH)
    love.graphics.setColor(hover and 0.26 or 0.20,
                           hover and 0.55 or 0.45,
                           hover and 0.32 or 0.25)
    love.graphics.rectangle("fill", saveX, saveY, saveW, saveH, 5, 5)
    love.graphics.setColor(0.5, 0.7, 0.6, 0.8)
    love.graphics.rectangle("line", saveX, saveY, saveW, saveH, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.printf("Salvar Mapa (Ctrl+S)", saveX, saveY + 6, saveW, "center")
    if hover then
        Tooltip.hover("Persistir as posições de NPCs no servidor (envia SAVE_MAP).")
    end

    if State.npcEditor.saveStatus and State.npcEditor.saveStatus ~= "" then
        love.graphics.setColor(0.95, 0.85, 0.40)
        love.graphics.setFont(State.fonts.name)
        love.graphics.print("salvar: " .. State.npcEditor.saveStatus,
            fx + 14, saveY - 18)
    end
end

-- ---------------------------------------------------------------------------
-- Drawing — placed-NPC list (right column) + per-row delete button.
-- ---------------------------------------------------------------------------

local LIST_ROW_H = 44

local function placedRows()
    -- Computes the absolute y of every row plus the rect for the delete
    -- button so draw + click hit-test stay in sync.
    local lx, ly, lw, lh = listRect()
    local headerH = 36
    local area = { x = lx + 6, y = ly + headerH, w = lw - 12, h = lh - headerH - 6 }
    local rows = {}
    local list = placedNPCs()
    local scroll = State.npcEditor.listScroll
    for i, p in ipairs(list) do
        local rx = area.x
        local ry = area.y + (i - 1) * (LIST_ROW_H + 4) - scroll
        rows[i] = {
            entry = p, x = rx, y = ry,
            w = area.w, h = LIST_ROW_H,
            delX = rx + area.w - 32, delY = ry + (LIST_ROW_H - 24) / 2,
            delW = 26, delH = 24,
        }
    end
    return rows, area, list
end

local function drawList()
    local lx, ly, lw, lh = listRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", lx, ly, lw, lh, 6, 6)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.95, 0.97, 1.0)
    love.graphics.print("NPCs no mapa", lx + 12, ly + 10)

    local rows, area, list = placedRows()
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.65, 0.74, 0.88)
    love.graphics.print(string.format("%d posicionados", #list),
        lx + lw - 110, ly + 12)

    if #list == 0 then
        love.graphics.setColor(0.75, 0.80, 0.90)
        love.graphics.printf(
            "Nenhum NPC posicionado.\nEscolha um sprite, defina o ID e clique no mapa.",
            lx + 12, ly + 60, lw - 24, "center")
        return
    end

    love.graphics.setScissor(area.x, area.y, area.w, area.h)
    for _, r in ipairs(rows) do
        if r.y + r.h >= area.y - 4 and r.y <= area.y + area.h then
            local hover = pointIn(mx, my, r.x, r.y, r.w, r.h)
            love.graphics.setColor(hover and 0.16 or 0.11,
                                   hover and 0.20 or 0.14,
                                   hover and 0.28 or 0.20)
            love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 5, 5)
            love.graphics.setColor(0.30, 0.42, 0.66, 0.5)
            love.graphics.rectangle("line", r.x, r.y, r.w, r.h, 5, 5)

            local sprite = Sprites.npcSprite(r.entry.entity.sprite or "")
            if sprite then
                drawSpriteThumb(sprite, r.x + 4, r.y + 4, r.h - 8)
            else
                love.graphics.setColor(0.4, 0.42, 0.5)
                love.graphics.rectangle("fill", r.x + 4, r.y + 4,
                    r.h - 8, r.h - 8, 4, 4)
            end

            love.graphics.setFont(State.fonts.ui)
            love.graphics.setColor(1, 1, 1)
            local lbl = r.entry.entity.kind or "?"
            love.graphics.print(lbl, r.x + r.h, r.y + 6)
            love.graphics.setFont(State.fonts.name)
            love.graphics.setColor(0.65, 0.74, 0.88)
            love.graphics.print(string.format("(%d, %d) — %s",
                r.entry.entity.x, r.entry.entity.y,
                (sprite and (sprite.label or sprite.id))
                    or (r.entry.entity.sprite or "sem sprite")),
                r.x + r.h, r.y + 22)

            local delHover = pointIn(mx, my, r.delX, r.delY, r.delW, r.delH)
            love.graphics.setColor(delHover and 0.85 or 0.45,
                                   delHover and 0.30 or 0.18,
                                   delHover and 0.30 or 0.22)
            love.graphics.rectangle("fill",
                r.delX, r.delY, r.delW, r.delH, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(State.fonts.ui)
            local delW = State.fonts.ui:getWidth("✕")
            love.graphics.print("✕",
                r.delX + (r.delW - delW) / 2,
                r.delY + (r.delH - State.fonts.ui:getHeight()) / 2 - 1)
            if delHover then
                Tooltip.hover("Remover este NPC do mapa.")
            end
        end
    end
    love.graphics.setScissor()
end

function M.drawContent()
    drawPalette()
    drawForm()
    drawList()
end

-- ---------------------------------------------------------------------------
-- World-side cursor preview: ghost sprite at the tile under the mouse.
-- ---------------------------------------------------------------------------

function M.drawCursor()
    if State.editorTab ~= "npcs" or not State.editorOpen then return end
    if not Map.current then return end
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local px, py, pw, ph = Layout.panelRect()
    if pointIn(mx, my, px, py, pw, ph) then return end

    local tx, ty = ensureCursorTile(mx, my)
    if not Map.inBounds(tx, ty) then return end

    local sx = (tx - 1) * World.TILE_W - State.camera.x
    local sy = (ty - 1) * World.TILE_H - State.camera.y

    -- Tile highlight.
    love.graphics.setColor(0.45, 0.78, 1.0, 0.85)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", sx, sy, World.TILE_W, World.TILE_H, 2, 2)
    love.graphics.setLineWidth(1)

    -- Ghost sprite.
    local sprite = selectedSprite()
    if sprite then
        local img, quad, fw, fh = Sprites.frame(sprite.animName,
            love.timer.getTime())
        if img then
            love.graphics.setColor(1, 1, 1, 0.55)
            love.graphics.draw(img, quad,
                sx + World.TILE_W / 2, sy + World.TILE_H + 2,
                0, 1.4, 1.4, fw / 2, fh)
        end
    end

    -- Floating label with kind/coords.
    love.graphics.setFont(State.fonts.name)
    local label = string.format("%s @ (%d,%d)",
        State.npcEditor.npcKind or "?", tx - 1, ty - 1)
    local lw = State.fonts.name:getWidth(label) + 8
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", mx + 14, my + 14, lw, 18, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, mx + 18, my + 16)
end

-- ---------------------------------------------------------------------------
-- World click — place / remove an NPC at the targeted tile.
-- ---------------------------------------------------------------------------

function M.worldClick(sx, sy, button)
    if not Map.current then return end
    local tx, ty = ensureCursorTile(sx, sy)
    if not Map.inBounds(tx, ty) then return end
    button = button or 1

    if button == 2 then
        -- Right click: remove the topmost NPC on this tile.
        for i = #Map.current.entities, 1, -1 do
            local e = Map.current.entities[i]
            if e.type == "npc" and e.x == tx - 1 and e.y == ty - 1 then
                table.remove(Map.current.entities, i)
                return
            end
        end
        return
    end

    local sprite = selectedSprite()
    Map.current.entities[#Map.current.entities + 1] = {
        type   = "npc",
        kind   = State.npcEditor.npcKind ~= "" and State.npcEditor.npcKind or DEFAULT_KIND,
        sprite = sprite and sprite.id or nil,
        x      = tx - 1,
        y      = ty - 1,
    }
end

-- M.worldDrag / M.worldRelease intentionally omitted: NPC placement is
-- discrete (one click = one NPC). Holding the mouse should *not* spam.

-- ---------------------------------------------------------------------------
-- Panel input
-- ---------------------------------------------------------------------------

local function paletteClick(x, y)
    local lx, ly, lw, lh = paletteRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end

    local area = { x = lx + 8, y = ly + 36, w = lw - 16, h = lh - 50 }
    if not pointIn(x, y, area.x, area.y, area.w, area.h) then return true end

    local cellW, cellH, gap = 80, 96, 8
    local cols = math.max(1, math.floor((area.w + gap) / (cellW + gap)))
    local scroll = State.npcEditor.paletteScroll
    local relY = y - area.y + scroll
    local row = math.floor(relY / (cellH + gap))
    local col = math.floor((x - area.x) / (cellW + gap))
    if col < 0 or col >= cols or row < 0 then return true end
    local idx = row * cols + col + 1
    local sp = Sprites.npcSprites[idx]
    if sp then
        State.npcEditor.spriteId = sp.id
        State.editorFocus = nil
    end
    return true
end

local function formClick(x, y)
    local fx, fy, fw, fh = formRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end

    -- Match the geometry computed in drawForm so inputs land where they
    -- look like they should.
    local previewSize = math.min(fw - 32, 180)
    local py = fy + 38
    local kindLabelY = py + previewSize + 60
    local txY = kindLabelY + 22
    local txX, txW, txH = fx + 14, fw - 28, 30
    if pointIn(x, y, txX, txY, txW, txH) then
        State.editorFocus = "npcKind"
        return true
    end

    local saveX, saveY, saveW, saveH = fx + 14, fy + fh - 44, fw - 28, 30
    if pointIn(x, y, saveX, saveY, saveW, saveH) then
        saveToServer()
        State.editorFocus = nil
        return true
    end

    State.editorFocus = nil
    return true
end

local function listClick(x, y)
    local lx, ly, lw, lh = listRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end

    local rows = placedRows()
    for _, r in ipairs(rows) do
        if pointIn(x, y, r.delX, r.delY, r.delW, r.delH) then
            table.remove(Map.current.entities, r.entry.idx)
            return true
        end
    end
    return true -- absorb panel clicks even if we didn't act
end

function M.mousepressedContent(x, y, button)
    button = button or 1
    if button == 1 then
        if paletteClick(x, y) then return true end
        if listClick(x, y)    then return true end
        if formClick(x, y)    then return true end
    end
    return true
end

-- Wheel inside the panel scrolls whichever sub-pane the cursor is over.
function M.wheelmoved(_, dy)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    if pointIn(mx, my, paletteRect()) then
        State.npcEditor.paletteScroll = math.max(0,
            State.npcEditor.paletteScroll - dy * 30)
        return
    end
    if pointIn(mx, my, listRect()) then
        State.npcEditor.listScroll = math.max(0,
            State.npcEditor.listScroll - dy * 30)
    end
end

-- Text + key input for the kind field.
function M.textinput(t)
    if not State.editorFocus then return false end
    if State.editorFocus ~= "npcKind" then return false end
    if #(State.npcEditor.npcKind or "") >= 24 then return true end
    if t:match("[%w_%-]") then
        State.npcEditor.npcKind = (State.npcEditor.npcKind or "") .. t
    end
    return true
end

function M.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    if ctrl and key == "s" then saveToServer(); return true end

    if State.editorFocus == "npcKind" then
        if key == "backspace" then
            State.npcEditor.npcKind = (State.npcEditor.npcKind or ""):sub(1, -2)
            return true
        elseif key == "return" or key == "kpenter" then
            State.editorFocus = nil
            return true
        end
        return true
    end
    return false
end

return M
