-- Phase 4 — toast notifications.
--
-- Lightweight transient feedback for loot, XP, level-ups and quest
-- transitions. Toasts stack in the top-right and slide down as older
-- entries expire.

local State = require("src.state")

local M = {}

function M.update()
    local now = love.timer.getTime()
    local kept = {}
    for _, t in ipairs(State.toasts) do
        if (t.expires or 0) > now then
            kept[#kept + 1] = t
        end
    end
    State.toasts = kept
end

function M.draw()
    if #State.toasts == 0 then return end
    M.update()
    local font = State.fonts.ui
    love.graphics.setFont(font)
    local now = love.timer.getTime()
    local sw = love.graphics.getWidth()
    local x  = sw - 240
    local y  = 14
    for _, t in ipairs(State.toasts) do
        local life = t.expires - now
        local alpha = math.min(1, life / 0.5)
        love.graphics.setColor(0, 0, 0, 0.55 * alpha)
        love.graphics.rectangle("fill", x, y, 220, 26, 4, 4)
        love.graphics.setColor(t.color[1], t.color[2], t.color[3], alpha)
        love.graphics.printf(t.text, x, y + 5, 220, "center")
        y = y + 30
    end
end

return M
