-- Sprite/animation registry. Loads the Pixel Crawler sheets (symlinked into
-- client/assets) and exposes per-name lookup of (image, quad, fw, fh) at a
-- given playback time. The animations cycle endlessly; callers feed the
-- current love.timer.getTime() (or any monotonically-increasing seconds).

local M = {}

M.images     = {}
M.animations = {}

local CHAR = "assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations"
local ORC  = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Orc Crew/Orc"

-- NPC sprite catalog. Each entry registers an "<id>_idle" animation pulled
-- from the Pixel Crawler pack and a label/category used by the NPC editor's
-- sprite picker. Sheets in this pack are 128x32 (4 frames of 32x32) for the
-- idle pose, so we hardcode that shape — adding new sprites with a different
-- frame size means extending this list, not the loader.
local NPC_SPRITE_DEFS = {
    -- Friendly NPCs.
    { id = "npc_knight",  label = "Cavaleiro", category = "NPC",
      path = "assets/Pixel Crawler - Free Pack/Entities/Npc's/Knight/Idle/Idle-Sheet.png" },
    { id = "npc_rogue",   label = "Ladina",    category = "NPC",
      path = "assets/Pixel Crawler - Free Pack/Entities/Npc's/Rogue/Idle/Idle-Sheet.png" },
    { id = "npc_wizzard", label = "Mago",      category = "NPC",
      path = "assets/Pixel Crawler - Free Pack/Entities/Npc's/Wizzard/Idle/Idle-Sheet.png" },
    -- Mobs reusable as quest givers / hostile NPCs.
    { id = "mob_orc",          label = "Orc",          category = "Orc",
      path = ORC .. "/Idle/Idle-Sheet.png" },
    { id = "mob_orc_warrior",  label = "Orc Guerreiro", category = "Orc",
      path = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Orc Crew/Orc - Warrior/Idle/Idle-Sheet.png" },
    { id = "mob_orc_rogue",    label = "Orc Ladino",    category = "Orc",
      path = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Orc Crew/Orc - Rogue/Idle/Idle-Sheet.png" },
    { id = "mob_orc_shaman",   label = "Orc Xamã",      category = "Orc",
      path = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Orc Crew/Orc - Shaman/Idle/Idle-Sheet.png" },
    { id = "mob_skeleton",         label = "Esqueleto",          category = "Esqueleto",
      path = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Skeleton Crew/Skeleton - Base/Idle/Idle-Sheet.png" },
    { id = "mob_skeleton_warrior", label = "Esqueleto Guerreiro", category = "Esqueleto",
      path = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Skeleton Crew/Skeleton - Warrior/Idle/Idle-Sheet.png" },
    { id = "mob_skeleton_rogue",   label = "Esqueleto Ladino",    category = "Esqueleto",
      path = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Skeleton Crew/Skeleton - Rogue/Idle/Idle-Sheet.png" },
    { id = "mob_skeleton_mage",    label = "Esqueleto Mago",      category = "Esqueleto",
      path = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Skeleton Crew/Skeleton - Mage/Idle/Idle-Sheet.png" },
}

M.npcSprites = {}     -- list of { id, label, category, animName }
M.npcSpritesById = {} -- id -> npcSprite entry

local function loadImage(path)
    if M.images[path] then return M.images[path] end
    local ok, img = pcall(love.graphics.newImage, path)
    if not ok or not img then
        return nil
    end
    img:setFilter("nearest", "nearest")
    M.images[path] = img
    return img
end

local function makeQuads(image, frames, fw, fh)
    local q = {}
    local iw, ih = image:getDimensions()
    for i = 0, frames - 1 do
        q[i + 1] = love.graphics.newQuad(i * fw, 0, fw, fh, iw, ih)
    end
    return q
end

local function defAnim(name, path, frames, fw, fh, frameTime)
    local img = loadImage(path)
    if not img then
        M.animations[name] = nil
        return
    end
    M.animations[name] = {
        image     = img,
        quads     = makeQuads(img, frames, fw, fh),
        frameTime = frameTime or 0.12,
        fw        = fw,
        fh        = fh,
    }
end

function M.init()
    defAnim("player_idle_down", CHAR .. "/Idle_Base/Idle_Down-Sheet.png", 4, 64, 64, 0.18)
    defAnim("player_idle_side", CHAR .. "/Idle_Base/Idle_Side-Sheet.png", 4, 64, 64, 0.18)
    defAnim("player_idle_up",   CHAR .. "/Idle_Base/Idle_Up-Sheet.png",   4, 64, 64, 0.18)
    defAnim("player_run_down",  CHAR .. "/Run_Base/Run_Down-Sheet.png",   6, 64, 64, 0.09)
    defAnim("player_run_side",  CHAR .. "/Run_Base/Run_Side-Sheet.png",   6, 64, 64, 0.09)
    defAnim("player_run_up",    CHAR .. "/Run_Base/Run_Up-Sheet.png",     6, 64, 64, 0.09)

    defAnim("orc_idle", ORC .. "/Idle/Idle-Sheet.png", 4, 32, 32, 0.18)
    defAnim("orc_run",  ORC .. "/Run/Run-Sheet.png",   6, 64, 64, 0.10)

    -- NPC catalog. Animations are registered as "<id>_idle"; the editor's
    -- sprite picker consumes M.npcSprites to render thumbnails. Each entry
    -- only loads if the underlying sheet is found, so a missing asset just
    -- drops the option from the picker instead of crashing on boot.
    M.npcSprites = {}
    M.npcSpritesById = {}
    for _, def in ipairs(NPC_SPRITE_DEFS) do
        local animName = def.id .. "_idle"
        defAnim(animName, def.path, 4, 32, 32, 0.18)
        if M.animations[animName] then
            local entry = {
                id = def.id, label = def.label, category = def.category,
                animName = animName,
            }
            M.npcSprites[#M.npcSprites + 1] = entry
            M.npcSpritesById[def.id] = entry
        end
    end
end

-- Returns the NPC sprite entry for the given id, or nil. Renderers fall back
-- to a placeholder when the sprite is missing so saved maps from older builds
-- still load.
function M.npcSprite(id)
    if not id or id == "" then return nil end
    return M.npcSpritesById[id]
end

function M.frame(name, t)
    local a = M.animations[name]
    if not a then return nil end
    local idx = math.floor((t or 0) / a.frameTime) % #a.quads + 1
    return a.image, a.quads[idx], a.fw, a.fh
end

function M.has(name)
    return M.animations[name] ~= nil
end

return M
