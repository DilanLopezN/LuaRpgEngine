local Network = require("src.network")
local Iso = require("src.iso")

local TILE_W, TILE_H = 64, 32

local state = {
    mapSize = 20,
    myId = nil,
    players = {},
    camera = { x = 0, y = 0 },
    lastSent = { dx = 0, dy = 0 },
    status = "connecting...",
}

local function handleMessage(msg)
    local words = {}
    for w in msg:gmatch("%S+") do words[#words + 1] = w end
    local cmd = words[1]
    if cmd == "WELCOME" then
        state.myId = tonumber(words[2])
        state.mapSize = tonumber(words[3]) or state.mapSize
        state.status = "connected"
    elseif cmd == "P" then
        local id = tonumber(words[2])
        local x = tonumber(words[3])
        local y = tonumber(words[4])
        if id and x and y then
            local p = state.players[id]
            if not p then
                p = { x = x, y = y }
                state.players[id] = p
            else
                p.x, p.y = x, y
            end
        end
    elseif cmd == "LEAVE" then
        local id = tonumber(words[2])
        if id then state.players[id] = nil end
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local ok, err = Network.connect("127.0.0.1", 7777)
    if not ok then
        state.status = "offline: " .. tostring(err)
    end
end

local function readInput()
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then dy = dy - 1 end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then dy = dy + 1 end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then dx = dx - 1 end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then dx = dx + 1 end
    if dx ~= 0 and dy ~= 0 then
        local s = 0.7071067811865475
        dx, dy = dx * s, dy * s
    end
    return dx, dy
end

function love.update(dt)
    Network.poll(handleMessage)

    local dx, dy = readInput()
    if dx ~= state.lastSent.dx or dy ~= state.lastSent.dy then
        Network.send(string.format("MOVE %.3f %.3f", dx, dy))
        state.lastSent.dx, state.lastSent.dy = dx, dy
    end

    local me = state.players[state.myId]
    if me then
        local sx, sy = Iso.toScreen(me.x, me.y, TILE_W, TILE_H)
        state.camera.x = sx - love.graphics.getWidth() / 2
        state.camera.y = sy - love.graphics.getHeight() / 2
    end
end

local function drawFloor()
    for ty = 0, state.mapSize - 1 do
        for tx = 0, state.mapSize - 1 do
            local sx, sy = Iso.toScreen(tx + 0.5, ty + 0.5, TILE_W, TILE_H)
            if (tx + ty) % 2 == 0 then
                love.graphics.setColor(0.32, 0.66, 0.28)
            else
                love.graphics.setColor(0.26, 0.56, 0.22)
            end
            Iso.fillTile(sx, sy, TILE_W, TILE_H)
        end
    end
    love.graphics.setColor(0, 0, 0, 0.18)
    for ty = 0, state.mapSize - 1 do
        for tx = 0, state.mapSize - 1 do
            local sx, sy = Iso.toScreen(tx + 0.5, ty + 0.5, TILE_W, TILE_H)
            Iso.outlineTile(sx, sy, TILE_W, TILE_H)
        end
    end
end

local function drawPlayer(id, p)
    local sx, sy = Iso.toScreen(p.x, p.y, TILE_W, TILE_H)
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.ellipse("fill", sx, sy + 2, 13, 6)
    if id == state.myId then
        love.graphics.setColor(0.90, 0.25, 0.25)
    else
        love.graphics.setColor(0.25, 0.45, 0.95)
    end
    love.graphics.rectangle("fill", sx - 8, sy - 36, 16, 30)
    love.graphics.setColor(0.96, 0.85, 0.72)
    love.graphics.circle("fill", sx, sy - 42, 7)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("line", sx - 8, sy - 36, 16, 30)
    love.graphics.circle("line", sx, sy - 42, 7)
end

local function drawPlayers()
    local list = {}
    for id, p in pairs(state.players) do
        list[#list + 1] = { id = id, p = p }
    end
    table.sort(list, function(a, b)
        return (a.p.x + a.p.y) < (b.p.x + b.p.y)
    end)
    for _, e in ipairs(list) do
        drawPlayer(e.id, e.p)
    end
end

function love.draw()
    love.graphics.clear(0.08, 0.10, 0.14)
    love.graphics.push()
    love.graphics.translate(-state.camera.x, -state.camera.y)
    drawFloor()
    drawPlayers()
    love.graphics.pop()

    local count = 0
    for _ in pairs(state.players) do count = count + 1 end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format(
        "FPS: %d | %s | id=%s | players=%d | WASD/arrows to move",
        love.timer.getFPS(), state.status, tostring(state.myId), count), 10, 10)
end

function love.quit()
    Network.close()
end
