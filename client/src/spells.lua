-- Spell registry. The server (Postgres-backed) is the source of truth: on
-- WELCOME the client clears its registry and rebuilds it from SPELL_DEF
-- messages. The in-game editor mutates spells locally and sends REGSPELL /
-- DELSPELL to keep the server in sync.

local M = {}

M.list = {}
M.byId = {}

M.KINDS   = { "line", "area", "self" }
M.EFFECTS = { "damage", "heal", "mana" }

local function reindex()
    M.byId = {}
    for _, s in ipairs(M.list) do
        M.byId[s.id] = s
    end
end

local function genId()
    local t = math.floor(love.timer.getTime() * 1000)
    return string.format("u%d_%04d", t, math.random(1000, 9999))
end

local function clampColor(spell)
    spell.color = spell.color or { 0.8, 0.8, 0.8 }
    for i = 1, 3 do
        local v = spell.color[i] or 0.5
        if v < 0 then v = 0 end
        if v > 1 then v = 1 end
        spell.color[i] = v
    end
end

local function normalize(spell)
    spell.name     = spell.name or "Spell"
    spell.kind     = spell.kind or "line"
    spell.effect   = spell.effect or "damage"
    spell.range    = spell.range or 5
    spell.radius   = spell.radius or 1
    spell.power    = spell.power or 10
    spell.manaCost = spell.manaCost or 10
    spell.cooldown = spell.cooldown or 0.7
    clampColor(spell)
    return spell
end
M.normalize = normalize

function M.add(spell)
    normalize(spell)
    spell.id = spell.id or genId()
    M.list[#M.list + 1] = spell
    M.byId[spell.id] = spell
    return spell
end

function M.remove(id)
    for i, s in ipairs(M.list) do
        if s.id == id then
            table.remove(M.list, i)
            M.byId[id] = nil
            return true
        end
    end
    return false
end

function M.clear()
    M.list = {}
    M.byId = {}
end

-- The server is the persistence layer for spells; load/save here are no-op
-- compatibility shims for callers that haven't been migrated yet.
function M.load() end
function M.save() end

-- Apply a spell definition pushed by the server. Replaces the entry in place
-- if it already exists so references in the editor / skillbar stay valid.
function M.upsertFromServer(spell)
    normalize(spell)
    local existing = M.byId[spell.id]
    if existing then
        for k, v in pairs(spell) do existing[k] = v end
        return existing
    end
    M.list[#M.list + 1] = spell
    M.byId[spell.id] = spell
    return spell
end

-- REGSPELL payload:
--   <id> <kind> <effect> <range> <radius> <power> <manaCost> <cooldownMs>
--   <r> <g> <b> <name>
-- Name comes last so it can contain spaces.
function M.serialize(s)
    local r = math.floor((s.color[1] or 0) * 255 + 0.5)
    local g = math.floor((s.color[2] or 0) * 255 + 0.5)
    local b = math.floor((s.color[3] or 0) * 255 + 0.5)
    local name = s.name or ""
    if name == "" then name = s.id end
    return string.format("%s %s %s %d %d %d %d %d %d %d %d %s",
        s.id, s.kind, s.effect,
        s.range or 0, s.radius or 0,
        s.power or 0, s.manaCost or 0,
        math.floor((s.cooldown or 0) * 1000 + 0.5),
        r, g, b,
        name)
end

return M
