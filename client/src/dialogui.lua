-- Phase 4 — NPC dialog modal.
--
-- Server pushes DIALOG <npc> <node> <text>, then a sequence of
-- DIALOG_OPT <idx> <text>. The player picks an option by clicking it
-- (or pressing 1..9). DIALOG_END closes the modal. The client never
-- decides the dialog graph — it only renders what the server sent.

local State   = require("src.state")
local Network = require("src.network")

local M = {}

local PANEL_W = 520
local PANEL_H = 280

local function panelRect()
    local sw, sh = love.graphics.getDimensions()
    local x = math.floor((sw - PANEL_W) / 2)
    local y = math.floor(sh * 0.62 - PANEL_H / 2)
    return x, y, PANEL_W, PANEL_H
end

local function rectContains(rx, ry, rw, rh, mx, my)
    return mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh
end

function M.draw()
    local d = State.dialog
    if not d then return end
    local x, y, w, h = panelRect()

    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())

    love.graphics.setColor(0.05, 0.06, 0.10, 0.97)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(1, 0.95, 0.55, 0.6)
    love.graphics.rectangle("line", x, y, w, h, 6, 6)

    local def = State.npcDefs[d.npc] or {}
    love.graphics.setFont(State.fonts.title)
    love.graphics.setColor(1, 0.95, 0.55)
    love.graphics.printf(def.name or d.npc, x + 12, y + 8, w - 24, "left")

    if def.title and def.title ~= "" then
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf(def.title, x + 12, y + 40, w - 24, "left")
    end

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(d.text, x + 12, y + 70, w - 24, "left")

    local optY = y + 150
    for i, opt in ipairs(d.options or {}) do
        local oy = optY + (i - 1) * 26
        love.graphics.setColor(0.16, 0.16, 0.22, 0.9)
        love.graphics.rectangle("fill", x + 12, oy, w - 24, 22, 4, 4)
        love.graphics.setColor(0.95, 0.95, 1.0)
        love.graphics.print(string.format("%d) %s", opt.idx, opt.text), x + 22, oy + 3)
    end

    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(1, 1, 1, 0.55)
    love.graphics.printf("Esc to leave   1-9 to pick", x, y + h - 20, w, "center")
end

function M.isOpen() return State.dialog ~= nil end

function M.keypressed(key)
    if not State.dialog then return false end
    if key == "escape" then
        Network.send("DIALOG_END")
        State.dialog = nil
        return true
    end
    local n = tonumber(key)
    if n and n >= 1 and n <= 9 then
        Network.send("DIALOG_PICK " .. n)
        return true
    end
    return true
end

function M.mousepressed(mx, my, button)
    if not State.dialog then return false end
    if button ~= 1 then return true end
    local x, y = panelRect()
    local optY = y + 150
    for i, opt in ipairs(State.dialog.options or {}) do
        local oy = optY + (i - 1) * 26
        if rectContains(x + 12, oy, PANEL_W - 24, 22, mx, my) then
            Network.send("DIALOG_PICK " .. opt.idx)
            return true
        end
    end
    return true
end

return M
