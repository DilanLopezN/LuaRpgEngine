-- Tooltip overlay. Each frame, UI code calls Tooltip.hover(text) while the
-- mouse is over a hoverable element. The module remembers what was hovered
-- last frame; if the same element stays hovered for more than DELAY seconds
-- the tooltip is rendered above everything else (call Tooltip.draw() last).

local State = require("src.state")

local M = {}

local DELAY  = 0.55
local MAX_W  = 320

local pending = nil
local target  = nil
local since   = 0

function M.hover(text)
    if text and text ~= "" then
        pending = text
    end
end

local function tick()
    local now = love.timer.getTime()
    if pending ~= target then
        target = pending
        since  = now
    end
    pending = nil
end

function M.draw()
    tick()
    if not target then return end
    local now = love.timer.getTime()
    if now - since < DELAY then return end

    love.graphics.setFont(State.fonts.name)
    local font = State.fonts.name
    local _, lines = font:getWrap(target, MAX_W)
    local lineH = font:getHeight()
    local pad = 6

    local boxW = 0
    for _, line in ipairs(lines) do
        boxW = math.max(boxW, font:getWidth(line))
    end
    boxW = boxW + pad * 2
    local boxH = #lines * lineH + pad * 2

    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local x = mx + 16
    local y = my + 18
    local sw, sh = love.graphics.getDimensions()
    if x + boxW > sw - 4 then x = sw - boxW - 4 end
    if x < 4 then x = 4 end
    if y + boxH > sh - 4 then y = my - boxH - 8 end
    if y < 4 then y = 4 end

    love.graphics.setColor(0, 0, 0, 0.92)
    love.graphics.rectangle("fill", x, y, boxW, boxH, 4, 4)
    love.graphics.setColor(0.45, 0.65, 0.95)
    love.graphics.rectangle("line", x, y, boxW, boxH, 4, 4)
    love.graphics.setColor(1, 1, 1)
    for i, line in ipairs(lines) do
        love.graphics.print(line, x + pad, y + pad + (i - 1) * lineH)
    end
end

return M
