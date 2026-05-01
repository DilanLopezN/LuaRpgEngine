local State   = require("src.state")
local Spells  = require("src.spells")

local SPELL_LINE_DURATION = 0.45
local SPELL_AREA_DURATION = 0.55
local SPELL_SELF_DURATION = 0.50

local MOVE_TRAIL = 0.18

local M = {}

local function approxEq(a, b)
    return math.abs((a or 0) - (b or 0)) < 0.001
end

local function handleSnapshot(line)
    local kind, rest = line:match("^(%S+)%s*(.*)$")
    if kind == "P" then
        local id, x, y, fx, fy, hp, maxHp, mp, maxMp, atk, name = rest:match(
            "^(%-?%d+)%s+(%-?[%d%.]+)%s+(%-?[%d%.]+)%s+" ..
            "(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+" ..
            "(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(.+)$")
        if id then
            id = tonumber(id)
            local p = State.players[id]
            if not p then
                p = { atkTime = -1 }
                State.players[id] = p
            end
            local nx, ny = tonumber(x), tonumber(y)
            if p.x and (not approxEq(nx, p.x) or not approxEq(ny, p.y)) then
                p.movingUntil = love.timer.getTime() + MOVE_TRAIL
            end
            p.x, p.y    = nx, ny
            p.fx, p.fy  = tonumber(fx), tonumber(fy)
            p.hp        = tonumber(hp)
            p.maxHp     = tonumber(maxHp)
            p.mp        = tonumber(mp)
            p.maxMp     = tonumber(maxMp)
            p.atk       = tonumber(atk) == 1
            p.name      = name
        end
    elseif kind == "E" then
        local id, ekind, x, y, hp, maxHp = rest:match(
            "^(%-?%d+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        if id then
            id = tonumber(id)
            local e = State.enemies[id]
            if not e then
                e = { hitTime = -1 }
                State.enemies[id] = e
            end
            e.kind     = ekind
            e.x, e.y   = tonumber(x), tonumber(y)
            e.hp       = tonumber(hp)
            e.maxHp    = tonumber(maxHp)
        end
    end
end

local function durationFor(kind)
    if kind == "line" then return SPELL_LINE_DURATION end
    if kind == "area" then return SPELL_AREA_DURATION end
    return SPELL_SELF_DURATION
end

function M.handle(line)
    local cmd, rest = line:match("^(%S+)%s*(.*)$")
    if cmd == "WELCOME" then
        local id, mapSize, name = rest:match("^(%-?%d+)%s+(%-?%d+)%s+(.+)$")
        State.myId    = tonumber(id)
        State.mapSize = tonumber(mapSize) or State.mapSize
        State.myName  = name
        State.scene   = State.SCENE_PLAYING
        State.status  = "connected"
        Spells.clear()
    elseif cmd == "STATS" then
        -- Authoritative HP/MP follows in the next P snapshot; the explicit
        -- STATS line is kept for parity with server-side persistence and lets
        -- us pre-populate the HUD before the first tick lands.
        local hp, maxHp, mp, maxMp = rest:match(
            "^(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        if hp then
            local me = State.players[State.myId] or { atkTime = -1 }
            me.hp, me.maxHp = tonumber(hp), tonumber(maxHp)
            me.mp, me.maxMp = tonumber(mp), tonumber(maxMp)
            State.players[State.myId] = me
        end
    elseif cmd == "SPELL_DEF" then
        local id, kind, effect, rng, rad, power, manaCost, cdMs, sr, sg, sb, name =
            rest:match("^(%S+)%s+(%S+)%s+(%S+)%s+" ..
                       "(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+" ..
                       "(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(.+)$")
        if id then
            Spells.upsertFromServer({
                id       = id,
                name     = name,
                kind     = kind,
                effect   = effect,
                range    = tonumber(rng),
                radius   = tonumber(rad),
                power    = tonumber(power),
                manaCost = tonumber(manaCost),
                cooldown = (tonumber(cdMs) or 0) / 1000,
                color    = {
                    (tonumber(sr) or 0) / 255,
                    (tonumber(sg) or 0) / 255,
                    (tonumber(sb) or 0) / 255,
                },
            })
        end
    elseif cmd == "SPELL_DEL" then
        local id = rest:match("^(%S+)$")
        if id then
            Spells.remove(id)
            for i = 1, 5 do
                if State.skillbar[i] == id then State.skillbar[i] = nil end
            end
        end
    elseif cmd == "LEAVE" then
        local id = tonumber(rest)
        if id then State.players[id] = nil end
    elseif cmd == "ATK" then
        local id, fx, fy = rest:match("^(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        id = tonumber(id)
        local p = State.players[id]
        if p then
            p.atkTime = love.timer.getTime()
            p.fx, p.fy = tonumber(fx), tonumber(fy)
        end
    elseif cmd == "HIT" then
        local id = tonumber(rest)
        local e = State.enemies[id]
        if e then e.hitTime = love.timer.getTime() end
    elseif cmd == "PHIT" then
        local id = tonumber(rest)
        local p = State.players[id]
        if p then p.hitTime = love.timer.getTime() end
    elseif cmd == "PDIE" then
        local id = tonumber(rest)
        local p = State.players[id]
        if p then p.dieTime = love.timer.getTime() end
    elseif cmd == "EDIE" then
        local id = tonumber(rest)
        if id then State.enemies[id] = nil end
    elseif cmd == "SPELL" then
        local casterId, spellId, fx, fy, ox, oy,
              skind, srange, sradius, sr, sg, sb = rest:match(
            "^(%-?%d+)%s+(%S+)%s+" ..
            "(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+" ..
            "(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+" ..
            "(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        if spellId then
            local kind = skind or "line"
            State.activeSpells[#State.activeSpells + 1] = {
                spellId  = spellId,
                casterId = tonumber(casterId),
                fx       = tonumber(fx),
                fy       = tonumber(fy),
                ox       = tonumber(ox),
                oy       = tonumber(oy),
                kind     = kind,
                range    = tonumber(srange) or 0,
                radius   = tonumber(sradius) or 0,
                color    = {
                    (tonumber(sr) or 200) / 255,
                    (tonumber(sg) or 200) / 255,
                    (tonumber(sb) or 200) / 255,
                },
                start    = love.timer.getTime(),
                duration = durationFor(kind),
            }
        end
    elseif cmd == "P" or cmd == "E" then
        handleSnapshot(line)
    end
end

return M
