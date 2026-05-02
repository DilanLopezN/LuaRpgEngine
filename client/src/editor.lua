-- Editor unificado da engine (F1). Gerencia a janela externa (cabeçalho +
-- barra de abas) e delega o desenho/entrada para o módulo da aba ativa. A
-- janela é arrastável (segure no cabeçalho) e a barra de abas fica em sua
-- própria linha logo abaixo, então as duas abas renderizam o conteúdo na
-- área restante.
--
-- Abas:
--   "map"    → editor_map     (edição de mapa)
--   "spells" → editor_spells  (criação dinâmica de spells)

local State        = require("src.state")
local EditorSpells = require("src.editor_spells")
local EditorMap    = require("src.editor_map")
local EditorNPCs   = require("src.editor_npcs")
local Map          = require("src.map")
local Layout       = require("src.editor_layout")
local Tooltip      = require("src.tooltip")

local M = {}

local TABS = {
    { id = "map",    label = "Editor de Mapa", icon = "M",
      tip = "Editor de mapa: pintar tiles, marcar colisão, posicionar entidades. (Tab para alternar abas)" },
    { id = "npcs",   label = "Criar NPCs", icon = "N",
      tip = "Posicione NPCs no mapa e escolha seu sprite. (Tab para alternar abas)" },
    { id = "spells", label = "Criador de Spells", icon = "S",
      tip = "Crie e edite spells dinamicamente: tipo, efeito, dano, cooldown, cor. (Tab para alternar abas)" },
}

local TAB_PADDING_X = 22
local TAB_GAP       = 4
local CLOSE_SIZE    = 28

local TIP_HEADER = "Arraste para mover a janela em qualquer ponto do monitor.\n" ..
                   "Home ou Ctrl+R recentraliza. Esc fecha o editor."
local TIP_CLOSE  = "Fechar editor (Esc)."

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local function activeTab()
    if State.editorTab == "spells" then return EditorSpells end
    if State.editorTab == "npcs"   then return EditorNPCs   end
    return EditorMap
end

local function closeBtnRect()
    local hx, hy, hw = Layout.headerRect()
    local x = hx + hw - CLOSE_SIZE - 8
    local y = hy + (Layout.HEADER_H - CLOSE_SIZE) / 2
    return x, y, CLOSE_SIZE, CLOSE_SIZE
end

local function tabRects()
    local tx0, ty, _, th = Layout.tabBarRect()
    local rects = {}
    local x = tx0 + 8
    for _, t in ipairs(TABS) do
        local lw = State.fonts.ui:getWidth(t.label)
        local w  = lw + TAB_PADDING_X * 2
        rects[#rects + 1] = {
            id = t.id, label = t.label, tip = t.tip,
            x = x, y = ty, w = w, h = th,
        }
        x = x + w + TAB_GAP
    end
    return rects
end

-- ---------------------------------------------------------------------------
-- Drawing
-- ---------------------------------------------------------------------------

-- Vertical "gradient" emulated by a stack of solid bands. LÖVE doesn't ship
-- a gradient primitive and a mesh would be overkill here — 12 bands is
-- plenty smooth at the editor's draw scale.
local function drawVerticalGradient(x, y, w, h, top, bot, steps)
    steps = steps or 12
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        love.graphics.setColor(
            top[1] + (bot[1] - top[1]) * t,
            top[2] + (bot[2] - top[2]) * t,
            top[3] + (bot[3] - top[3]) * t,
            (top[4] or 1) + ((bot[4] or 1) - (top[4] or 1)) * t)
        local ys = y + math.floor(h * i / steps)
        local ye = y + math.floor(h * (i + 1) / steps)
        love.graphics.rectangle("fill", x, ys, w, ye - ys)
    end
end

local function drawHeader()
    local hx, hy, hw, hh = Layout.headerRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    -- Glossy gradient + accent bar bottom — reads as "title bar" without
    -- the flat slab look the previous design had.
    drawVerticalGradient(hx, hy, hw, hh,
        { 0.20, 0.26, 0.40, 1 }, { 0.10, 0.13, 0.20, 1 }, 14)
    love.graphics.setColor(0.45, 0.78, 1.00, 0.95)
    love.graphics.rectangle("fill", hx + 12, hy + hh - 3, hw - 24, 2)

    -- Drag-handle dots (top-left).
    love.graphics.setColor(0.55, 0.70, 0.95, 0.8)
    for i = 0, 2 do
        love.graphics.circle("fill", hx + 14 + i * 6, hy + 16, 1.6)
        love.graphics.circle("fill", hx + 14 + i * 6, hy + 28, 1.6)
    end

    -- Title block: app icon + name + subtitle hinting at the active tab.
    love.graphics.setColor(0.45, 0.78, 1.00, 0.18)
    love.graphics.rectangle("fill", hx + 38, hy + 8, hh - 16, hh - 16, 6, 6)
    love.graphics.setColor(0.85, 0.95, 1.0)
    love.graphics.setFont(State.fonts.title)
    love.graphics.print("⚙",
        hx + 38 + (hh - 16) / 2 - State.fonts.title:getWidth("⚙") / 2,
        hy + 8 + (hh - 16) / 2 - State.fonts.title:getHeight() / 2 - 2)

    love.graphics.setFont(State.fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Engine Editor",
        hx + 38 + (hh - 16) + 12, hy + 6)

    local subtitle = "Mapa · NPCs · Spells — F1 alterna · Tab troca aba · Esc fecha"
    if State.editorTab == "map"    then subtitle = "Editor de Mapa — pinte tiles, defina colisão, posicione entidades" end
    if State.editorTab == "npcs"   then subtitle = "Criar NPCs — escolha o sprite e clique no mapa para posicionar" end
    if State.editorTab == "spells" then subtitle = "Criador de Spells — crie spells dinamicamente e arraste à skillbar" end
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.65, 0.78, 0.95, 0.95)
    love.graphics.print(subtitle, hx + 38 + (hh - 16) + 12, hy + 6 + State.fonts.title:getHeight() - 4)

    local cx, cy, cw, ch = closeBtnRect()
    local hoverClose = pointIn(mx, my, cx, cy, cw, ch)
    if hoverClose then
        love.graphics.setColor(0.85, 0.30, 0.30)
        Tooltip.hover(TIP_CLOSE)
    else
        love.graphics.setColor(0.42, 0.16, 0.18)
        if pointIn(mx, my, hx, hy, hw, hh) then
            Tooltip.hover(TIP_HEADER)
        end
    end
    love.graphics.rectangle("fill", cx, cy, cw, ch, 6, 6)
    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.rectangle("line", cx, cy, cw, ch, 6, 6)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    local lblW = State.fonts.ui:getWidth("✕")
    love.graphics.print("✕",
        cx + (cw - lblW) / 2,
        cy + (ch - State.fonts.ui:getHeight()) / 2 - 1)
end

local function drawTabStrip()
    local tx, ty, tw, th = Layout.tabBarRect()
    drawVerticalGradient(tx, ty, tw, th,
        { 0.10, 0.13, 0.19, 1 }, { 0.05, 0.07, 0.11, 1 }, 8)
    love.graphics.setColor(0.4, 0.55, 0.78, 0.45)
    love.graphics.rectangle("fill", tx, ty + th - 1, tw, 1)

    love.graphics.setFont(State.fonts.ui)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    for _, r in ipairs(tabRects()) do
        local active = (r.id == State.editorTab)
        local hover  = pointIn(mx, my, r.x, r.y, r.w, r.h)
        if hover then Tooltip.hover(r.tip) end

        if active then
            drawVerticalGradient(r.x, r.y + 4, r.w, r.h - 4,
                { 0.18, 0.24, 0.36, 1 }, { 0.10, 0.14, 0.22, 1 }, 6)
            love.graphics.setColor(0.45, 0.78, 1.0, 0.35)
            love.graphics.rectangle("line", r.x, r.y + 4, r.w, r.h - 4, 4, 4)
        elseif hover then
            love.graphics.setColor(0.13, 0.17, 0.24, 0.85)
            love.graphics.rectangle("fill", r.x, r.y + 4, r.w, r.h - 4, 4, 4)
        end

        if active then
            love.graphics.setColor(1, 1, 1)
        elseif hover then
            love.graphics.setColor(0.95, 0.97, 1.0)
        else
            love.graphics.setColor(0.62, 0.70, 0.84)
        end
        love.graphics.print(r.label,
            r.x + TAB_PADDING_X,
            r.y + (r.h - State.fonts.ui:getHeight()) / 2)

        if active then
            love.graphics.setColor(0.45, 0.78, 1.0)
            love.graphics.rectangle("fill", r.x + 8, r.y + r.h - 3, r.w - 16, 2)
        end
    end
end

local function drawPanelFrame()
    local px, py, pw, ph = Layout.panelRect()
    -- Drop shadow.
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", px + 4, py + 6, pw, ph, 10, 10)
    -- Body with a soft top→bottom darkening.
    drawVerticalGradient(px, py, pw, ph,
        { 0.11, 0.13, 0.18, 0.98 }, { 0.07, 0.08, 0.12, 0.98 }, 16)
    -- Inner highlight + outer outline give the panel a "card" feel.
    love.graphics.setColor(0.45, 0.55, 0.78, 0.85)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", px, py, pw, ph, 10, 10)
    love.graphics.setColor(1, 1, 1, 0.05)
    love.graphics.rectangle("line", px + 1, py + 1, pw - 2, ph - 2, 9, 9)
end

function M.draw()
    if not State.editorOpen then return end
    if State.scene ~= State.SCENE_PLAYING then return end

    if State.editorTab == "map" and EditorMap.drawCursor then
        EditorMap.drawCursor()
    elseif State.editorTab == "npcs" and EditorNPCs.drawCursor then
        EditorNPCs.drawCursor()
    end

    drawPanelFrame()
    drawHeader()
    drawTabStrip()

    local tab = activeTab()
    if tab and tab.drawContent then tab.drawContent() end
end

-- ---------------------------------------------------------------------------
-- Input
-- ---------------------------------------------------------------------------

local function clickedTab(x, y)
    for _, r in ipairs(tabRects()) do
        if pointIn(x, y, r.x, r.y, r.w, r.h) then
            if State.editorTab ~= r.id then
                State.editorTab = r.id
                State.editorFocus = nil
            end
            return true
        end
    end
    return false
end

local function startDragOnHeader(x, y)
    local hx, hy, hw, hh = Layout.headerRect()
    if not pointIn(x, y, hx, hy, hw, hh) then return false end
    local cx, cy, cw, ch = closeBtnRect()
    if pointIn(x, y, cx, cy, cw, ch) then return false end
    State.editorDrag = { offsetX = x - hx, offsetY = y - hy }
    return true
end

function M.mousepressed(x, y, button)
    if not State.editorOpen then return false end
    if State.scene ~= State.SCENE_PLAYING then return false end
    button = button or 1

    if button == 1 then
        local cx, cy, cw, ch = closeBtnRect()
        if pointIn(x, y, cx, cy, cw, ch) then
            State.editorOpen = false
            State.editorFocus = nil
            State.editorDrag = nil
            return true
        end
        if startDragOnHeader(x, y) then return true end
    end

    local px, py, pw, ph = Layout.panelRect()
    if not pointIn(x, y, px, py, pw, ph) then
        -- Cliques fora da janela vão para a aba ativa para dispatch no
        -- mundo (Mapa = pintar/posicionar; NPCs = colocar/remover NPC).
        local tab = activeTab()
        if Map.current and tab and tab.worldClick then
            tab.worldClick(x, y, button)
            return true
        end
        return false
    end

    if button == 1 and clickedTab(x, y) then return true end

    local tab = activeTab()
    if tab and tab.mousepressedContent then
        return tab.mousepressedContent(x, y, button)
    end
    return true
end

function M.mousemoved(x, y, dx, dy)
    if not State.editorOpen then return false end
    if State.editorDrag then
        State.editorPanel.x = x - State.editorDrag.offsetX
        State.editorPanel.y = y - State.editorDrag.offsetY
        return true
    end
    if State.scene ~= State.SCENE_PLAYING then return false end
    if love.mouse.isDown(1) or love.mouse.isDown(2) then
        local tab = activeTab()
        local px, py, pw, ph = Layout.panelRect()
        if not pointIn(x, y, px, py, pw, ph) and tab and tab.worldDrag then
            tab.worldDrag(x, y)
        end
    end
    return false
end

function M.mousereleased(x, y, button)
    if State.editorDrag then
        State.editorDrag = nil
        return true
    end
    if not State.editorOpen then return false end
    local tab = activeTab()
    if tab and tab.worldRelease then tab.worldRelease() end
    return false
end

function M.wheelmoved(dx, dy)
    if not State.editorOpen then return false end
    local tab = activeTab()
    if tab and tab.wheelmoved then
        tab.wheelmoved(dx, dy)
        return true
    end
    return false
end

function M.textinput(t)
    if not State.editorOpen then return false end
    local tab = activeTab()
    if tab and tab.textinput then return tab.textinput(t) end
    return false
end

function M.keypressed(key)
    if not State.editorOpen then return false end
    if key == "escape" then
        if State.editorFocus then
            State.editorFocus = nil
        else
            State.editorOpen = false
            State.editorDrag = nil
        end
        return true
    end
    -- Recentraliza a janela.
    if key == "home" or (love.keyboard.isDown("lctrl", "rctrl") and key == "r") then
        Layout.recenter()
        return true
    end
    -- Tab / Shift+Tab alterna abas.
    if key == "tab" then
        local idx = 1
        for i, t in ipairs(TABS) do if t.id == State.editorTab then idx = i; break end end
        local shift = love.keyboard.isDown("lshift", "rshift")
        idx = idx + (shift and -1 or 1)
        if idx < 1 then idx = #TABS end
        if idx > #TABS then idx = 1 end
        State.editorTab = TABS[idx].id
        State.editorFocus = nil
        return true
    end
    local tab = activeTab()
    if tab and tab.keypressed then
        if tab.keypressed(key) then return true end
    end
    return false
end

-- Chamado por input.lua quando F1 abre o editor. Garante que a janela esteja
-- visível mesmo se ela tiver sido arrastada para fora da tela.
function M.opened()
    Layout.ensureReachable()
end

return M
