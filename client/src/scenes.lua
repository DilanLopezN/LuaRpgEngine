local State   = require("src.state")
local Network = require("src.network")

local M = {}

function M.tryConnect()
    if #State.nameInput:gsub("%s", "") == 0 then
        State.status = "Digite um nome primeiro"
        return false
    end
    local ok, err = Network.connect(State.serverHost, State.serverPort)
    if not ok then
        State.scene  = State.SCENE_NAME
        State.status = "offline: " .. tostring(err)
        return false
    end
    Network.send("NAME " .. State.nameInput)
    State.scene  = State.SCENE_CONNECTING
    State.status = "conectando..."
    return true
end

function M.drawNameScene()
    local W, H = love.graphics.getDimensions()
    love.graphics.clear(0.07, 0.09, 0.13)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(State.fonts.title)
    local title = "LuaRpgEngine"
    love.graphics.print(title, (W - State.fonts.title:getWidth(title)) / 2, H / 2 - 140)

    love.graphics.setFont(State.fonts.ui)
    local prompt = "Nomeie seu personagem:"
    love.graphics.print(prompt, (W - State.fonts.ui:getWidth(prompt)) / 2, H / 2 - 60)

    local boxW, boxH = 360, 44
    local boxX, boxY = (W - boxW) / 2, H / 2 - 24
    love.graphics.setColor(0.15, 0.18, 0.24)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 6, 6)
    love.graphics.setColor(0.5, 0.55, 0.65)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 6, 6)

    love.graphics.setColor(1, 1, 1)
    local text = State.nameInput
    if (math.floor(love.timer.getTime() * 2) % 2) == 0 then
        text = text .. "_"
    end
    love.graphics.print(text, boxX + 10, boxY + (boxH - State.fonts.ui:getHeight()) / 2)

    love.graphics.setColor(0.7, 0.7, 0.75)
    local hint = "Enter para entrar. WASD para mover, Espaço para atacar, F1 abre o editor da engine, F11 alterna tela cheia."
    love.graphics.print(hint, (W - State.fonts.ui:getWidth(hint)) / 2, boxY + boxH + 18)

    if State.status and State.status ~= "" then
        love.graphics.setColor(0.9, 0.7, 0.3)
        love.graphics.print(State.status,
            (W - State.fonts.ui:getWidth(State.status)) / 2, boxY + boxH + 46)
    end
end

return M
