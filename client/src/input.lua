local State    = require("src.state")
local Network  = require("src.network")
local Editor   = require("src.editor")
local Skillbar = require("src.skillbar")
local Scenes   = require("src.scenes")

local M = {}

function M.textinput(t)
    if Editor.textinput(t) then return end
    if State.scene == State.SCENE_NAME and #State.nameInput < 24 then
        if t:match("[%w _%-]") then
            State.nameInput = State.nameInput .. t
        end
    end
end

function M.keypressed(key)
    if State.scene == State.SCENE_NAME then
        if key == "backspace" then
            State.nameInput = State.nameInput:sub(1, -2)
        elseif key == "return" or key == "kpenter" then
            Scenes.tryConnect()
        elseif key == "escape" then
            love.event.quit()
        end
        return
    end

    if State.scene ~= State.SCENE_PLAYING then return end

    if key == "f11" then
        local fs = love.window.getFullscreen()
        love.window.setFullscreen(not fs, "desktop")
        return
    end

    if key == "f1" then
        State.editorOpen = not State.editorOpen
        State.editorFocus = nil
        if State.editorOpen and Editor.opened then Editor.opened() end
        return
    end

    if Editor.keypressed(key) then return end

    if State.editorOpen then return end

    if key == "space" or key == "j" then
        Network.send("ATTACK")
    elseif key == "escape" then
        love.event.quit()
    elseif key:match("^[1-5]$") then
        Skillbar.cast(tonumber(key))
    end
end

function M.mousepressed(x, y, button)
    State.mouse.x, State.mouse.y = x, y
    if State.scene ~= State.SCENE_PLAYING then return end

    if button == 1 and Skillbar.mousepressed(x, y) then return end
    if Editor.mousepressed(x, y, button) then return end
end

function M.mousemoved(x, y, dx, dy)
    State.mouse.x, State.mouse.y = x, y
    if State.scene == State.SCENE_PLAYING and State.editorOpen then
        Editor.mousemoved(x, y, dx, dy)
    end
end

function M.mousereleased(x, y, button)
    State.mouse.x, State.mouse.y = x, y
    if button == 1 then
        Skillbar.mousereleased(x, y)
    end
    if State.scene == State.SCENE_PLAYING and State.editorOpen then
        Editor.mousereleased(x, y, button)
    end
end

function M.wheelmoved(dx, dy)
    if State.scene == State.SCENE_PLAYING and State.editorOpen then
        Editor.wheelmoved(dx, dy)
    end
end

-- readWasd polls every supported movement binding and clamps to {-1,0,1}.
-- We sample love.keyboard each frame instead of relying on keypressed/
-- keyreleased so dropped key events (alt-tab, focus loss) never leave the
-- avatar walking forever.
local function readWasd()
    local dx, dy = 0, 0
    if love.keyboard.isDown("w", "up")    then dy = dy - 1 end
    if love.keyboard.isDown("s", "down")  then dy = dy + 1 end
    if love.keyboard.isDown("a", "left")  then dx = dx - 1 end
    if love.keyboard.isDown("d", "right") then dx = dx + 1 end
    if dx < -1 then dx = -1 elseif dx > 1 then dx = 1 end
    if dy < -1 then dy = -1 elseif dy > 1 then dy = 1 end
    return dx, dy
end

function M.update(dt)
    if State.scene ~= State.SCENE_PLAYING then
        State.lastSent.dx, State.lastSent.dy = 0, 0
        return
    end
    if State.editorOpen or State.editorFocus then
        if State.lastSent.dx ~= 0 or State.lastSent.dy ~= 0 then
            Network.send("MOVE 0 0")
            State.lastSent.dx, State.lastSent.dy = 0, 0
        end
        return
    end
    local dx, dy = readWasd()
    if dx ~= State.lastSent.dx or dy ~= State.lastSent.dy then
        Network.send(string.format("MOVE %d %d", dx, dy))
        State.lastSent.dx, State.lastSent.dy = dx, dy
    end
end

return M
