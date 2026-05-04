local State   = require("src.state")
local Spells  = require("src.spells")
local Map     = require("src.map")
local JSON    = require("src.json")
local FX      = require("src.fx")

local SPELL_LINE_DURATION = 0.45
local SPELL_AREA_DURATION = 0.55
local SPELL_SELF_DURATION = 0.50

local MOVE_TRAIL = 0.18

local M = {}

local function approxEq(a, b)
    return math.abs((a or 0) - (b or 0)) < 0.001
end

-- pushChat appends a message to the rolling log used by the chat UI.
local function pushChat(kind, who, msg)
    local entry = { kind = kind, who = who or "", msg = msg or "", t = love.timer.getTime() }
    local hist = State.chat.history
    hist[#hist + 1] = entry
    while #hist > State.chat.max do
        table.remove(hist, 1)
    end
end

-- pushToast adds a transient floating notification.
local function pushToast(text, color)
    State.toasts[#State.toasts + 1] = {
        text = text,
        color = color or { 1, 0.95, 0.55 },
        expires = love.timer.getTime() + 3.0,
    }
end

local function decodeText(s)
    if not s or s == "_" then return "" end
    return (s:gsub("_", " "))
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
            -- Phase 6 — feedback visual: derivamos delta de HP/MP do
            -- snapshot já que o servidor não envia o número do golpe
            -- explicitamente. O sinal decide se é dano ou cura.
            local prevHp, prevMp = p.hp, p.mp
            p.x, p.y    = nx, ny
            p.fx, p.fy  = tonumber(fx), tonumber(fy)
            p.hp        = tonumber(hp)
            p.maxHp     = tonumber(maxHp)
            p.mp        = tonumber(mp)
            p.maxMp     = tonumber(maxMp)
            p.atk       = tonumber(atk) == 1
            p.name      = name
            if prevHp and p.hp ~= prevHp then
                local d = p.hp - prevHp
                if d < 0 then
                    FX.spawn("dmg", p.x, p.y, -d)
                elseif d > 0 then
                    FX.spawn("heal", p.x, p.y, d)
                end
            end
            if prevMp and p.mp and p.mp > prevMp then
                FX.spawn("mana", p.x, p.y, p.mp - prevMp)
            end
        end
    elseif kind == "E" then
        -- Wire format expanded: optional <sprite> token after maxHp
        -- carries the custom artwork for hostile-NPC-promoted enemies
        -- (a guardian or named enemy authored in npcs_user/). Older
        -- builds without a sprite still parse via the fallback
        -- pattern below.
        local id, ekind, x, y, hp, maxHp, sprite =
            rest:match("^(%-?%d+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%S+)$")
        if not id then
            id, ekind, x, y, hp, maxHp = rest:match(
                "^(%-?%d+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        end
        if id then
            id = tonumber(id)
            local e = State.enemies[id]
            if not e then
                e = { hitTime = -1 }
                State.enemies[id] = e
            end
            local prevHp = e.hp
            e.kind     = ekind
            e.x, e.y   = tonumber(x), tonumber(y)
            e.hp       = tonumber(hp)
            e.maxHp    = tonumber(maxHp)
            if sprite == "-" or sprite == "" then sprite = nil end
            e.sprite   = sprite
            if prevHp and e.hp and e.hp < prevHp then
                FX.spawn("dmg", e.x, e.y, prevHp - e.hp)
            end
        end
    elseif kind == "N" then
        -- Sprite token is optional. Servers running the new wire format
        -- ship "N <id> <name> <x> <y> <sprite>" — older builds stop at y.
        local id, name, x, y, sprite =
            rest:match("^(%-?%d+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%S+)$")
        if not id then
            id, name, x, y = rest:match("^(%-?%d+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)$")
        end
        if id then
            id = tonumber(id)
            if sprite == "-" or sprite == "" then sprite = nil end
            State.npcs[id] = {
                id = id, name = name,
                sprite = sprite,
                x = tonumber(x), y = tonumber(y),
            }
        end
    elseif kind == "X" then
        -- Phase 5 — server tells us an entity left the AoI window.
        local k, id = rest:match("^(%a)%s+(%-?%d+)$")
        id = tonumber(id)
        if id then
            if k == "P" then State.players[id] = nil
            elseif k == "E" then State.enemies[id] = nil
            elseif k == "N" then State.npcs[id] = nil
            end
        end
    end
end

local function durationFor(kind)
    if kind == "line" then return SPELL_LINE_DURATION end
    if kind == "area" then return SPELL_AREA_DURATION end
    return SPELL_SELF_DURATION
end

-- Parsers grouped by command verb. Adding a new wire message means
-- dropping a function into this table — no other file needs to know.
local handlers = {}

handlers.WELCOME = function(rest)
    local id, w, h, name = rest:match("^(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(.+)$")
    if not id then
        local lid, ms, lname = rest:match("^(%-?%d+)%s+(%-?%d+)%s+(.+)$")
        id, w, h, name = lid, ms, ms, lname
    end
    State.myId      = tonumber(id)
    State.mapWidth  = tonumber(w) or State.mapWidth
    State.mapHeight = tonumber(h) or State.mapHeight
    State.mapSize   = State.mapWidth
    State.myName    = name
    State.scene     = State.SCENE_PLAYING
    State.status    = "conectado"
    State.lastSent.dx, State.lastSent.dy = -99, -99
    Spells.clear()
end


handlers.MAP_CHANGE = function(rest)
    local name = rest:match("^(%S+)")
    State.status = "Mapa: " .. (name or "world")
    State.players = {}
    State.enemies = {}
    State.npcs = {}
end
handlers.MAP = function(rest)
    local m, err = JSON.decode(rest)
    if m then
        Map.setActive(m)
        State.mapWidth  = m.width
        State.mapHeight = m.height
        State.mapSize   = math.max(m.width, m.height)
    else
        print("MAP decode failed: " .. tostring(err))
    end
end

-- Phase 2 — server reply to a warp trigger. Format:
--   MAP_CHANGE <name> <w> <h> <tx> <ty>
-- The MAP frame with the full destination layers arrived just before
-- this one. We use this hook to forget every entity that lived on the
-- old map (the snapshot pipeline's diff path won't emit "X" drops for
-- them because the LastSeen set was reset server-side) and to recentre
-- the camera on the new tile so the player doesn't see a one-frame
-- jump.
handlers.MAP_CHANGE = function(rest)
    local name, w, h, tx, ty = rest:match(
        "^(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
    if not name then return end
    State.currentMapName = name
    State.mapWidth  = tonumber(w) or State.mapWidth
    State.mapHeight = tonumber(h) or State.mapHeight
    State.mapSize   = math.max(State.mapWidth, State.mapHeight)
    -- Drop every other player / enemy / npc — they belonged to the
    -- previous world. Keep ourselves so the renderer has something
    -- to show until the next snapshot arrives.
    local me = State.players[State.myId]
    State.players = {}
    if me then
        local nx, ny = tonumber(tx), tonumber(ty)
        if nx and ny then
            me.x, me.y = nx, ny
        end
        State.players[State.myId] = me
    end
    State.enemies = {}
    State.npcs = {}
    State.activeSpells = {}
    pushToast(string.format("Mapa: %s", name), { 0.65, 0.85, 1.0 })
end

-- STATS carries up to 12 numeric fields. Older clients only knew the
-- first four; we now consume the full character sheet.

handlers.SHOP_OPEN = function(rest)
    local id, payload = rest:match("^(%S+)%s+(.+)$")
    if not id then return end
    local d = JSON.decode(payload)
    State.shop.open = true
    State.shop.id = id
    State.shop.def = d
end

handlers.SHOP_CLOSE = function()
    State.shop.open = false
    State.shop.id = nil
    State.shop.def = nil
end
handlers.STATS = function(rest)
    local hp, maxHp, mp, maxMp, level, xp, nextX, str, dex, intel, vit, gold = rest:match(
        "^(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)" ..
        "%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)" ..
        "%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
    if hp then
        local me = State.players[State.myId] or { atkTime = -1 }
        me.hp, me.maxHp = tonumber(hp), tonumber(maxHp)
        me.mp, me.maxMp = tonumber(mp), tonumber(maxMp)
        State.players[State.myId] = me
        local c = State.character
        c.level = tonumber(level)  or c.level
        c.xp    = tonumber(xp)     or c.xp
        c.nextX = tonumber(nextX)  or c.nextX
        c.str   = tonumber(str)    or c.str
        c.dex   = tonumber(dex)    or c.dex
        c.intel = tonumber(intel)  or c.intel
        c.vit   = tonumber(vit)    or c.vit
        c.gold  = tonumber(gold)   or c.gold
    else
        local hp4, maxHp4, mp4, maxMp4 = rest:match(
            "^(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
        if hp4 then
            local me = State.players[State.myId] or { atkTime = -1 }
            me.hp, me.maxHp = tonumber(hp4), tonumber(maxHp4)
            me.mp, me.maxMp = tonumber(mp4), tonumber(maxMp4)
            State.players[State.myId] = me
        end
    end
end

handlers.SPELL_DEF = function(rest)
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
end

handlers.SPELL_DEL = function(rest)
    local id = rest:match("^(%S+)$")
    if id then
        Spells.remove(id)
        for i = 1, 5 do
            if State.skillbar[i] == id then State.skillbar[i] = nil end
        end
    end
end

handlers.LEAVE = function(rest)
    local id = tonumber(rest)
    if id then State.players[id] = nil end
end

handlers.ATK = function(rest)
    local id, fx, fy = rest:match("^(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
    id = tonumber(id)
    local p = State.players[id]
    if p then
        p.atkTime = love.timer.getTime()
        p.fx, p.fy = tonumber(fx), tonumber(fy)
    end
end

handlers.EATK = function(rest)
    local id = tonumber(rest:match("^(%-?%d+)"))
    local e = State.enemies[id]
    if e then e.atkTime = love.timer.getTime() end
end

handlers.HIT = function(rest)
    local id = tonumber(rest)
    local e = State.enemies[id]
    if e then e.hitTime = love.timer.getTime() end
end

handlers.PHIT = function(rest)
    local id = tonumber(rest)
    local p = State.players[id]
    if p then p.hitTime = love.timer.getTime() end
end

handlers.PDIE = function(rest)
    local id = tonumber(rest)
    local p = State.players[id]
    if p then p.dieTime = love.timer.getTime() end
end

handlers.EDIE = function(rest)
    local id = tonumber(rest)
    if id then State.enemies[id] = nil end
end

handlers.SPELL = function(rest)
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
end

-- Phase 4 — inventory / items.
-- The wire moved to JSON when the editor needed to ship sprite, type,
-- damage, description, level_req and on_use without endless token
-- surgery. The legacy whitespace-separated format is still parsed so
-- a stale server build can still hand out items.
handlers.ITEM_DEF = function(rest)
    -- Try JSON first (current shape).
    local first = rest:sub(1, 1)
    if first == "{" then
        local ok, def = pcall(JSON.decode, rest)
        if ok and type(def) == "table" and def.id then
            State.itemDefs[def.id] = def
            return
        end
    end
    -- Legacy: id slot rarity stack bound attrs name
    local id, slot, rarity, stack, bound, _, name = rest:match(
        "^(%S+)%s+(%S+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(.+)$")
    if id then
        State.itemDefs[id] = {
            id     = id,
            name   = decodeText(name),
            slot   = slot,
            rarity = rarity,
            stack  = tonumber(stack) or 1,
            bound  = (bound == "1"),
        }
    end
end

handlers.ITEM_DEF_DELETE = function(rest)
    local id = rest:match("^(%S+)")
    if id then State.itemDefs[id] = nil end
end

handlers.INV_SET = function(rest)
    local count, items = rest:match("^(%-?%d+)%s*(.*)$")
    count = tonumber(count) or 0
    State.inventory = {}
    if count > 0 and items and items ~= "" then
        for token in items:gmatch("(%S+)") do
            local id, qty = token:match("^(.-):(%-?%d+)$")
            if id then
                State.inventory[#State.inventory + 1] = {
                    id = id, qty = tonumber(qty) or 0,
                }
            end
        end
    end
end

handlers.EQUIP_SET = function(rest)
    State.equipped = {}
    if rest and rest ~= "" then
        for token in rest:gmatch("(%S+)") do
            local slot, id = token:match("^(.-):(.+)$")
            if slot then State.equipped[slot] = id end
        end
    end
end

handlers.LOOT = function(rest)
    local id, qty = rest:match("^(%S+)%s+(%-?%d+)$")
    if id then
        local def = State.itemDefs[id]
        local label = def and def.name or id
        pushToast(string.format("+%s ×%d", label, tonumber(qty) or 1),
            { 0.65, 0.85, 0.55 })
    end
end

handlers.XP_GAIN = function(rest)
    local n = tonumber(rest)
    if n and n > 0 then
        pushToast(string.format("+%d XP", n), { 0.6, 0.8, 1.0 })
    end
end

handlers.LEVELUP = function(rest)
    local n = tonumber(rest) or 1
    pushToast(string.format("Level up! (+%d)", n), { 1.0, 0.85, 0.20 })
end

-- Phase 4 — skills / progression.
handlers.SKILL_DEF = function(rest)
    local id, kind, dmg, mana, cdMs, rng, rad, name = rest:match(
        "^(%S+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(.+)$")
    if id then
        State.skillDefs[id] = {
            id    = id,
            type  = kind,
            dmg   = tonumber(dmg) or 0,
            mana  = tonumber(mana) or 0,
            cdMs  = tonumber(cdMs) or 0,
            range = tonumber(rng) or 0,
            radius= tonumber(rad) or 0,
            name  = decodeText(name),
        }
    end
end

handlers.SKILL_LEARNED = function(rest)
    local id = rest:match("^(%S+)$")
    if id then State.learned[id] = true end
end

handlers.SKILL_POINTS = function(rest)
    State.character.skillPoints = tonumber(rest) or 0
end

handlers.SKILL_RESET = function(rest)
    State.learned = {}
    State.character.skillPoints = tonumber(rest) or 0
    pushToast("Skill tree reset", { 0.85, 0.65, 0.95 })
end

handlers.SKILL = function(rest)
    -- Visual fx for global skills mirror handlers.SPELL behaviour.
    local casterId, skillId, fx, fy, ox, oy = rest:match(
        "^(%-?%d+)%s+(%S+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)%s+(%-?%d+)$")
    if skillId then
        local def = State.skillDefs[skillId] or {}
        local kind = def.type == "area" and "area"
                  or def.type == "heal" and "self"
                  or def.type == "buff" and "self"
                  or "line"
        State.activeSpells[#State.activeSpells + 1] = {
            spellId  = skillId,
            casterId = tonumber(casterId),
            fx       = tonumber(fx),
            fy       = tonumber(fy),
            ox       = tonumber(ox),
            oy       = tonumber(oy),
            kind     = kind,
            range    = def.range or 4,
            radius   = def.radius or 1,
            color    = { 0.85, 0.55, 1.0 },
            start    = love.timer.getTime(),
            duration = durationFor(kind),
        }
    end
end

-- Phase 4 — NPCs / quests / dialog.
-- NPC_DEF wire payload is a single-line JSON document. Decoding it into a
-- table puts the full editor-authored shape (role, faction, sprite, hp,
-- damage, quest binding, ...) within reach of every client surface that
-- needs to render NPCs distinctly — no extra round-trip to the server.
handlers.NPC_DEF = function(rest)
    local ok, def = pcall(JSON.decode, rest)
    if not ok or type(def) ~= "table" or not def.id then
        return
    end
    State.npcDefs[def.id] = def
end

-- A user-authored NPC was deleted. Drop it from the catalog so its name
-- no longer appears in the editor's quest dropdowns or dialog labels.
handlers.NPC_DEF_DELETE = function(rest)
    local id = rest:match("^(%S+)")
    if id then State.npcDefs[id] = nil end
end

-- QUEST_DEF agora é um JSON com schema rico (multi-objective, reward
-- bundle, prereqs, mensagens). O cliente guarda tudo como uma tabela
-- e a UI escolhe o que renderizar.
handlers.QUEST_DEF = function(rest)
    local ok, def = pcall(JSON.decode, rest)
    if not ok or type(def) ~= "table" or not def.id then
        return
    end
    State.questDefs[def.id] = def
end

-- Servidor avisou que uma quest foi excluída pelo editor.
handlers.QUEST_DEF_DELETE = function(rest)
    local id = rest:match("^(%S+)")
    if id then State.questDefs[id] = nil end
end

-- QUEST_STATE: <id> <stage> <killCount> <done> <progress csv|->.
-- O killCount fica por compat — todo cliente novo lê o vetor
-- progress em vez. Quando o vetor é "-" caímos pro fallback antigo.
handlers.QUEST_STATE = function(rest)
    local id, stage, kills, done, prog = rest:match(
        "^(%S+)%s+(%S+)%s+(%-?%d+)%s+(%S+)%s+(%S+)$")
    if not id then
        id, stage, kills, done = rest:match(
            "^(%S+)%s+(%S+)%s+(%-?%d+)%s+(%S+)$")
        prog = "-"
    end
    if not id then return end
    local progress = {}
    if prog and prog ~= "-" and prog ~= "" then
        for n in string.gmatch(prog, "([^,]+)") do
            progress[#progress + 1] = tonumber(n) or 0
        end
    end
    local prev = State.quests[id]
    State.quests[id] = {
        id = id,
        stage = stage,
        killCount = tonumber(kills) or 0,
        done = (done == "1"),
        progress = progress,
    }
    if not prev then
        local def = State.questDefs[id]
        pushToast(string.format("Quest: %s", def and def.name or id),
            { 1.0, 0.85, 0.55 })
    elseif prev and (prev.killCount or 0) ~= (tonumber(kills) or 0) and not (done == "1") then
        -- Bumped progress on an active quest — small toast so the
        -- player notices their kill counted.
        pushToast(string.format("%s: progresso", id), { 0.85, 0.95, 1.0 })
    end
end

handlers.QUEST_COMPLETE = function(rest)
    local id = rest:match("^(%S+)")
    local def = State.questDefs[id] or {}
    pushToast(string.format("Quest complete: %s", def.name or id),
        { 0.85, 1.0, 0.55 })
end

handlers.DIALOG = function(rest)
    local npc, node, text = rest:match("^(%S+)%s+(%S+)%s+(.+)$")
    if npc then
        State.dialog = {
            npc     = npc,
            node    = node,
            text    = decodeText(text),
            options = {},
        }
    end
end

handlers.DIALOG_OPT = function(rest)
    local idx, text = rest:match("^(%-?%d+)%s+(.+)$")
    if idx and State.dialog then
        State.dialog.options[#State.dialog.options + 1] = {
            idx  = tonumber(idx),
            text = decodeText(text),
        }
    end
end

handlers.DIALOG_END = function()
    State.dialog = nil
end

-- Phase 4 — chat.
handlers.CHAT = function(rest)
    local sub, who, msg = rest:match("^(%S+)%s+(%S+)%s+(.+)$")
    if not sub then
        sub, who, msg = "SYS", "server", rest
    end
    pushChat(sub, who, msg)
end

handlers.SYS = function(rest)
    pushChat("SYS", "system", rest or "")
end

handlers.RELOADED = function(rest)
    pushChat("SYS", "server", "reloaded " .. (rest or "all"))
end

function M.handle(line)
       print("RX: " .. line)
    local cmd, rest = line:match("^(%S+)%s*(.*)$")
    if not cmd then return end
    local h = handlers[cmd]
    if h then
        h(rest)
        return
    end
    if cmd == "P" or cmd == "E" or cmd == "N" or cmd == "X" then
        handleSnapshot(line)
    end
end

return M
