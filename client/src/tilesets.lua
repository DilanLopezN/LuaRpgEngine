-- Tileset registry for the map renderer + map editor.
--
-- The map JSON declares one or more tilesets (image path + tile size); this
-- module loads each image, slices it into quads on demand, and exposes the
-- packed ID encoding shared with the server:
--   id == 0                                    → empty cell
--   id == tilesetID * 100000 + tileIndex       → otherwise
-- Where tileIndex = row * columns + column (0-based).

local M = {}

M.PACK_BASE  = 100000  -- tilesetID multiplier in packed IDs
M.tilesets   = {}      -- list ordered by registration index
M.byId       = {}      -- id → tileset entry

local function loadImage(path)
    if not path or path == "" then return nil end
    if not love.filesystem.getInfo(path) then return nil end
    local ok, img = pcall(love.graphics.newImage, path)
    if not ok or not img then return nil end
    img:setFilter("nearest", "nearest")
    return img
end

-- registerOne creates an entry and pre-builds quads. Returns nil if the
-- image can't be loaded (e.g. missing file in a server-authored map).
local function registerOne(spec)
    local img = loadImage(spec.path)
    if not img then
        return {
            id    = spec.id,
            path  = spec.path,
            tileW = spec.tile_w or spec.tileW or 16,
            tileH = spec.tile_h or spec.tileH or 16,
            image = nil, columns = 0, rows = 0, count = 0, quads = {},
        }
    end
    local iw, ih = img:getDimensions()
    local tileW = spec.tile_w or spec.tileW or 16
    local tileH = spec.tile_h or spec.tileH or 16
    local cols = math.floor(iw / tileW)
    local rows = math.floor(ih / tileH)
    local quads = {}
    for r = 0, rows - 1 do
        for c = 0, cols - 1 do
            local idx = r * cols + c
            quads[idx] = love.graphics.newQuad(c * tileW, r * tileH,
                tileW, tileH, iw, ih)
        end
    end
    return {
        id      = spec.id,
        path    = spec.path,
        tileW   = tileW,
        tileH   = tileH,
        image   = img,
        columns = cols,
        rows    = rows,
        count   = cols * rows,
        quads   = quads,
    }
end

function M.load(specs)
    M.tilesets = {}
    M.byId     = {}
    if not specs then return end
    for _, spec in ipairs(specs) do
        local entry = registerOne(spec)
        M.tilesets[#M.tilesets + 1] = entry
        M.byId[entry.id] = entry
    end
end

function M.list()
    return M.tilesets
end

function M.pack(tilesetId, tileIndex)
    return tilesetId * M.PACK_BASE + tileIndex
end

function M.unpack(id)
    if not id or id == 0 then return nil, nil end
    local ts = math.floor(id / M.PACK_BASE)
    local idx = id - ts * M.PACK_BASE
    return ts, idx
end

function M.resolve(id)
    local tsId, idx = M.unpack(id)
    if not tsId then return nil end
    local ts = M.byId[tsId]
    if not ts then return nil end
    local quad = ts.quads[idx]
    if not quad then return nil end
    return ts, quad, idx
end

return M
