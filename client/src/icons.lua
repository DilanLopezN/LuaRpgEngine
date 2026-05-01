local M = {}

local KIND_GLYPHS = {
    line = "→",
    area = "◇",
    self = "◎",
}

local EFFECT_GLYPHS = {
    damage = "DMG",
    heal   = "HEAL",
    mana   = "MP",
}

function M.drawSpell(spell, x, y, w, h, font)
    if not spell then return end
    local c = spell.color or { 0.8, 0.8, 0.8 }
    love.graphics.setColor(c[1] * 0.45, c[2] * 0.45, c[3] * 0.45)
    love.graphics.rectangle("fill", x + 2, y + 2, w - 4, h - 4, 4, 4)
    love.graphics.setColor(c[1], c[2], c[3])
    if spell.kind == "line" then
        love.graphics.rectangle("fill", x + w * 0.18, y + h * 0.42, w * 0.64, h * 0.16)
        love.graphics.polygon("fill",
            x + w * 0.82, y + h * 0.5,
            x + w * 0.7,  y + h * 0.34,
            x + w * 0.7,  y + h * 0.66)
    elseif spell.kind == "area" then
        love.graphics.circle("fill", x + w / 2, y + h / 2, math.min(w, h) * 0.28)
        love.graphics.setColor(c[1], c[2], c[3], 0.4)
        love.graphics.circle("fill", x + w / 2, y + h / 2, math.min(w, h) * 0.42)
    elseif spell.kind == "self" then
        love.graphics.setColor(c[1], c[2], c[3], 0.45)
        love.graphics.circle("fill", x + w / 2, y + h / 2, math.min(w, h) * 0.4)
        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.circle("fill", x + w / 2, y + h / 2, math.min(w, h) * 0.18)
    end
    if font then
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0, 0.85)
        local label = spell.name or spell.id or "?"
        if #label > 9 then label = label:sub(1, 9) end
        love.graphics.print(label, x + 4, y + h - font:getHeight() - 2)
        love.graphics.setColor(1, 1, 1, 0.85)
        local tag = (EFFECT_GLYPHS[spell.effect] or "")
        love.graphics.print(tag, x + 4, y + 2)
    end
end

return M
