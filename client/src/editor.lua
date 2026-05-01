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
            return true
        end
        tx = tx + tw + 8
    end
    return false
end

function M.mousepressed(x, y, button)
    if not State.editorOpen then return false end
    if State.scene ~= State.SCENE_PLAYING then return false end
    button = button or 1

    local px, py, pw, ph = panelRect()

    if pointIn(x, y, px + pw - 36, py + 14, 22, 22) then
        State.editorOpen = false
        State.editorFocus = nil
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
            return true
        end
        if EditorMap.keypressed(key) then return true end
    end
    return false
end

return M
