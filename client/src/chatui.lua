-- Phase 4 — chat overlay.
--
-- T opens an input box at the bottom-left. Enter sends, Escape cancels.
-- Without a leading slash the message is broadcast as a SAY (radius
-- around the player). Recognised slashes:
--
--   /shout msg
--   /yell  msg          (alias for /shout)
--   /w name msg         (whisper)
--   /tell name msg      (alias)
--
-- Messages from the server (CHAT SAY/SHOUT/WHISPER, SYS) appear above
-- the input box and fade after a few seconds.

local State   = require("src.state")
local Network = require("src.network")

local M = {}

local CHAT_LIFETIME = 12

local function colorFor(kind)
    if kind == "SHOUT"   then return { 1.0,  0.55, 0.30 } end
    if kind == "WHISPER" then return { 0.85, 0.55, 1.00 } end
    if kind == "SYS"     then return { 1.0,  0.85, 0.20 } end
    return { 0.85, 0.95, 1.00 }
end

function M.draw()
    local font = State.fonts.ui
    love.graphics.setFont(font)

    local now = love.timer.getTime()
    local sw, sh = love.graphics.getDimensions()
    local x = 14
    local y = sh - 200
    local visible = {}
    for _, entry in ipairs(State.chat.history) do
        local age = now - (entry.t or now)
        if State.chat.open or age < CHAT_LIFETIME then
            visible[#visible + 1] = { entry = entry, age = age }
        end
    end
    -- Render last 8 entries (or all when chat is open).
    local startIdx = math.max(1, #visible - (State.chat.open and 14 or 8) + 1)
    local row = 0
    for i = startIdx, #visible do
        local v = visible[i]
        local entry = v.entry
        local fade = State.chat.open and 1.0
            or math.max(0, 1 - v.age / CHAT_LIFETIME)
        local col = colorFor(entry.kind)
        love.graphics.setColor(0, 0, 0, 0.45 * fade)
        local text
        if entry.kind == "SAY" then
            text = string.format("%s: %s", entry.who, entry.msg)
        elseif entry.kind == "SHOUT" then
            text = string.format("%s [shout]: %s", entry.who, entry.msg)
        elseif entry.kind == "WHISPER" then
            text = string.format("%s [w]: %s", entry.who, entry.msg)
        else
            text = string.format("[%s] %s", entry.kind, entry.msg)
        end
        local tw = font:getWidth(text) + 12
        love.graphics.rectangle("fill", x, y + row * 18, tw, 17, 3, 3)
        love.graphics.setColor(col[1], col[2], col[3], fade)
        love.graphics.print(text, x + 6, y + row * 18)
        row = row + 1
    end

    if State.chat.open then
        local boxY = sh - 36
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", x, boxY, sw - 28, 26, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("> " .. State.chat.input .. "_", x + 6, boxY + 4)
    end
end

local function dispatch(line)
    line = (line or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if line == "" then return end
    if line:sub(1, 1) ~= "/" then
        Network.send("SAY " .. line)
        return
    end
    local cmd, rest = line:match("^/(%S+)%s*(.*)$")
    cmd = (cmd or ""):lower()
    if cmd == "shout" or cmd == "yell" then
        if rest ~= "" then Network.send("SHOUT " .. rest) end
    elseif cmd == "w" or cmd == "tell" or cmd == "whisper" then
        local target, msg = rest:match("^(%S+)%s+(.+)$")
        if target and msg then
            Network.send("WHISPER " .. target .. " " .. msg)
        end
    elseif cmd == "say" then
        if rest ~= "" then Network.send("SAY " .. rest) end
    elseif cmd == "reload" then
        Network.send("RELOAD " .. (rest ~= "" and rest or "all"))
    elseif cmd == "help" then
        local entry = {
            kind = "SYS", who = "client",
            msg = "/say /shout /w <name> /reload [domain]",
            t = love.timer.getTime(),
        }
        State.chat.history[#State.chat.history + 1] = entry
    end
end

function M.open() State.chat.open = true; State.chat.input = "" end
function M.close() State.chat.open = false; State.chat.input = "" end
function M.isOpen() return State.chat.open end

function M.keypressed(key)
    if not State.chat.open then return false end
    if key == "return" or key == "kpenter" then
        dispatch(State.chat.input)
        M.close()
        return true
    elseif key == "escape" then
        M.close()
        return true
    elseif key == "backspace" then
        State.chat.input = State.chat.input:sub(1, -2)
        return true
    end
    return true
end

function M.textinput(t)
    if not State.chat.open then return false end
    if #State.chat.input >= 200 then return true end
    if t:match("[%g ]") then
        State.chat.input = State.chat.input .. t
    end
    return true
end

return M
