-- Sprite/animation registry. Loads the Pixel Crawler sheets (symlinked into
-- client/assets) and exposes per-name lookup of (image, quad, fw, fh) at a
-- given playback time. The animations cycle endlessly; callers feed the
-- current love.timer.getTime() (or any monotonically-increasing seconds).

local M = {}

M.images     = {}
M.animations = {}

local CHAR = "assets/Pixel Crawler - Free Pack/Entities/Characters/Body_A/Animations"
local ORC  = "assets/Pixel Crawler - Free Pack/Entities/Mobs/Orc Crew/Orc"

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
