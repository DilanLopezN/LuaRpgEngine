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
local EditorNPC    = require("src.editor_npc")
local Map          = require("src.map")
local Layout       = require("src.editor_layout")
local Tooltip      = require("src.tooltip")

local M = {}

local TABS = {
    { id = "map",    label = "Editor de Mapa",
      tip = "Editor de mapa: pintar tiles, marcar colisão, posicionar entidades. (Tab para alternar abas)" },
    { id = "spells", label = "Criador de Spells",
      tip = "Crie e edite spells dinamicamente: tipo, efeito, dano, cooldown, cor. (Tab para alternar abas)" },
    { id = "npcs",   label = "Criador de NPCs",
      tip = "Crie e edite NPCs com diálogos, opções e hooks de quest/item. (Tab para alternar abas)" },
}

local TAB_PADDING_X = 18
local TAB_GAP       = 6
local CLOSE_SIZE    = 22

local TIP_HEADER = "Arraste para mover a janela em qualquer ponto do monitor.\n" ..
                   "Home ou Ctrl+R recentraliza. Esc fecha o editor."
local TIP_CLOSE  = "Fechar editor (Esc)."

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local function activeTab()
    if State.editorTab == "spells" then return EditorSpells end
    if State.editorTab == "npcs"   then return EditorNPC end
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

local function drawHeader()
    local hx, hy, hw, hh = Layout.headerRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.16, 0.20, 0.30)
    love.graphics.rectangle("fill", hx, hy, hw, hh, 8, 8)
    love.graphics.setColor(0.16, 0.20, 0.30)
    love.graphics.rectangle("fill", hx, hy + hh - 8, hw, 8)
    love.graphics.setColor(0.05, 0.06, 0.10, 0.8)
    love.graphics.rectangle("fill", hx, hy + hh - 1, hw, 1)

    -- "Grip" para sinalizar que o cabeçalho é arrastável.
    love.graphics.setColor(0.55, 0.65, 0.85, 0.7)
    for i = 0, 2 do
        love.graphics.circle("fill", hx + 12 + i * 5, hy + 12, 1.5)
        love.graphics.circle("fill", hx + 12 + i * 5, hy + 22, 1.5)
    end

    love.graphics.setFont(State.fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Editor da Engine",
        hx + 32, hy + (hh - State.fonts.title:getHeight()) / 2 - 2)

    local cx, cy, cw, ch = closeBtnRect()
    local hoverClose = pointIn(mx, my, cx, cy, cw, ch)
    if hoverClose then
        love.graphics.setColor(0.75, 0.25, 0.25)
        Tooltip.hover(TIP_CLOSE)
    else
        love.graphics.setColor(0.45, 0.18, 0.18)
        if pointIn(mx, my, hx, hy, hw, hh) then
            Tooltip.hover(TIP_HEADER)
        end
    end
    love.graphics.rectangle("fill", cx, cy, cw, ch, 4, 4)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    local lblW = State.fonts.ui:getWidth("X")
    love.graphics.print("X",
        cx + (cw - lblW) / 2,
        cy + (ch - State.fonts.ui:getHeight()) / 2)
end

local function drawTabStrip()
    local tx, ty, tw, th = Layout.tabBarRect()
    love.graphics.setColor(0.07, 0.09, 0.13)
    love.graphics.rectangle("fill", tx, ty, tw, th)
    love.graphics.setColor(0.4, 0.5, 0.7, 0.5)
    love.graphics.rectangle("fill", tx, ty + th - 1, tw, 1)

    love.graphics.setFont(State.fonts.ui)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    for _, r in ipairs(tabRects()) do
        local active = (r.id == State.editorTab)
        local hover  = pointIn(mx, my, r.x, r.y, r.w, r.h)
        if hover then Tooltip.hover(r.tip) end

        if active then
            love.graphics.setColor(0.13, 0.18, 0.26)
            love.graphics.rectangle("fill", r.x, r.y + 3, r.w, r.h - 3, 4, 4)
        elseif hover then
            love.graphics.setColor(0.10, 0.13, 0.19)
            love.graphics.rectangle("fill", r.x, r.y + 3, r.w, r.h - 3, 4, 4)
        end

        if active then
            love.graphics.setColor(1, 1, 1)
        elseif hover then
            love.graphics.setColor(0.95, 0.97, 1.0)
        else
            love.graphics.setColor(0.65, 0.72, 0.84)
        end
        love.graphics.print(r.label,
            r.x + TAB_PADDING_X,
            r.y + (r.h - State.fonts.ui:getHeight()) / 2)

        if active then
            love.graphics.setColor(0.45, 0.78, 1.0)
            love.graphics.rectangle("fill", r.x + 6, r.y + r.h - 3, r.w - 12, 2)
        end
    end
end

local function drawPanelFrame()
    local px, py, pw, ph = Layout.panelRect()
    love.graphics.setColor(0.10, 0.12, 0.16, 0.97)
    love.graphics.rectangle("fill", px, py, pw, ph, 8, 8)
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.rectangle("line", px, py, pw, ph, 8, 8)
end

function M.draw()
    if not State.editorOpen then return end
    if State.scene ~= State.SCENE_PLAYING then return end

    if State.editorTab == "map" and EditorMap.drawCursor then
        EditorMap.drawCursor()
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
        -- Cliques fora da janela vão para o mundo (aba Mapa) ou caem.
        if State.editorTab == "map" and Map.current and EditorMap.worldClick then
            EditorMap.worldClick(x, y, button)
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
    if State.editorTab ~= "map" then return false end
    if love.mouse.isDown(1) or love.mouse.isDown(2) then
        local px, py, pw, ph = Layout.panelRect()
        if not pointIn(x, y, px, py, pw, ph) and EditorMap.worldDrag then
            EditorMap.worldDrag(x, y)
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
    if State.editorTab == "map" and EditorMap.worldRelease then
        EditorMap.worldRelease()
    end
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
