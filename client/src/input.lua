-- Player input dispatcher.
--
-- The game is WSAD-first: every frame we sample the keyboard and turn
-- the held W/A/S/D (or arrow keys) into a (dx, dy) intent that is
-- shipped to the server as `MOVE dx dy`. The server is the single
-- authority on whether the step is allowed; the client simply expresses
-- desire. Sending only on change keeps the wire empty when the player
-- is idle, while a sentinel value (-99, -99) on connect forces a
-- guaranteed first frame so the server never has stale state.
--
-- Attack: Space (or J, mouse-friendly) sends `ATTACK`. Holding the key
-- repeatedly issues the request; the server gates it via NextAttack so
-- the client never has to track its own cooldown.
--
-- Other input surfaces (chat, dialog, character panel, editor, skill
-- bar) get first refusal on every event. Only when none of them claim
-- the keypress do we touch movement / attack.

local State    = require("src.state")
local Network  = require("src.network")
local Editor   = require("src.editor")
local Skillbar = require("src.skillbar")
local Scenes   = require("src.scenes")
local World    = require("src.world")
local Chat     = require("src.chatui")
local Dialog   = require("src.dialogui")
local Char     = require("src.charpanel")
local Keybinds = require("src.keybinds")

local M = {}

-- ATTACK is rate-limited at the server, but we throttle on the client
-- too so a held key doesn't generate 60 messages/second.
local ATTACK_REPEAT = 0.18  -- seconds between auto-fired attacks
local lastAttackSent = -1

-- inputBlocked espelha exatamente os overlays REALMENTE abertos: editor
-- (com ou sem campo focado), chat, modal de NPC, painel de personagem ou
-- captura de keybind. Manter essa lista em UM único lugar evita o bug
-- recorrente de "personagem anda sozinho com a UI aberta".
--
-- Regra: TODA UI nova com captura de input deve aparecer aqui *e* expor
-- um isOpen()/isCapturing() correspondente. Se a flag pode ficar pendurada
-- (ex.: editorFocus que não fechou), clearOverlays() é o reset central.
local function inputBlocked()
    return State.editorOpen or State.editorFocus
        or Chat.isOpen() or Dialog.isOpen() or Char.isOpen()
        or (State.keybindCapture ~= nil)
end

-- clearOverlays é chamado em love.focus(false) e love.resize: qualquer
-- evento que possa deixar uma UI "presa" tem de passar por aqui.
function M.clearOverlays()
    State.editorOpen   = false
    State.editorFocus  = nil
    State.editorDrag   = nil
    State.charPanelOpen = false
    if Chat.close then Chat.close() end
    State.keybindCapture = nil
end

function M.textinput(t)
    if Chat.textinput(t) then return end
    if Editor.textinput(t) then return end
    if State.scene == State.SCENE_NAME and #State.nameInput < 24 then
        if t:match("[%w _%-]") then
            State.nameInput = State.nameInput .. t
        end
    end
end

local function npcAtTile(tx, ty)
    for _, n in pairs(State.npcs or {}) do
        if n.x == tx and n.y == ty then return n end
    end
end

function M.keypressed(key)
    -- Captura de keybind tem prioridade absoluta — ela está esperando
    -- exatamente UMA tecla do usuário. Esc cancela, qualquer outra
    -- tecla vira o novo bind. Ver keybinds.lua para timeout.
    if Keybinds.keypressed(key) then return end

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

    -- UI overlays steal events first.
    if Chat.keypressed(key)   then return end
    if Dialog.keypressed(key) then return end

    if Keybinds.is("fullscreen", key) then
        local fs = love.window.getFullscreen()
        love.window.setFullscreen(not fs, "desktop")
        return
    end

    if Keybinds.is("editor", key) then
        State.editorOpen = not State.editorOpen
        State.editorFocus = nil
        if State.editorOpen and Editor.opened then Editor.opened() end
        return
    end

    if Keybinds.is("character", key) then
        Char.toggle()
        return
    end

    if Editor.keypressed(key) then return end
    if State.editorOpen then return end

    if Keybinds.is("chat", key) then
        Chat.open()
        return
    end

    if Keybinds.is("inventory", key) then
        State.charPanelOpen = true
        State.charPanelTab = "inventory"
        return
    end
    if Keybinds.is("quests", key) and not Char.isOpen() then
        State.charPanelOpen = true
        State.charPanelTab = "quests"
        return
    end

    if Keybinds.is("attack", key) then
        Network.send("ATTACK")
        lastAttackSent = love.timer.getTime()
        return
    end

    if Keybinds.is("talk", key) then
        -- Talk to the NPC in front of the player. This complements the
        -- mouse-click path so keyboard-only play stays viable.
        local me = State.players[State.myId]
        if me and me.x then
            local fx, fy = me.fx or 0, me.fy or 1
            local tx = math.floor(me.x + 0.5) + fx
            local ty = math.floor(me.y + 0.5) + fy
            local npc = npcAtTile(tx, ty)
            if npc then Network.send("TALK " .. (npc.name or "")) end
        end
        return
    end

    if key == "escape" then
        if Char.isOpen() then
            State.charPanelOpen = false
        else
            love.event.quit()
        end
        return
    end

    for slot = 1, 5 do
        if Keybinds.is("skill_" .. slot, key) then
            Skillbar.cast(slot)
            return
        end
    end
end

function M.mousepressed(x, y, button)
    State.mouse.x, State.mouse.y = x, y
    if State.scene ~= State.SCENE_PLAYING then return end

    if Dialog.mousepressed(x, y, button) then return end
    if Char.mousepressed(x, y, button) then return end
    if button == 1 and Skillbar.mousepressed(x, y) then return end
    if Editor.mousepressed(x, y, button) then return end

    -- Click an NPC tile to talk. Convert screen → world tile.
    if button == 1 then
        local wx = x + State.camera.x
        local wy = y + State.camera.y
        local tx = math.floor(wx / World.TILE_W)
        local ty = math.floor(wy / World.TILE_H)
        local npc = npcAtTile(tx, ty)
        if npc then
            Network.send("TALK " .. (npc.name or ""))
        end
    end
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
    if Keybinds.isHeld("move_up")    then dy = dy - 1 end
    if Keybinds.isHeld("move_down")  then dy = dy + 1 end
    if Keybinds.isHeld("move_left")  then dx = dx - 1 end
    if Keybinds.isHeld("move_right") then dx = dx + 1 end
    if dx < -1 then dx = -1 elseif dx > 1 then dx = 1 end
    if dy < -1 then dy = -1 elseif dy > 1 then dy = 1 end
    return dx, dy
end

function M.update(dt)
    if State.scene ~= State.SCENE_PLAYING then
        if love.keyboard.isDown("w","a","s","d") then
            print("BLOCKED: scene=" .. tostring(State.scene))
        end
        State.lastSent.dx, State.lastSent.dy = 0, 0
        return
    end

    if inputBlocked() then
        if love.keyboard.isDown("w","a","s","d") then
            print(string.format("BLOCKED at PLAYING: editorOpen=%s focus=%s chat=%s dialog=%s char=%s",
                tostring(State.editorOpen), tostring(State.editorFocus),
                tostring(Chat.isOpen()), tostring(Dialog.isOpen()), tostring(Char.isOpen())))
        end
        if State.lastSent.dx ~= 0 or State.lastSent.dy ~= 0 then
            Network.send("MOVE 0 0")
            State.lastSent.dx, State.lastSent.dy = 0, 0
        end
        return
    end

    local dx, dy = readWasd()
    if dx ~= State.lastSent.dx or dy ~= State.lastSent.dy then
        print(string.format("TX: MOVE %d %d (lastSent=%d,%d)", dx, dy, State.lastSent.dx, State.lastSent.dy))
        Network.send(string.format("MOVE %d %d", dx, dy))
        State.lastSent.dx, State.lastSent.dy = dx, dy
    end

    if Keybinds.isHeld("attack") then
        local now = love.timer.getTime()
        if now - lastAttackSent >= ATTACK_REPEAT then
            print("TX: ATTACK")
            Network.send("ATTACK")
            lastAttackSent = now
        end
    end
end

return M
