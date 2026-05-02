-- Phase 6 — keybinds configuráveis.
--
-- Os ações mapeáveis vivem aqui. O resto do cliente pergunta
-- Keybinds.is(action, key) em vez de comparar strings literais — assim
-- trocar a tecla é UMA mudança de tabela em vez de caça aos `if key ==`
-- pelo código.
--
-- Persistência: gravamos em love.filesystem (savedir do LÖVE) como JSON
-- ao confirmar um rebind. Se o arquivo não existir os defaults são
-- usados sem barulho.
--
-- Captura de input para rebind: regra do roadmap §🎨 (Phase 6) —
-- timeout de 5s e Esc para cancelar. Sem isso, a UI fica congelada para
-- sempre se o usuário desistir no meio.

local State = require("src.state")
local JSON  = require("src.json")

local M = {}

local FILE = "keybinds.json"
local CAPTURE_TIMEOUT = 5.0  -- segundos

-- Defaults. Cada ação é uma lista — várias teclas podem ativar a mesma
-- coisa (W e Up, por exemplo).
local DEFAULTS = {
    move_up    = { "w", "up" },
    move_down  = { "s", "down" },
    move_left  = { "a", "left" },
    move_right = { "d", "right" },
    attack     = { "space", "j" },
    chat       = { "return", "kpenter", "t" },
    talk       = { "e" },
    inventory  = { "i" },
    quests     = { "q" },
    editor     = { "f1" },
    character  = { "f2" },
    fullscreen = { "f11" },
    skill_1    = { "1" },
    skill_2    = { "2" },
    skill_3    = { "3" },
    skill_4    = { "4" },
    skill_5    = { "5" },
}

-- Cópia mutável; as outras partes do código nunca tocam DEFAULTS.
local bindings = {}

local function copyDefaults()
    bindings = {}
    for action, keys in pairs(DEFAULTS) do
        local copy = {}
        for i, k in ipairs(keys) do copy[i] = k end
        bindings[action] = copy
    end
end

local function load()
    if not love.filesystem.getInfo(FILE) then
        copyDefaults()
        return
    end
    local raw = love.filesystem.read(FILE)
    local parsed, err = JSON.decode(raw or "")
    if not parsed or type(parsed) ~= "table" then
        print("keybinds: load failed (" .. tostring(err) .. "), using defaults")
        copyDefaults()
        return
    end
    copyDefaults()
    for action, keys in pairs(parsed) do
        if bindings[action] and type(keys) == "table" then
            local copy = {}
            for i, k in ipairs(keys) do
                if type(k) == "string" then copy[#copy + 1] = k end
            end
            if #copy > 0 then bindings[action] = copy end
        end
    end
end

local function save()
    local ok, err = love.filesystem.write(FILE, JSON.encode(bindings))
    if not ok then
        print("keybinds: save failed (" .. tostring(err) .. ")")
    end
end

function M.init()
    load()
end

-- is(action, key) → boolean. O cliente chama assim:
--   if Keybinds.is("attack", key) then ... end
function M.is(action, key)
    local keys = bindings[action]
    if not keys then return false end
    for _, k in ipairs(keys) do
        if k == key then return true end
    end
    return false
end

-- isHeld(action) → polled equivalent for "is any of these keys held".
function M.isHeld(action)
    local keys = bindings[action]
    if not keys then return false end
    for _, k in ipairs(keys) do
        if love.keyboard.isDown(k) then return true end
    end
    return false
end

function M.actions()
    local out = {}
    for k in pairs(bindings) do out[#out + 1] = k end
    table.sort(out)
    return out
end

function M.keysFor(action)
    local keys = bindings[action]
    if not keys then return {} end
    local out = {}
    for i, k in ipairs(keys) do out[i] = k end
    return out
end

function M.resetDefaults()
    copyDefaults()
    save()
end

-- Captura assíncrona de tecla — retorna a uma máquina de estado em
-- State.keybindCapture. Quem chama M.startCapture(action) deve apenas
-- desenhar "Pressione uma tecla..." e deixar update()/keypressed() aqui
-- fazerem o trabalho.
function M.startCapture(action)
    if not bindings[action] then return false end
    State.keybindCapture = {
        action = action,
        startedAt = love.timer.getTime(),
        timeout = CAPTURE_TIMEOUT,
    }
    return true
end

function M.cancelCapture()
    State.keybindCapture = nil
end

function M.isCapturing()
    return State.keybindCapture ~= nil
end

-- update precisa rodar todo frame: cancela captura por timeout para a
-- UI não ficar travada esperando uma tecla pra sempre.
function M.update(dt)
    local cap = State.keybindCapture
    if not cap then return end
    if (love.timer.getTime() - cap.startedAt) >= cap.timeout then
        State.keybindCapture = nil
    end
end

-- keypressed → consome a próxima tecla quando estamos capturando.
-- Retorna true se a tecla foi consumida (não deve ir para gameplay).
function M.keypressed(key)
    local cap = State.keybindCapture
    if not cap then return false end
    if key == "escape" then
        State.keybindCapture = nil
        return true
    end
    -- Ignora teclas modificadoras puras — o usuário esperaria
    -- "Ctrl+S", não "Ctrl" sozinho.
    if key == "lctrl" or key == "rctrl" or key == "lshift" or key == "rshift"
       or key == "lalt" or key == "ralt" or key == "lgui" or key == "rgui" then
        return true
    end
    bindings[cap.action] = { key }
    State.keybindCapture = nil
    save()
    return true
end

return M
