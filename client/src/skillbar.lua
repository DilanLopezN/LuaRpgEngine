local State   = require("src.state")
local Spells  = require("src.spells")
local Network = require("src.network")
local Icons   = require("src.icons")

local M = {}

local SLOT = 56
local GAP  = 8

local function origin()
    local W, H = love.graphics.getDimensions()
    local total = 5 * SLOT + 4 * GAP
    return (W - total) / 2, H - SLOT - 24
end

function M.slotRect(i)
    local ox, oy = origin()
    return ox + (i - 1) * (SLOT + GAP), oy, SLOT, SLOT
end

local function pointInRect(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

function M.hit(mx, my)
    for i = 1, 5 do
        local x, y, w, h = M.slotRect(i)
        if pointInRect(mx, my, x, y, w, h) then return i end
    end
    return nil
end

function M.mousepressed(x, y)
    local slot = M.hit(x, y)
    if slot and State.skillbar[slot] then
        State.drag = {
            spellId  = State.skillbar[slot],
            source   = "slot",
            fromSlot = slot,
        }
        return true
    end
    return false
end

function M.mousereleased(x, y)
    if not State.drag then return end
    local target = M.hit(x, y)
    if target then
        local existing = State.skillbar[target]
        State.skillbar[target] = State.drag.spellId
        if State.drag.source == "slot" and State.drag.fromSlot ~= target then
            State.skillbar[State.drag.fromSlot] = existing
        end
    elseif State.drag.source == "slot" then
        State.skillbar[State.drag.fromSlot] = nil
    end
    State.drag = nil
end

function M.cast(slot)
    local spellId = State.skillbar[slot]
    if not spellId then return end
    if not Spells.byId[spellId] then
        State.skillbar[slot] = nil
        return
    end
    Network.send("CAST " .. spellId)
end

function M.draw()
    love.graphics.setFont(State.fonts.name)
    for i = 1, 5 do
        local x, y, w, h = M.slotRect(i)
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4, 5, 5)
        love.graphics.setColor(0.16, 0.18, 0.22)
        love.graphics.rectangle("fill", x, y, w, h, 4, 4)
        local spellId = State.skillbar[i]
        local hidden = State.drag and State.drag.source == "slot"
            and State.drag.fromSlot == i
        if spellId and not hidden then
            local sp = Spells.byId[spellId]
            if sp then
                Icons.drawSpell(sp, x, y, w, h, State.fonts.name)
            end
        end
        love.graphics.setColor(0.65, 0.7, 0.8)
        love.graphics.rectangle("line", x, y, w, h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tostring(i), x + 4, y + 2)
    end

    if State.drag then
        local mx, my = State.mouse.x, State.mouse.y
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", mx - SLOT / 2, my - SLOT / 2,
            SLOT, SLOT, 4, 4)
        local sp = Spells.byId[State.drag.spellId]
        if sp then
            Icons.drawSpell(sp, mx - SLOT / 2, my - SLOT / 2,
                SLOT, SLOT, State.fonts.name)
        end
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle("line", mx - SLOT / 2, my - SLOT / 2,
            SLOT, SLOT, 4, 4)
    end
end

return M
