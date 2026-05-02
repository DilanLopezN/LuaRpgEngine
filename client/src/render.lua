local State    = require("src.state")
local World    = require("src.world")
local Sprites  = require("src.sprites")
local Map      = require("src.map")
local Tilesets = require("src.tilesets")
local FX       = require("src.fx")

local M = {}

local TILE_W = World.TILE_W
local TILE_H = World.TILE_H

local PLAYER_SCALE = 1
local ORC_SCALE    = 1.6

local function drawCheckerFallback(w, h)
    for ty = 0, h - 1 do
        for tx = 0, w - 1 do
            if (tx + ty) % 2 == 0 then
                love.graphics.setColor(0.93, 0.85, 0.66)
            else
                love.graphics.setColor(0.42, 0.26, 0.15)
            end
            World.fillTile(tx, ty)
        end
    end
end

local function drawTileLayer(layer, mapW, mapH)
    if not layer then return end
    for y = 1, mapH do
        local row = layer[y]
        if row then
            for x = 1, mapW do
                local id = row[x]
                if id and id ~= 0 then
                    local ts, quad = Tilesets.resolve(id)
                    if ts and quad then
                        local sx, sy = (x - 1) * TILE_W, (y - 1) * TILE_H
                        local sxScale = TILE_W / ts.tileW
                        local syScale = TILE_H / ts.tileH
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.draw(ts.image, quad, sx, sy,
                            0, sxScale, syScale)
                    end
                end
            end
        end
    end
end

local function drawFloor()
    local m = Map.current
    local mapW = (m and m.width)  or State.mapWidth  or State.mapSize
    local mapH = (m and m.height) or State.mapHeight or State.mapSize
    local boardW = mapW * TILE_W
    local boardH = mapH * TILE_H

    love.graphics.setColor(0.18, 0.10, 0.05)
    love.graphics.rectangle("fill", -12, -12, boardW + 24, boardH + 24)

    if m then
        drawCheckerFallback(mapW, mapH)
        drawTileLayer(m.layers.ground, mapW, mapH)
        drawTileLayer(m.layers.decoration, mapW, mapH)
    else
        drawCheckerFallback(mapW, mapH)
    end

    if State.editorOpen and State.editorTab == "map" and State.mapEditor then
        if State.mapEditor.showGrid then
            love.graphics.setColor(0, 0, 0, 0.35)
            love.graphics.setLineWidth(1)
            for i = 0, mapW do
                love.graphics.line(i * TILE_W, 0, i * TILE_W, boardH)
            end
            for i = 0, mapH do
                love.graphics.line(0, i * TILE_H, boardW, i * TILE_H)
            end
        end
        if State.mapEditor.layer == "collision" and m then
            love.graphics.setColor(0.95, 0.20, 0.20, 0.35)
            for y = 1, mapH do
                local row = m.layers.collision[y]
                if row then
                    for x = 1, mapW do
                        if (row[x] or 0) ~= 0 then
                            love.graphics.rectangle("fill",
                                (x - 1) * TILE_W, (y - 1) * TILE_H,
                                TILE_W, TILE_H)
                        end
                    end
                end
            end
        elseif State.mapEditor.layer == "logic" and m then
            love.graphics.setColor(0.30, 0.65, 1.00, 0.30)
            for y = 1, mapH do
                local row = m.layers.logic[y]
                if row then
                    for x = 1, mapW do
                        if (row[x] or 0) ~= 0 then
                            love.graphics.rectangle("fill",
                                (x - 1) * TILE_W, (y - 1) * TILE_H,
                                TILE_W, TILE_H)
                        end
                    end
                end
            end
        end
        if m and m.entities then
            love.graphics.setFont(State.fonts.name)
            for _, e in ipairs(m.entities) do
                local ex = e.x * TILE_W + TILE_W * 0.5
                local ey = e.y * TILE_H + TILE_H * 0.5
                love.graphics.setColor(0.20, 0.85, 0.30, 0.85)
                love.graphics.circle("line", ex, ey, math.min(TILE_W, TILE_H) * 0.35)
                love.graphics.setColor(1, 1, 1, 0.95)
                local label = (e.type or "?") .. ":" .. (e.kind or "")
                love.graphics.print(label, ex - TILE_W * 0.35, ey - TILE_H * 0.5)
            end
        end
        if State.mapEditor.selection then
            local s = State.mapEditor.selection
            local x1, y1 = math.min(s.x1, s.x2), math.min(s.y1, s.y2)
            local x2, y2 = math.max(s.x1, s.x2), math.max(s.y1, s.y2)
            love.graphics.setColor(1, 1, 0.4, 0.25)
            love.graphics.rectangle("fill",
                (x1 - 1) * TILE_W, (y1 - 1) * TILE_H,
                (x2 - x1 + 1) * TILE_W, (y2 - y1 + 1) * TILE_H)
            love.graphics.setColor(1, 1, 0.4, 0.9)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line",
                (x1 - 1) * TILE_W, (y1 - 1) * TILE_H,
                (x2 - x1 + 1) * TILE_W, (y2 - y1 + 1) * TILE_H)
            love.graphics.setLineWidth(1)
        end
    end

    -- NPC tab: highlight every authored NPC entity on the map so the user
    -- can spot what's already placed before laying down more. We don't
    -- pre-render the sprite here because the server-spawned NPC entity
    -- already does that; the marker just calls out the *authoring* row.
    if State.editorOpen and State.editorTab == "npcs"
            and m and m.entities then
        love.graphics.setFont(State.fonts.name)
        for _, e in ipairs(m.entities) do
            if e.type == "npc" then
                local ex = e.x * TILE_W + TILE_W * 0.5
                local ey = e.y * TILE_H + TILE_H * 0.5
                love.graphics.setColor(0.45, 0.78, 1.0, 0.85)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line",
                    e.x * TILE_W, e.y * TILE_H, TILE_W, TILE_H, 2, 2)
                love.graphics.setLineWidth(1)
                love.graphics.setColor(0, 0, 0, 0.55)
                local label = e.kind or "npc"
                local lblW = State.fonts.name:getWidth(label)
                love.graphics.rectangle("fill",
                    ex - lblW / 2 - 3, ey - TILE_H * 0.7,
                    lblW + 6, 14, 4, 4)
                love.graphics.setColor(0.95, 0.97, 1.0)
                love.graphics.print(label,
                    ex - lblW / 2, ey - TILE_H * 0.7 + 1)
            end
        end
    end

    love.graphics.setColor(0.08, 0.04, 0.02)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", 0, 0, boardW, boardH)
    love.graphics.setLineWidth(1)
end

local function drawShadow(sx, sy, radius)
    radius = radius or 16
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.ellipse("fill", sx, sy + 4, radius, radius * 0.4)
end

local function drawSword(sx, sy, fx, fy, progress)
    if fx == 0 and fy == 0 then fy = 1 end
    local baseAngle = math.atan2(fy, fx)
    local sweep = math.rad(110)
    local angle = baseAngle - sweep / 2 + sweep * progress
    local len = 28
    local pivotY = sy - 24
    local hx = sx + math.cos(angle) * 8
    local hy = pivotY + math.sin(angle) * 8
    local tx = sx + math.cos(angle) * len
    local ty = pivotY + math.sin(angle) * len

    love.graphics.setColor(0.85, 0.85, 0.95)
    love.graphics.setLineWidth(4)
    love.graphics.line(hx, hy, tx, ty)
    love.graphics.setColor(0.55, 0.32, 0.18)
    love.graphics.setLineWidth(5)
    love.graphics.line(sx, pivotY, hx, hy)

    love.graphics.setColor(1, 1, 1, 0.45)
    love.graphics.setLineWidth(2)
    love.graphics.arc("line", "open", sx, pivotY, len,
        baseAngle - sweep / 2, angle)
    love.graphics.setLineWidth(1)
end

local function drawNameTag(name, sx, topY, isMe)
    love.graphics.setFont(State.fonts.name)
    local w = State.fonts.name:getWidth(name)
    local h = State.fonts.name:getHeight()
    local pad = 4
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", sx - w / 2 - pad, topY - h - pad,
        w + pad * 2, h + pad * 2, 4, 4)
    if isMe then
        love.graphics.setColor(1.0, 0.95, 0.55)
    else
        love.graphics.setColor(0.85, 0.92, 1.0)
    end
    love.graphics.print(name, sx - w / 2, topY - h - pad + 1)
end

local function drawHpBar(sx, topY, hp, maxHp, w)
    w = w or 30
    local h = 4
    local x = sx - w / 2
    local y = topY - 2
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x - 1, y - 1, w + 2, h + 2)
    love.graphics.setColor(0.25, 0.25, 0.25)
    love.graphics.rectangle("fill", x, y, w, h)
    local frac = math.max(0, math.min(1, hp / maxHp))
    love.graphics.setColor(0.85, 0.20, 0.20)
    love.graphics.rectangle("fill", x, y, w * frac, h)
end

local function pickPlayerAnim(p)
    local now = love.timer.getTime()
    local moving = p.movingUntil and now < p.movingUntil
    local fx, fy = p.fx or 0, p.fy or 1
    if math.abs(fx) > math.abs(fy) then
        return moving and "player_run_side" or "player_idle_side", fx < 0
    elseif fy < 0 then
        return moving and "player_run_up" or "player_idle_up", false
    end
    return moving and "player_run_down" or "player_idle_down", false
end

local function drawPlayerSpriteFallback(sx, sy, isMe, flash)
    local r, g, b
    if isMe then r, g, b = 0.92, 0.30, 0.30
    else        r, g, b = 0.30, 0.50, 0.95 end
    r = r + (1 - r) * flash
    g = g + (0.15 - g) * flash
    b = b + (0.15 - b) * flash
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", sx - 9, sy - 30, 18, 26)
    love.graphics.setColor(0.96, 0.85, 0.72)
    love.graphics.circle("fill", sx, sy - 36, 7)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("line", sx - 9, sy - 30, 18, 26)
    love.graphics.circle("line", sx, sy - 36, 7)
end

local function drawPlayer(id, p)
    local sx, sy = p.x * TILE_W + TILE_W / 2, p.y * TILE_H + TILE_H / 2
    drawShadow(sx, sy, 16)

    local isMe = id == State.myId
    local since = love.timer.getTime() - (p.hitTime or -1)
    local flash = (since >= 0 and since < 0.18) and (1 - since / 0.18) or 0

    local animName, flip = pickPlayerAnim(p)
    local img, quad, fw, fh = Sprites.frame(animName, love.timer.getTime())

    local headTopY
    if img and quad then
        local tint = isMe and { 1.0, 0.95, 0.92 } or { 0.85, 0.92, 1.0 }
        local r = tint[1] + (1 - tint[1]) * flash
        local g = tint[2] - tint[2] * flash * 0.7
        local b = tint[3] - tint[3] * flash * 0.7
        love.graphics.setColor(r, g, b)
        local sxScale = (flip and -1 or 1) * PLAYER_SCALE
        love.graphics.draw(img, quad, sx, sy + 4,
            0, sxScale, PLAYER_SCALE, fw / 2, fh - 4)
        headTopY = sy + 4 - fh * PLAYER_SCALE + fh * 0.15 * PLAYER_SCALE
    else
        drawPlayerSpriteFallback(sx, sy, isMe, flash)
        headTopY = sy - 36 - 7
    end

    local atkTime = p.atkTime or -1
    local elapsed = love.timer.getTime() - atkTime
    local DURATION = 0.35
    if elapsed >= 0 and elapsed <= DURATION then
        drawSword(sx, sy, p.fx or 0, p.fy or 1, elapsed / DURATION)
    end

    drawHpBar(sx, headTopY - 6, p.hp or 0, p.maxHp or 100, 36)
    drawNameTag(p.name or ("?" .. id), sx, headTopY - 12, isMe)
end

local function drawEnemy(id, e)
    local sx, sy = e.x * TILE_W + TILE_W / 2, e.y * TILE_H + TILE_H / 2
    drawShadow(sx, sy, 14)

    local since = love.timer.getTime() - (e.hitTime or -1)
    local flash = (since >= 0 and since < 0.18) and (1 - since / 0.18) or 0

    local img, quad, fw, fh = Sprites.frame("orc_idle", love.timer.getTime())
    local headTopY
    if img and quad then
        local r = 1
        local g = 1 - flash * 0.7
        local b = 1 - flash * 0.7
        love.graphics.setColor(r, g, b)
        love.graphics.draw(img, quad, sx, sy + 4,
            0, ORC_SCALE, ORC_SCALE, fw / 2, fh - 4)
        headTopY = sy + 4 - fh * ORC_SCALE + fh * 0.18 * ORC_SCALE
    else
        local r, g, b = 0.45, 0.65, 0.30
        r = r + (1 - r) * flash
        g = g + (0.2 - g) * flash
        b = b + (0.2 - b) * flash
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", sx - 11, sy - 28, 22, 24)
        love.graphics.setColor(0.55, 0.45, 0.25)
        love.graphics.circle("fill", sx, sy - 34, 8)
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("line", sx - 11, sy - 28, 22, 24)
        love.graphics.circle("line", sx, sy - 34, 8)
        headTopY = sy - 34 - 8
    end

    drawHpBar(sx, headTopY - 6, e.hp or 0, e.maxHp or 1, 32)

    love.graphics.setFont(State.fonts.name)
    local label = e.kind or "enemy"
    local w = State.fonts.name:getWidth(label)
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", sx - w / 2 - 3, headTopY - 24, w + 6, 16, 4, 4)
    love.graphics.setColor(0.95, 0.75, 0.75)
    love.graphics.print(label, sx - w / 2, headTopY - 23)
end

local function drawSpellEffect(eff)
    local now = love.timer.getTime()
    local t = (now - eff.start) / eff.duration
    if t < 0 then t = 0 end
    if t > 1 then t = 1 end

    local r, g, b = eff.color[1], eff.color[2], eff.color[3]

    if eff.kind == "line" then
        local fx, fy = eff.fx, eff.fy
        if fx == 0 and fy == 0 then fy = 1 end
        local headTile = t * eff.range
        local cx = (eff.ox + 0.5 + fx * headTile) * TILE_W
        local cy = (eff.oy + 0.5 + fy * headTile) * TILE_H
        local size = TILE_H * 0.85
        local trailSteps = 4
        for i = 0, trailSteps - 1 do
            local back = i / trailSteps
            local tx = (eff.ox + 0.5 + fx * (headTile - back * 0.9)) * TILE_W
            local ty = (eff.oy + 0.5 + fy * (headTile - back * 0.9)) * TILE_H
            local alpha = (1 - back) * (1 - t * 0.4)
            love.graphics.setColor(r, g, b, alpha)
            love.graphics.rectangle("fill", tx - size / 2, ty - size / 2, size, size)
        end
        love.graphics.setColor(1, 1, 1, 0.85 * (1 - t))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", cx - size / 2, cy - size / 2, size, size)
        love.graphics.setLineWidth(1)
    elseif eff.kind == "area" then
        local cxTile = eff.ox + eff.fx
        local cyTile = eff.oy + eff.fy
        local diameter = (eff.radius * 2 + 1)
        local grow = t
        local w = diameter * TILE_W * grow
        local h = diameter * TILE_H * grow
        local cx = (cxTile + 0.5) * TILE_W
        local cy = (cyTile + 0.5) * TILE_H
        local alpha = 0.55 * (1 - t)
        love.graphics.setColor(r, g, b, alpha + 0.2)
        love.graphics.rectangle("fill", cx - w / 2, cy - h / 2, w, h)
        love.graphics.setColor(1, 1, 1, 0.9 * (1 - t))
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", cx - w / 2, cy - h / 2, w, h)
        love.graphics.setLineWidth(1)
    elseif eff.kind == "self" then
        local cx = (eff.ox + 0.5) * TILE_W
        local cy = (eff.oy + 0.5) * TILE_H
        local maxR = TILE_W * 0.85
        local rr = maxR * t
        love.graphics.setColor(r, g, b, 0.45 * (1 - t))
        love.graphics.circle("fill", cx, cy - 14, rr)
        love.graphics.setColor(1, 1, 1, 0.7 * (1 - t))
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", cx, cy - 14, rr)
        love.graphics.setLineWidth(1)
    end
end

local NPC_SPRITE_SCALE = 1.6

local function drawNPC(id, n)
    local sx, sy = n.x * TILE_W + TILE_W / 2, n.y * TILE_H + TILE_H / 2
    drawShadow(sx, sy, 14)

    -- Subtle glow halo so NPCs read as "interactable" at a glance.
    love.graphics.setColor(1.0, 0.85, 0.30, 0.20)
    love.graphics.circle("fill", sx, sy - 16, 22)

    -- Try the chosen sprite first; fall back to the placeholder figure if
    -- the artwork is missing or none was configured.
    local sprite = n.sprite and Sprites.npcSprite(n.sprite) or nil
    local headTopY
    if sprite then
        local img, quad, fw, fh = Sprites.frame(sprite.animName,
            love.timer.getTime())
        if img then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(img, quad, sx, sy + 4,
                0, NPC_SPRITE_SCALE, NPC_SPRITE_SCALE,
                fw / 2, fh - 4)
            headTopY = sy + 4 - fh * NPC_SPRITE_SCALE + fh * 0.18 * NPC_SPRITE_SCALE
        end
    end
    if not headTopY then
        love.graphics.setColor(0.95, 0.85, 0.55)
        love.graphics.rectangle("fill", sx - 8, sy - 28, 16, 24)
        love.graphics.setColor(0.96, 0.85, 0.72)
        love.graphics.circle("fill", sx, sy - 32, 7)
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("line", sx - 8, sy - 28, 16, 24)
        love.graphics.circle("line", sx, sy - 32, 7)
        headTopY = sy - 32 - 7
    end

    love.graphics.setFont(State.fonts.name)
    local def  = State.npcDefs[n.name] or {}
    local label = def.name or n.name or "?"
    local title = def.title or ""
    local lblW = State.fonts.name:getWidth(label)
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", sx - lblW / 2 - 3, headTopY - 18,
        lblW + 6, 16, 4, 4)
    love.graphics.setColor(1.0, 0.95, 0.55)
    love.graphics.print(label, sx - lblW / 2, headTopY - 17)
    if title ~= "" then
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.printf(title, sx - 80, headTopY - 32, 160, "center")
    end
end

function M.drawWorld()
    drawFloor()

    local list = {}
    for id, p in pairs(State.players) do
        if p.x and p.y then
            list[#list + 1] = { kind = "p", id = id, ent = p, depth = p.y }
        end
    end
    for id, e in pairs(State.enemies) do
        if e.x and e.y then
            list[#list + 1] = { kind = "e", id = id, ent = e, depth = e.y }
        end
    end
    for id, n in pairs(State.npcs or {}) do
        if n.x and n.y then
            list[#list + 1] = { kind = "n", id = id, ent = n, depth = n.y }
        end
    end
    table.sort(list, function(a, b) return a.depth < b.depth end)
    for _, item in ipairs(list) do
        if item.kind == "p" then
            drawPlayer(item.id, item.ent)
        elseif item.kind == "e" then
            drawEnemy(item.id, item.ent)
        else
            drawNPC(item.id, item.ent)
        end
    end

    for _, eff in ipairs(State.activeSpells) do
        drawSpellEffect(eff)
    end

    -- Floating combat text por cima de tudo no mundo, abaixo da HUD.
    FX.draw(TILE_W, TILE_H)
end

return M
