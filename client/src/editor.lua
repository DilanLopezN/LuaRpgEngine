-- Unified F1 engine editor. Owns the outer panel/tab strip and dispatches
-- input + drawing to the active tab module.
--
-- Tabs:
--   "map"    → editor_map    (Phase 1: tilemap editing)
--   "spells" → editor_spells (legacy spell creator)

local State        = require("src.state")
local EditorSpells = require("src.editor_spells")
local EditorMap    = require("src.editor_map")
local Map          = require("src.map")

local M = {}

local TABS = {
    { id = "map",    label = "Map Editor"    },
    { id = "spells", label = "Spell Creator" },
}

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local function panelRect()
    local W, H = love.graphics.getDimensions()
    local margin = 30
    local skillBarReserved = 96
    return margin, margin, W - 2 * margin, H - 2 * margin - skillBarReserved
end
M.panelRect = panelRect

local function activeTab()
    if State.editorTab == "spells" then return EditorSpells end
    return EditorMap
local function listRect()
    local px, py, _, ph = panelRect()
    return px + 16, py + 64, 260, ph - 80
end

local function formRect()
    local px, py, pw, ph = panelRect()
    local _, _, lw, _ = listRect()
    return px + 16 + lw + 16, py + 64, pw - lw - 48, ph - 80
end

local function newSpell()
    return {
        name     = "New Spell",
        kind     = "line",
        effect   = "damage",
        range    = 5,
        radius   = 1,
        power    = 12,
        manaCost = 12,
        cooldown = 0.7,
        color    = { 0.95, 0.45, 0.20 },
    }
end

local function selected()
    return State.editorSelected and Spells.byId[State.editorSelected]
end
M.selected = selected

local function registerWithServer(spell)
    if Network.connected and not Network.connected() then return end
    Network.send("REGSPELL " .. Spells.serialize(spell))
end

local function unregisterWithServer(id)
    if Network.connected and not Network.connected() then return end
    Network.send("DELSPELL " .. id)
end

local function persist(spell)
    if spell then registerWithServer(spell) end
end

local function loseFocus()
    if State.editorFocus then
        local sp = selected()
        if sp then registerWithServer(sp) end
        State.editorFocus = nil
    end
end

-- ---------------------------------------------------------------------------
-- Form fields layout
--
-- The same layout function is consumed by draw() and the click handler so
-- positions stay in sync.
-- ---------------------------------------------------------------------------

local function formFields(spell)
    local fx, fy, fw, fh = formRect()
    local rows = {}
    local y = fy + 16

    local function row(field)
        field.x = fx + 16
        field.y = y
        field.w = fw - 32
        field.h = field.h or FIELD_H
        rows[#rows + 1] = field
        y = y + field.h + FIELD_GAP
    end

    row{ name = "name",   type = "text",   label = "Name",   value = spell.name or "" }
    row{ name = "kind",   type = "toggle", label = "Kind",   value = spell.kind,
         options = Spells.KINDS }

    if spell.kind == "line" then
        row{ name = "range",  type = "stepper", label = "Range",
             value = spell.range, step = 1, min = 1, max = 20 }
    elseif spell.kind == "area" then
        row{ name = "radius", type = "stepper", label = "Radius",
             value = spell.radius, step = 1, min = 0, max = 6 }
    end

    row{ name = "effect",   type = "toggle",  label = "Effect",
         value = spell.effect, options = Spells.EFFECTS }
    row{ name = "power",    type = "stepper", label = "Power",
         value = spell.power, step = 5, min = 0, max = 500 }
    row{ name = "manaCost", type = "stepper", label = "Mana Cost",
         value = spell.manaCost, step = 5, min = 0, max = 500 }
    row{ name = "cooldown", type = "stepper", label = "Cooldown (s)",
         value = spell.cooldown, step = 0.1, min = 0.1, max = 10, decimals = 1 }
    row{ name = "colorR",   type = "stepper", label = "Color R",
         value = math.floor((spell.color[1] or 0) * 255 + 0.5),
         step = 17, min = 0, max = 255 }
    row{ name = "colorG",   type = "stepper", label = "Color G",
         value = math.floor((spell.color[2] or 0) * 255 + 0.5),
         step = 17, min = 0, max = 255 }
    row{ name = "colorB",   type = "stepper", label = "Color B",
         value = math.floor((spell.color[3] or 0) * 255 + 0.5),
         step = 17, min = 0, max = 255 }

    local by = fy + fh - 40
    rows[#rows + 1] = { type = "button", name = "delete",
        label = "Delete", x = fx + 16, y = by, w = 100, h = 28,
        color = { 0.50, 0.20, 0.20 } }
    rows[#rows + 1] = { type = "label",  name = "hint",
        text  = "Drag the spell card on the left into a skillbar slot.",
        x = fx + 16 + 116, y = by + 6 }

    return rows
end

local function applyStep(spell, row, delta)
    local val = (row.value or 0) + delta
    if val < row.min then val = row.min end
    if val > row.max then val = row.max end
    if row.name == "colorR" then
        spell.color[1] = val / 255
    elseif row.name == "colorG" then
        spell.color[2] = val / 255
    elseif row.name == "colorB" then
        spell.color[3] = val / 255
    elseif row.decimals then
        spell[row.name] = math.floor(val * 10 + 0.5) / 10
    else
        spell[row.name] = val
    end
end

-- ---------------------------------------------------------------------------
-- Drawing
-- ---------------------------------------------------------------------------

local function drawListAndCards()
    local lx, ly, lw, lh = listRect()
    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", lx, ly, lw, lh, 4, 4)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.20, 0.45, 0.25)
    love.graphics.rectangle("fill", lx + 6, ly + 6, lw - 12, 28, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("+ New Spell", lx + 18, ly + 11)

    love.graphics.setFont(State.fonts.name)
    local cardH = 56
    local cardY = ly + 44
    for i, sp in ipairs(Spells.list) do
        local cx = lx + 6
        local cy = cardY + (i - 1) * (cardH + 6)
        if cy + cardH > ly + lh then break end
        local hidden = State.drag and State.drag.source == "editor"
            and State.drag.spellId == sp.id
        if not hidden then
            if sp.id == State.editorSelected then
                love.graphics.setColor(0.22, 0.34, 0.55)
            else
                love.graphics.setColor(0.13, 0.15, 0.20)
            end
            love.graphics.rectangle("fill", cx, cy, lw - 12, cardH, 4, 4)
            love.graphics.setColor(0.35, 0.40, 0.50)
            love.graphics.rectangle("line", cx, cy, lw - 12, cardH, 4, 4)
            Icons.drawSpell(sp, cx + 4, cy + 4, cardH - 8, cardH - 8, nil)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(sp.name or "?", cx + cardH + 4, cy + 6)
            love.graphics.setColor(0.7, 0.75, 0.85)
            love.graphics.print(string.format("%s · %s", sp.kind, sp.effect),
                cx + cardH + 4, cy + 22)
            love.graphics.setColor(0.55, 0.7, 0.95)
            love.graphics.print("drag to skillbar →", cx + cardH + 4, cy + 38)
        end
    end

    if #Spells.list == 0 then
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.printf("No spells yet.\nClick \"+ New Spell\" to create one.",
            lx + 12, ly + 80, lw - 24, "center")
    end
end

local function drawForm()
    local fx, fy, fw, fh = formRect()
    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", fx, fy, fw, fh, 4, 4)

    local spell = selected()
    if not spell then
        love.graphics.setFont(State.fonts.ui)
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.printf(
            "Select a spell on the left or click \"+ New Spell\" to create one.",
            fx + 16, fy + 24, fw - 32, "left")
        return
    end

    local rows = formFields(spell)
    love.graphics.setFont(State.fonts.ui)

    for _, r in ipairs(rows) do
        if r.type == "text" then
            love.graphics.setColor(0.7, 0.75, 0.85)
            love.graphics.print(r.label, r.x, r.y + 6)
            local tx = r.x + LABEL_W
            local tw = r.w - LABEL_W
            local focused = State.editorFocus == r.name
            love.graphics.setColor(focused and 0.20 or 0.13,
                                   focused and 0.25 or 0.15,
                                   focused and 0.32 or 0.20)
            love.graphics.rectangle("fill", tx, r.y, tw, r.h, 4, 4)
            love.graphics.setColor(focused and 0.7 or 0.4, 0.5, 0.7)
            love.graphics.rectangle("line", tx, r.y, tw, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            local txt = r.value or ""
            if focused and (math.floor(love.timer.getTime() * 2) % 2) == 0 then
                txt = txt .. "_"
            end
            love.graphics.print(txt, tx + 6, r.y + 6)
        elseif r.type == "toggle" then
            love.graphics.setColor(0.7, 0.75, 0.85)
            love.graphics.print(r.label, r.x, r.y + 6)
            local ox = r.x + LABEL_W
            for _, opt in ipairs(r.options) do
                local ow = State.fonts.ui:getWidth(opt) + 22
                if r.value == opt then
                    love.graphics.setColor(0.25, 0.42, 0.65)
                else
                    love.graphics.setColor(0.13, 0.15, 0.20)
                end
                love.graphics.rectangle("fill", ox, r.y, ow, r.h, 4, 4)
                love.graphics.setColor(0.4, 0.5, 0.6)
                love.graphics.rectangle("line", ox, r.y, ow, r.h, 4, 4)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(opt, ox + 11, r.y + 6)
                ox = ox + ow + 6
            end
        elseif r.type == "stepper" then
            love.graphics.setColor(0.7, 0.75, 0.85)
            love.graphics.print(r.label, r.x, r.y + 6)
            local sx = r.x + LABEL_W
            local sw = r.w - LABEL_W
            local btnW = 26

            love.graphics.setColor(0.20, 0.30, 0.45)
            love.graphics.rectangle("fill", sx, r.y, btnW, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("-", sx + btnW / 2 - 4, r.y + 6)

            love.graphics.setColor(0.13, 0.15, 0.20)
            love.graphics.rectangle("fill", sx + btnW + 4, r.y,
                sw - btnW * 2 - 8, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            local vstr
            if r.decimals then
                vstr = string.format("%." .. r.decimals .. "f", r.value)
            else
                vstr = tostring(r.value)
            end
            love.graphics.print(vstr, sx + btnW + 12, r.y + 6)

            love.graphics.setColor(0.20, 0.30, 0.45)
            love.graphics.rectangle("fill", sx + sw - btnW, r.y,
                btnW, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("+", sx + sw - btnW + btnW / 2 - 4, r.y + 6)
        elseif r.type == "button" then
            love.graphics.setColor(r.color)
            love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 4, 4)
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("line", r.x, r.y, r.w, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(r.label, r.x + 12, r.y + 6)
        elseif r.type == "label" then
            love.graphics.setColor(0.65, 0.75, 0.9)
            love.graphics.print(r.text, r.x, r.y)
        end
    end
end

function M.draw()
    if not State.editorOpen then return end
    if State.scene ~= State.SCENE_PLAYING then return end

    if State.editorTab == "map" then
        EditorMap.drawCursor()
    end

    local W, H = love.graphics.getDimensions()
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local px, py, pw, ph = panelRect()
    love.graphics.setColor(0.10, 0.12, 0.16, 0.97)
    love.graphics.rectangle("fill", px, py, pw, ph, 8, 8)
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.rectangle("line", px, py, pw, ph, 8, 8)

    love.graphics.setFont(State.fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Engine Editor", px + 16, py + 10)

    love.graphics.setFont(State.fonts.ui)
    local cx, cy = px + pw - 36, py + 14
    love.graphics.setColor(0.45, 0.18, 0.18)
    love.graphics.rectangle("fill", cx, cy, 22, 22, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X", cx + 7, cy + 3)

    local tx = px + 16
    local ty = py + 50
    for _, t in ipairs(TABS) do
        local tw = State.fonts.ui:getWidth(t.label) + 24
        local th = 22
        if t.id == State.editorTab then
            love.graphics.setColor(0.22, 0.34, 0.55)
        else
            love.graphics.setColor(0.15, 0.18, 0.22)
        end
        love.graphics.rectangle("fill", tx, ty, tw, th, 4, 4)
        love.graphics.setColor(0.5, 0.6, 0.8)
        love.graphics.rectangle("line", tx, ty, tw, th, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(t.label, tx + 12, ty + 4)
        tx = tx + tw + 8
    end

    local tab = activeTab()
    if tab and tab.drawContent then tab.drawContent() end
end

local function clickedTab(x, y)
    local px, py = panelRect()
    local tx = px + 16
    local ty = py + 50
    for _, t in ipairs(TABS) do
        local tw = State.fonts.ui:getWidth(t.label) + 24
        if pointIn(x, y, tx, ty, tw, 22) then
            State.editorTab = t.id
            State.editorFocus = nil
-- ---------------------------------------------------------------------------
-- Input
-- ---------------------------------------------------------------------------

local function listClick(x, y)
    local lx, ly, lw, lh = listRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end

    if pointIn(x, y, lx + 6, ly + 6, lw - 12, 28) then
        loseFocus()
        local sp = Spells.add(newSpell())
        State.editorSelected = sp.id
        registerWithServer(sp)
        return true
    end

    local cardH = 56
    local cardY = ly + 44
    for i, sp in ipairs(Spells.list) do
        local cx = lx + 6
        local cy = cardY + (i - 1) * (cardH + 6)
        if cy + cardH > ly + lh then break end
        if pointIn(x, y, cx, cy, lw - 12, cardH) then
            loseFocus()
            State.editorSelected = sp.id
            State.drag = { spellId = sp.id, source = "editor" }
            return true
        end
        tx = tx + tw + 8
    end
    return false
    return true -- absorbed: clicked inside list
end

local function formClick(x, y)
    local fx, fy, fw, fh = formRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end
    local spell = selected()
    if not spell then return true end

    local rows = formFields(spell)
    for _, r in ipairs(rows) do
        if r.type == "text" then
            local tx = r.x + LABEL_W
            local tw = r.w - LABEL_W
            if pointIn(x, y, tx, r.y, tw, r.h) then
                State.editorFocus = r.name
                return true
            end
        elseif r.type == "toggle" then
            local ox = r.x + LABEL_W
            for _, opt in ipairs(r.options) do
                local ow = State.fonts.ui:getWidth(opt) + 22
                if pointIn(x, y, ox, r.y, ow, r.h) then
                    loseFocus()
                    spell[r.name] = opt
                    persist(spell)
                    return true
                end
                ox = ox + ow + 6
            end
        elseif r.type == "stepper" then
            local sx = r.x + LABEL_W
            local sw = r.w - LABEL_W
            local btnW = 26
            if pointIn(x, y, sx, r.y, btnW, r.h) then
                loseFocus()
                applyStep(spell, r, -r.step)
                persist(spell)
                return true
            elseif pointIn(x, y, sx + sw - btnW, r.y, btnW, r.h) then
                loseFocus()
                applyStep(spell, r, r.step)
                persist(spell)
                return true
            end
        elseif r.type == "button" then
            if pointIn(x, y, r.x, r.y, r.w, r.h) then
                if r.name == "delete" then
                    State.editorFocus = nil
                    local id = spell.id
                    Spells.remove(id)
                    for i = 1, 5 do
                        if State.skillbar[i] == id then
                            State.skillbar[i] = nil
                        end
                    end
                    State.editorSelected = nil
                    unregisterWithServer(id)
                end
                return true
            end
        end
    end
    loseFocus()
    return true
end

function M.mousepressed(x, y, button)
    if not State.editorOpen then return false end
    if State.scene ~= State.SCENE_PLAYING then return false end
    button = button or 1

    local px, py, pw, ph = panelRect()

    if pointIn(x, y, px + pw - 36, py + 14, 22, 22) then
        loseFocus()
        State.editorOpen = false
        return true
    end

    if not pointIn(x, y, px, py, pw, ph) then
        -- Click outside the panel: world-level edit when on Map tab.
        if State.editorTab == "map" and Map.current then
            EditorMap.worldClick(x, y, button)
            return true
        end
        return false
    end

    if clickedTab(x, y) then return true end

    local tab = activeTab()
    if tab and tab.mousepressedContent then
        return tab.mousepressedContent(x, y, button)
    end
    loseFocus()
    return true
end

function M.mousemoved(x, y, dx, dy)
    if not State.editorOpen then return false end
    if State.scene ~= State.SCENE_PLAYING then return false end
    if State.editorTab ~= "map" then return false end
    if love.mouse.isDown(1) or love.mouse.isDown(2) then
        local px, py, pw, ph = panelRect()
        if not pointIn(x, y, px, py, pw, ph) then
            EditorMap.worldDrag(x, y)
    if not State.editorFocus then return false end
    local sp = selected()
    if not sp then return false end
    local field = State.editorFocus
    if field == "name" and #(sp.name or "") < 24 then
        if t:match("[%w _%-]") then
            sp.name = (sp.name or "") .. t
        end
    end
    return false
end

function M.mousereleased(x, y, button)
    if not State.editorOpen then return false end
    if State.editorTab ~= "map" then return false end
    EditorMap.worldRelease()
    return false
end

function M.wheelmoved(dx, dy)
    if not State.editorOpen then return false end
    if State.editorTab == "map" then EditorMap.wheelmoved(dx, dy); return true end
    return false
end

function M.textinput(t)
    if not State.editorOpen then return false end
    if State.editorTab == "spells" then return EditorSpells.textinput(t) end
    return false
end

function M.keypressed(key)
    if not State.editorOpen then return false end
    if State.editorTab == "spells" then
        return EditorSpells.keypressed(key)
    end
    if State.editorTab == "map" then
        if key == "escape" then
            State.editorOpen = false
    if State.editorFocus then
        local sp = selected()
        if sp and key == "backspace" then
            if State.editorFocus == "name" then
                sp.name = (sp.name or ""):sub(1, -2)
            end
            return true
        elseif key == "return" or key == "kpenter" or key == "escape" then
            loseFocus()
            return true
        end
        if EditorMap.keypressed(key) then return true end
    end
    return false
end

return M
