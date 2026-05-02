-- Active world map on the client.
--
-- The server is the source of truth: on connect (and after every successful
-- save) it pushes a `MAP <json>` message which Protocol routes here. Editor
-- mutations happen locally and are flushed back via a `SAVE_MAP <json>`
-- command. There's no per-tile delta protocol in Phase 1 — the whole map
-- round-trips, which keeps the wire format trivial and the editor's
-- save/undo semantics easy to reason about.

local Tilesets = require("src.tilesets")

local M = {}

M.SCHEMA_VERSION = 1
M.LAYER_NAMES    = { "ground", "decoration", "collision", "logic" }

M.current = nil

local function emptyLayer(w, h)
    local rows = {}
    for y = 1, h do
        local r = {}
        for x = 1, w do r[x] = 0 end
        rows[y] = r
    end
    return rows
end

-- normalize takes a raw map table parsed from JSON (or built locally) and
-- fills in any missing fields/layers so the rest of the codebase can treat
-- maps as totally regular.
function M.normalize(m)
    m.schema_version = m.schema_version or M.SCHEMA_VERSION
    m.name           = m.name or "world"
    m.width          = m.width  or 20
    m.height         = m.height or 20
    m.tile_w         = m.tile_w or 16
    m.tile_h         = m.tile_h or 16
    m.tilesets       = m.tilesets or {}
    m.entities       = m.entities or {}
    m.layers         = m.layers or {}
    for _, name in ipairs(M.LAYER_NAMES) do
        local layer = m.layers[name]
        if type(layer) ~= "table" or #layer == 0 then
            m.layers[name] = emptyLayer(m.width, m.height)
        else
            -- Trim/pad each row to width and pad/truncate to height.
            for y = 1, m.height do
                local row = layer[y]
                if type(row) ~= "table" then
                    row = {}
                    layer[y] = row
                end
                for x = 1, m.width do
                    row[x] = row[x] or 0
                end
                for x = m.width + 1, #row do row[x] = nil end
            end
            for y = m.height + 1, #layer do layer[y] = nil end
        end
    end
    return m
end

-- setActive replaces the world map and reloads tileset images.
function M.setActive(m)
    M.normalize(m)
    M.current = m
    Tilesets.load(m.tilesets)
end

function M.empty(width, height)
    local m = {
        schema_version = M.SCHEMA_VERSION,
        name           = "world",
        width          = width or 20,
        height         = height or 20,
        tile_w         = 16,
        tile_h         = 16,
        tilesets       = {},
        entities       = {},
        layers         = {},
    }
    M.normalize(m)
    return m
end

function M.inBounds(x, y)
    local m = M.current
    if not m then return false end
    return x >= 1 and x <= m.width and y >= 1 and y <= m.height
end

function M.get(layer, x, y)
    local m = M.current
    if not m or not M.inBounds(x, y) then return 0 end
    local row = m.layers[layer]
    if not row then return 0 end
    row = row[y]
    if not row then return 0 end
    return row[x] or 0
end

function M.set(layer, x, y, value)
    local m = M.current
    if not m or not M.inBounds(x, y) then return end
    local layerData = m.layers[layer]
    if not layerData then return end
    layerData[y] = layerData[y] or {}
    layerData[y][x] = value or 0
end

-- snapshot returns a deep copy of the layers + entities so the editor can
-- stash an undo entry without worrying about aliasing.
function M.snapshot()
    local m = M.current
    if not m then return nil end
    local copy = { layers = {}, entities = {} }
    for _, name in ipairs(M.LAYER_NAMES) do
        local src = m.layers[name]
        local dst = {}
        for y = 1, m.height do
            local r = {}
            local sr = src and src[y]
            for x = 1, m.width do r[x] = (sr and sr[x]) or 0 end
            dst[y] = r
        end
        copy.layers[name] = dst
    end
    for i, e in ipairs(m.entities) do
        copy.entities[i] = {
            type = e.type, kind = e.kind, sprite = e.sprite,
            x = e.x, y = e.y,
        }
    end
    return copy
end

function M.restore(snap)
    local m = M.current
    if not m or not snap then return end
    for _, name in ipairs(M.LAYER_NAMES) do
        local src = snap.layers[name]
        if src then
            local dst = m.layers[name]
            for y = 1, m.height do
                for x = 1, m.width do
                    dst[y][x] = (src[y] and src[y][x]) or 0
                end
            end
        end
    end
    m.entities = {}
    for i, e in ipairs(snap.entities) do
        m.entities[i] = {
            type = e.type, kind = e.kind, sprite = e.sprite,
            x = e.x, y = e.y,
        }
    end
end

return M
