local Network = require("src.network")
local World = require("src.world")

local TILE_W, TILE_H = World.TILE_W, World.TILE_H

local SCENE_NAME       = "name"
local SCENE_CONNECTING = "connecting"
local SCENE_PLAYING    = "playing"

local state = {
    scene = SCENE_NAME,
    nameInput = "",
    status = "Enter your name",
    serverHost = "127.0.0.1",
    serverPort = 7777,
    mapSize = 8,
    myId = nil,
    myName = nil,
    players = {},
    enemies = {},
    camera = { x = 0, y = 0 },
    lastSent = { dx = 0, dy = 0 },
}

local fonts = {}

local function ensureFonts()
    if fonts.ui then return end
    fonts.ui    = love.graphics.newFont(14)
    fonts.name  = love.graphics.newFont(13)
    fonts.title = love.graphics.newFont(28)
end

local function handleSnapshot(line)
    local kind, rest = line:match("^(%S+)%s*(.*)$")
    if kind == "P" then
        local id, x, y, fx, fy, hp, atk, name = rest:match(
            "^(%-?%d+)%s+(%-?[%d%.]+)%s+(%-?[%d%.]+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(.+)$")
        if id then
            id = tonumber(id)
            local p = state.players[id]
            if not p then
                p = { atkTime = -1 }
                state.players[id] = p
            end
            p.x, p.y = tonumber(x), tonumber(y)
            p.fx, p.fy = tonumber(fx), tonumber(fy)
            p.hp = tonumber(hp)
            p.atk = tonumber(atk) == 1
            p.name = name
        end
    elseif kind == "E" then
        local id, ekind, x, y, hp, maxHp = rest:match(
            "^(%-?%d+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        if id then
            id = tonumber(id)
            local e = state.enemies[id]
            if not e then
                e = { hitTime = -1 }
                state.enemies[id] = e
            end
            e.kind = ekind
            e.x, e.y = tonumber(x), tonumber(y)
            e.hp, e.maxHp = tonumber(hp), tonumber(maxHp)
        end
    end
end

local function handleEvent(line)
    local cmd, rest = line:match("^(%S+)%s*(.*)$")
    if cmd == "WELCOME" then
        local id, mapSize, name = rest:match("^(%-?%d+)%s+(%-?%d+)%s+(.+)$")
        state.myId = tonumber(id)
        state.mapSize = tonumber(mapSize) or state.mapSize
        state.myName = name
        state.scene = SCENE_PLAYING
        state.status = "connected"
    elseif cmd == "LEAVE" then
        local id = tonumber(rest)
        if id then state.players[id] = nil end
    elseif cmd == "ATK" then
        local id, fx, fy = rest:match("^(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        id = tonumber(id)
        local p = state.players[id]
        if p then
            p.atkTime = love.timer.getTime()
            p.fx, p.fy = tonumber(fx), tonumber(fy)
        end
    elseif cmd == "HIT" then
        local id = tonumber(rest)
        local e = state.enemies[id]
        if e then e.hitTime = love.timer.getTime() end
    elseif cmd == "PHIT" then
        local id = tonumber(rest)
        local p = state.players[id]
        if p then p.hitTime = love.timer.getTime() end
    elseif cmd == "PDIE" then
        local id = tonumber(rest)
        local p = state.players[id]
        if p then p.dieTime = love.timer.getTime() end
    elseif cmd == "EDIE" then
        local id = tonumber(rest)
        if id then state.enemies[id] = nil end
    elseif cmd == "P" or cmd == "E" then
        handleSnapshot(line)
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    ensureFonts()
end

local function tryConnect()
    local ok, err = Network.connect(state.serverHost, state.serverPort)
    if not ok then
        state.scene = SCENE_NAME
        state.status = "offline: " .. tostring(err)
        return false
    end
    Network.send("NAME " .. state.nameInput)
    state.scene = SCENE_CONNECTING
    state.status = "connecting..."
    return true
end

local function readInput()
    local dx, dy = 0, 0
    if love.keyboard.isDown("w", "up")    then dy = dy - 1 end
    if love.keyboard.isDown("s", "down")  then dy = dy + 1 end
    if love.keyboard.isDown("a", "left")  then dx = dx - 1 end
    if love.keyboard.isDown("d", "right") then dx = dx + 1 end
    if dx < -1 then dx = -1 elseif dx > 1 then dx = 1 end
    if dy < -1 then dy = -1 elseif dy > 1 then dy = 1 end
    return dx, dy
end

function love.textinput(t)
    if state.scene == SCENE_NAME and #state.nameInput < 24 then
        if t:match("[%w _%-]") then
            state.nameInput = state.nameInput .. t
        end
    end
end

function love.keypressed(key)
    if state.scene == SCENE_NAME then
        if key == "backspace" then
            state.nameInput = state.nameInput:sub(1, -2)
        elseif key == "return" or key == "kpenter" then
            if #state.nameInput:gsub("%s", "") > 0 then
                tryConnect()
            else
                state.status = "Type a name first"
            end
        elseif key == "escape" then
            love.event.quit()
        end
        return
    end

    if state.scene == SCENE_PLAYING then
        if key == "space" or key == "j" then
            Network.send("ATTACK")
        elseif key == "escape" then
            love.event.quit()
        end
    end
end

function love.update(dt)
    Network.poll(handleEvent)

    if state.scene == SCENE_PLAYING then
        local dx, dy = readInput()
        if dx ~= state.lastSent.dx or dy ~= state.lastSent.dy then
            Network.send(string.format("MOVE %d %d", dx, dy))
            state.lastSent.dx, state.lastSent.dy = dx, dy
        end

        local me = state.players[state.myId]
        if me and me.x then
            local sx, sy = me.x * TILE_W + TILE_W / 2, me.y * TILE_H + TILE_H / 2
            state.camera.x = sx - love.graphics.getWidth()  / 2
            state.camera.y = sy - love.graphics.getHeight() / 2
        end
    end
end

local function drawFloor()
    local size = state.mapSize
    local boardW = size * TILE_W
    local boardH = size * TILE_H

    love.graphics.setColor(0.18, 0.10, 0.05)
    love.graphics.rectangle("fill", -12, -12, boardW + 24, boardH + 24)

    for ty = 0, size - 1 do
        for tx = 0, size - 1 do
            if (tx + ty) % 2 == 0 then
                love.graphics.setColor(0.93, 0.85, 0.66)
            else
                love.graphics.setColor(0.42, 0.26, 0.15)
            end
            World.fillTile(tx, ty)
        end
    end

    love.graphics.setColor(0.10, 0.06, 0.03, 0.85)
    love.graphics.setLineWidth(2)
    for i = 0, size do
        love.graphics.line(i * TILE_W, 0, i * TILE_W, boardH)
        love.graphics.line(0, i * TILE_H, boardW, i * TILE_H)
    end

    love.graphics.setColor(0.08, 0.04, 0.02)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", 0, 0, boardW, boardH)
    love.graphics.setLineWidth(1)
end

local function drawShadow(sx, sy)
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.ellipse("fill", sx, sy + 6, 16, 6)
end

local function drawSword(sx, sy, fx, fy, progress)
    if fx == 0 and fy == 0 then fy = 1 end
    local baseAngle = math.atan2(fy, fx)
    local sweep = math.rad(110)
    local angle = baseAngle - sweep / 2 + sweep * progress
    local len = 28
    local pivotY = sy - 14
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
    love.graphics.setFont(fonts.name)
    local w = fonts.name:getWidth(name)
    local h = fonts.name:getHeight()
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

local function drawPlayer(id, p)
    local sx, sy = p.x * TILE_W + TILE_W / 2, p.y * TILE_H + TILE_H / 2
    drawShadow(sx, sy)

    local r, g, b
    if id == state.myId then
        r, g, b = 0.92, 0.30, 0.30
    else
        r, g, b = 0.30, 0.50, 0.95
    end
    local since = love.timer.getTime() - (p.hitTime or -1)
    if since >= 0 and since < 0.18 then
        local f = 1 - since / 0.18
        r = r + (1 - r) * f
        g = g + (0.15 - g) * f
        b = b + (0.15 - b) * f
    end
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", sx - 9, sy - 30, 18, 26)
    love.graphics.setColor(0.96, 0.85, 0.72)
    love.graphics.circle("fill", sx, sy - 36, 7)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("line", sx - 9, sy - 30, 18, 26)
    love.graphics.circle("line", sx, sy - 36, 7)

    local atkTime = p.atkTime or -1
    local elapsed = love.timer.getTime() - atkTime
    local DURATION = 0.35
    if elapsed >= 0 and elapsed <= DURATION then
        drawSword(sx, sy, p.fx or 0, p.fy or 1, elapsed / DURATION)
    end

    local headTop = sy - 36 - 7
    drawHpBar(sx, headTop - 6, p.hp or 0, 100, 32)
    drawNameTag(p.name or ("?" .. id), sx, headTop - 12, id == state.myId)
end

local function drawEnemy(id, e)
    local sx, sy = e.x * TILE_W + TILE_W / 2, e.y * TILE_H + TILE_H / 2
    drawShadow(sx, sy)

    local flash = 0
    local since = love.timer.getTime() - (e.hitTime or -1)
    if since >= 0 and since < 0.18 then
        flash = 1 - since / 0.18
    end

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

    local headTop = sy - 34 - 8
    drawHpBar(sx, headTop - 6, e.hp or 0, e.maxHp or 1, 32)
    love.graphics.setFont(fonts.name)
    local label = e.kind or "enemy"
    local w = fonts.name:getWidth(label)
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", sx - w / 2 - 3, headTop - 24, w + 6, 16, 4, 4)
    love.graphics.setColor(0.95, 0.75, 0.75)
    love.graphics.print(label, sx - w / 2, headTop - 23)
end

local function drawWorld()
    drawFloor()

    local list = {}
    for id, p in pairs(state.players) do
        if p.x and p.y then
            list[#list + 1] = { kind = "p", id = id, ent = p, depth = p.y }
        end
    end
    for id, e in pairs(state.enemies) do
        if e.x and e.y then
            list[#list + 1] = { kind = "e", id = id, ent = e, depth = e.y }
        end
    end
    table.sort(list, function(a, b) return a.depth < b.depth end)
    for _, item in ipairs(list) do
        if item.kind == "p" then
            drawPlayer(item.id, item.ent)
        else
            drawEnemy(item.id, item.ent)
        end
    end
end

local function drawNameScene()
    local W, H = love.graphics.getDimensions()
    love.graphics.clear(0.07, 0.09, 0.13)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    local title = "LuaRpgEngine"
    love.graphics.print(title, (W - fonts.title:getWidth(title)) / 2, H / 2 - 140)

    love.graphics.setFont(fonts.ui)
    local prompt = "Name your character:"
    love.graphics.print(prompt, (W - fonts.ui:getWidth(prompt)) / 2, H / 2 - 60)

    local boxW, boxH = 360, 44
    local boxX, boxY = (W - boxW) / 2, H / 2 - 24
    love.graphics.setColor(0.15, 0.18, 0.24)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 6, 6)
    love.graphics.setColor(0.5, 0.55, 0.65)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 6, 6)
    love.graphics.setColor(1, 1, 1)
    local text = state.nameInput
    if (math.floor(love.timer.getTime() * 2) % 2) == 0 then
        text = text .. "_"
    end
    love.graphics.print(text, boxX + 10, boxY + (boxH - fonts.ui:getHeight()) / 2)

    love.graphics.setColor(0.7, 0.7, 0.75)
    local hint = "Press Enter to join. WASD/arrows to move, Space to attack."
    love.graphics.print(hint, (W - fonts.ui:getWidth(hint)) / 2, boxY + boxH + 18)

    if state.status and state.status ~= "" then
        love.graphics.setColor(0.9, 0.7, 0.3)
        love.graphics.print(state.status, (W - fonts.ui:getWidth(state.status)) / 2, boxY + boxH + 46)
    end
end

function love.draw()
    ensureFonts()

    if state.scene == SCENE_NAME or state.scene == SCENE_CONNECTING then
        drawNameScene()
        return
    end

    love.graphics.clear(0.08, 0.10, 0.14)
    love.graphics.push()
    love.graphics.translate(-state.camera.x, -state.camera.y)
    drawWorld()
    love.graphics.pop()

    love.graphics.setFont(fonts.ui)
    love.graphics.setColor(1, 1, 1)
    local count = 0
    for _ in pairs(state.players) do count = count + 1 end
    local me = state.players[state.myId]
    local hp = me and me.hp or 0
    love.graphics.print(string.format(
        "FPS: %d | %s | %s | hp=%d | players=%d | WASD move, Space attack",
        love.timer.getFPS(), state.status, tostring(state.myName), hp, count), 10, 10)
end

function love.quit()
    Network.close()
end
