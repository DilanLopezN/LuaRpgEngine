-- Entry point. Wires LÖVE callbacks into the engine modules and keeps the
-- per-frame loop minimal. Every responsibility lives in src/:
--   network.lua    – TCP transport
--   protocol.lua   – wire-format parser
--   state.lua      – shared mutable state
--   spells.lua     – dynamic spell registry (created via the editor)
--   editor.lua     – F1 in-game editor (Spell Creator tab)
--   skillbar.lua   – 5 hot slots, drag/drop, casting
--   render.lua     – world drawing (floor, players, enemies, NPCs, FX)
--   hud.lua        – HP/MP bars, character header
--   charpanel.lua  – F2 character panel (stats/inventory/quests)
--   chatui.lua     – chat overlay (T to open)
--   dialogui.lua   – NPC dialog modal
--   toasts.lua     – transient notifications (loot, XP, level)
--   input.lua      – keyboard/mouse dispatch and movement
--   scenes.lua     – non-gameplay scenes (name entry, connecting)
--   world.lua      – tile maths
--   icons.lua      – spell icon rendering shared by skillbar + editor

local State    = require("src.state")
local World    = require("src.world")
local Network  = require("src.network")
local Sprites  = require("src.sprites")
local Protocol = require("src.protocol")
local Render   = require("src.render")
local HUD      = require("src.hud")
local Skillbar = require("src.skillbar")
local Editor   = require("src.editor")
local Scenes   = require("src.scenes")
local Input    = require("src.input")
local Map      = require("src.map")
local Tooltip  = require("src.tooltip")
local CharPanel = require("src.charpanel")
local Chat     = require("src.chatui")
local Dialog   = require("src.dialogui")
local Toasts   = require("src.toasts")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    State.fonts.ui    = love.graphics.newFont(14)
    State.fonts.name  = love.graphics.newFont(13)
    State.fonts.title = love.graphics.newFont(28)
    math.randomseed(os.time())
    Sprites.init()
    -- Maximize so the editor (and the dragged window position) can roam the
    -- entire monitor instead of being clipped to a small client area. F11
    -- toggles borderless fullscreen for an even bigger canvas.
    love.window.maximize()
end

-- Network.poll dispatches every received line through Protocol.handle. A
-- single malformed message must not be allowed to abort love.update, or the
-- next call to Input.update never runs and the player ends up "stuck" with no
-- WSAD movement (the symptom we kept hunting). pcall isolates the parser.
local function safeHandle(line)
    local ok, err = pcall(Protocol.handle, line)
    if not ok then
        print("protocol error: " .. tostring(err) .. " | line=" .. tostring(line))
    end
end

function love.update(dt)
    Network.poll(safeHandle)

    if #State.activeSpells > 0 then
        local now = love.timer.getTime()
        local kept = {}
        for _, sp in ipairs(State.activeSpells) do
            if now - sp.start < sp.duration then
                kept[#kept + 1] = sp
            end
        end
        State.activeSpells = kept
    end

    Toasts.update()
    Input.update(dt)

    if State.scene == State.SCENE_PLAYING then
        local me = State.players[State.myId]
        if me and me.x then
            local sx = me.x * World.TILE_W + World.TILE_W / 2
            local sy = me.y * World.TILE_H + World.TILE_H / 2
            State.camera.x = sx - love.graphics.getWidth()  / 2
            State.camera.y = sy - love.graphics.getHeight() / 2
        end
    end
end

function love.draw()
    if State.scene == State.SCENE_NAME or State.scene == State.SCENE_CONNECTING then
        Scenes.drawNameScene()
        return
    end

    love.graphics.clear(0.08, 0.10, 0.14)
    love.graphics.push()
    love.graphics.translate(-State.camera.x, -State.camera.y)
    Render.drawWorld()
    love.graphics.pop()

    HUD.draw()
    Editor.draw()
    Skillbar.draw()
    CharPanel.draw()
    Chat.draw()
    Dialog.draw()
    Toasts.draw()
    Tooltip.draw()
end

love.textinput     = Input.textinput
love.keypressed    = Input.keypressed
love.mousepressed  = Input.mousepressed
love.mousemoved    = Input.mousemoved
love.mousereleased = Input.mousereleased
love.wheelmoved    = Input.wheelmoved

function love.quit()
    Network.close()
end
