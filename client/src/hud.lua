local State = require("src.state")

local M = {}

local function drawStatBar(x, y, w, h, frac, fillColor, label)
    if frac < 0 then frac = 0 elseif frac > 1 then frac = 1 end
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4, 4, 4)
    love.graphics.setColor(0.18, 0.18, 0.22)
    love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    love.graphics.setColor(fillColor[1], fillColor[2], fillColor[3])
    love.graphics.rectangle("fill", x, y, w * frac, h, 3, 3)
    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.rectangle("line", x, y, w, h, 3, 3)
    if label then
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(label, x + 6, y + (h - State.fonts.name:getHeight()) / 2)
    end
end

function M.draw()
    local me = State.players[State.myId]
    local hp = me and me.hp or 0
    local maxHp = me and me.maxHp or 100
    local mp = me and me.mp or 0
    local maxMp = me and me.maxMp or 100

    local barX, barY, barW = 14, 14, 220
    drawStatBar(barX, barY, barW, 18, hp / math.max(1, maxHp),
        { 0.85, 0.20, 0.20 }, string.format("HP %d / %d", hp, maxHp))
    drawStatBar(barX, barY + 24, barW, 14, mp / math.max(1, maxMp),
        { 0.25, 0.50, 1.00 }, string.format("MP %d / %d", mp, maxMp))

    -- Phase 4 — XP bar showing progress toward the next level.
    local c = State.character
    local xpFrac = (c.nextX > 0) and (c.xp / c.nextX) or 0
    drawStatBar(barX, barY + 42, barW, 10, xpFrac,
        { 0.95, 0.85, 0.30 },
        string.format("Lv %d  XP %d/%d", c.level, c.xp, c.nextX))

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print(
        string.format("FPS %d  Gold %d  SP %d  %s",
            love.timer.getFPS(), c.gold, c.skillPoints, State.status or ""),
        barX, barY + 60)
    love.graphics.setColor(1, 1, 1, 0.55)
    love.graphics.print(
        "WSAD - mover   Space - atacar   T - chat   F1 - editor   F2 - personagem   I - inventário   Q - quests   E - falar com NPC   F11 - fullscreen",
        barX, barY + 80)
end

return M
