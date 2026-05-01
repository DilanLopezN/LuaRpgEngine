-- Aba "Criador de Spells" do editor unificado. Mantém uma lista à esquerda
-- (cards arrastáveis até a skillbar) e um formulário à direita com os campos
-- da spell selecionada. Cada alteração propaga para o servidor via REGSPELL
-- (autosave); o botão Excluir manda DELSPELL.

local State   = require("src.state")
local Spells  = require("src.spells")
local Network = require("src.network")
local Icons   = require("src.icons")
local Layout  = require("src.editor_layout")
local Tooltip = require("src.tooltip")

local M = {}

local LABEL_W   = 130
local FIELD_H   = 28
local FIELD_GAP = 8

-- Labels exibidos no toggle. Os IDs internos (line/area/self, damage/heal/mana)
-- continuam em inglês porque viajam pela rede e são chave em código.
local KIND_LABELS = {
    line = "Linha",
    area = "Área",
    self = "Próprio",
}
local EFFECT_LABELS = {
    damage = "Dano",
    heal   = "Cura",
    mana   = "Mana",
}

local KIND_TIPS = {
    line = "Projétil em linha reta na direção que você está olhando.",
    area = "Efeito quadrado em volta de um tile à frente.",
    self = "Aplica o efeito em você mesmo (boas para cura/mana).",
}
local EFFECT_TIPS = {
    damage = "Causa dano nos inimigos atingidos.",
    heal   = "Restaura HP do alvo (você ou aliados na área).",
    mana   = "Restaura mana do alvo.",
}

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local panelRect = Layout.panelRect

local function listRect()
    local cx, cy, _, ch = Layout.contentRect()
    return cx + 16, cy + 12, 260, ch - 28
end

local function formRect()
    local cx, cy, cw, ch = Layout.contentRect()
    local lw = 260
    return cx + 16 + lw + 16, cy + 12, cw - lw - 48, ch - 28
end

local function newSpell()
    return {
        name     = "Nova Spell",
        kind     = "line",
        effect   = "damage",
        range    = 5,
        radius   = 1,
        power    = 12,
        manaCost = 12,
        cooldown = 0.7,
        color    = { 0.95, 0.45, 0.20 },
    }
end

local function selected()
    return State.editorSelected and Spells.byId[State.editorSelected]
end
M.selected = selected

local function registerWithServer(spell)
    if Network.connected and not Network.connected() then return end
    Network.send("REGSPELL " .. Spells.serialize(spell))
end

local function unregisterWithServer(id)
    if Network.connected and not Network.connected() then return end
    Network.send("DELSPELL " .. id)
end

local function persist(spell)
    if spell then registerWithServer(spell) end
end

-- ---------------------------------------------------------------------------
-- Layout dos campos. A mesma função alimenta tanto o draw quanto o click,
-- então as posições nunca saem de sincronia.
-- ---------------------------------------------------------------------------

local function formFields(spell)
    local fx, fy, fw, fh = formRect()
    local rows = {}
    local y = fy + 16

    local function row(field)
        field.x = fx + 16
        field.y = y
        field.w = fw - 32
        field.h = field.h or FIELD_H
        rows[#rows + 1] = field
        y = y + field.h + FIELD_GAP
    end

    row{ name = "name", type = "text", label = "Nome",
         value = spell.name or "",
         tip = "Nome de exibição da spell. Mostrado no card e no ícone da skillbar." }

    row{ name = "kind", type = "toggle", label = "Tipo",
         value = spell.kind, options = Spells.KINDS,
         optionLabels = KIND_LABELS,
         optionTips   = KIND_TIPS,
         tip = "Geometria da spell: linha (projétil), área (AOE) ou próprio (autobuff)." }

    if spell.kind == "line" then
        row{ name = "range", type = "stepper", label = "Alcance",
             value = spell.range, step = 1, min = 1, max = 20,
             tip = "Distância máxima em tiles que o projétil percorre." }
    elseif spell.kind == "area" then
        row{ name = "radius", type = "stepper", label = "Raio",
             value = spell.radius, step = 1, min = 0, max = 6,
             tip = "Quantos tiles em volta do alvo são atingidos (0 = só o tile central)." }
    end

    row{ name = "effect", type = "toggle", label = "Efeito",
         value = spell.effect, options = Spells.EFFECTS,
         optionLabels = EFFECT_LABELS,
         optionTips   = EFFECT_TIPS,
         tip = "O que a spell faz: causar dano, curar HP ou restaurar mana." }

    row{ name = "power", type = "stepper", label = "Potência",
         value = spell.power, step = 5, min = 0, max = 500,
         tip = "Quantidade aplicada (HP de dano, HP curado ou mana restaurada)." }

    row{ name = "manaCost", type = "stepper", label = "Custo de Mana",
         value = spell.manaCost, step = 5, min = 0, max = 500,
         tip = "Mana consumida ao lançar a spell." }

    row{ name = "cooldown", type = "stepper", label = "Recarga (s)",
         value = spell.cooldown, step = 0.1, min = 0.1, max = 10, decimals = 1,
         tip = "Tempo (segundos) antes de poder lançar novamente." }

    row{ name = "colorR", type = "stepper", label = "Vermelho",
         value = math.floor((spell.color[1] or 0) * 255 + 0.5),
         step = 17, min = 0, max = 255,
         tip = "Componente vermelho (0–255) da cor do ícone e do efeito visual." }
    row{ name = "colorG", type = "stepper", label = "Verde",
         value = math.floor((spell.color[2] or 0) * 255 + 0.5),
         step = 17, min = 0, max = 255,
         tip = "Componente verde (0–255) da cor do ícone e do efeito visual." }
    row{ name = "colorB", type = "stepper", label = "Azul",
         value = math.floor((spell.color[3] or 0) * 255 + 0.5),
         step = 17, min = 0, max = 255,
         tip = "Componente azul (0–255) da cor do ícone e do efeito visual." }

    local by = fy + fh - 40
    rows[#rows + 1] = { type = "button", name = "delete",
        label = "Excluir", x = fx + 16, y = by, w = 110, h = 28,
        color = { 0.50, 0.20, 0.20 },
        tip = "Apaga esta spell do servidor e a remove de qualquer slot da skillbar." }
    rows[#rows + 1] = { type = "label", name = "hint",
        text  = "Arraste o card da esquerda até um slot da skillbar para equipar.",
        x = fx + 16 + 124, y = by + 6 }

    return rows
end

local function applyStep(spell, row, delta)
    local val = (row.value or 0) + delta
    if val < row.min then val = row.min end
    if val > row.max then val = row.max end
    if row.name == "colorR" then
        spell.color[1] = val / 255
    elseif row.name == "colorG" then
        spell.color[2] = val / 255
    elseif row.name == "colorB" then
        spell.color[3] = val / 255
    elseif row.decimals then
        spell[row.name] = math.floor(val * 10 + 0.5) / 10
    else
        spell[row.name] = val
    end
end

-- ---------------------------------------------------------------------------
-- Drawing
-- ---------------------------------------------------------------------------

local function drawListAndCards()
    local lx, ly, lw, lh = listRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", lx, ly, lw, lh, 4, 4)

    love.graphics.setFont(State.fonts.ui)
    local newBtnX, newBtnY, newBtnW, newBtnH = lx + 6, ly + 6, lw - 12, 28
    if pointIn(mx, my, newBtnX, newBtnY, newBtnW, newBtnH) then
        love.graphics.setColor(0.26, 0.55, 0.32)
        Tooltip.hover("Cria uma nova spell com valores padrão. Edite no formulário ao lado.")
    else
        love.graphics.setColor(0.20, 0.45, 0.25)
    end
    love.graphics.rectangle("fill", newBtnX, newBtnY, newBtnW, newBtnH, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("+ Nova Spell", lx + 18, ly + 11)

    love.graphics.setFont(State.fonts.name)
    local cardH = 56
    local cardY = ly + 44
    for i, sp in ipairs(Spells.list) do
        local cx = lx + 6
        local cy = cardY + (i - 1) * (cardH + 6)
        if cy + cardH > ly + lh then break end
        local hidden = State.drag and State.drag.source == "editor"
            and State.drag.spellId == sp.id
        if not hidden then
            local cw = lw - 12
            if pointIn(mx, my, cx, cy, cw, cardH) then
                Tooltip.hover("Clique para selecionar e editar. Arraste até um slot da skillbar para equipar.")
            end
            if sp.id == State.editorSelected then
                love.graphics.setColor(0.22, 0.34, 0.55)
            else
                love.graphics.setColor(0.13, 0.15, 0.20)
            end
            love.graphics.rectangle("fill", cx, cy, cw, cardH, 4, 4)
            love.graphics.setColor(0.35, 0.40, 0.50)
            love.graphics.rectangle("line", cx, cy, cw, cardH, 4, 4)
            Icons.drawSpell(sp, cx + 4, cy + 4, cardH - 8, cardH - 8, nil)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(sp.name or "?", cx + cardH + 4, cy + 6)
            love.graphics.setColor(0.7, 0.75, 0.85)
            local kindLabel   = KIND_LABELS[sp.kind] or sp.kind
            local effectLabel = EFFECT_LABELS[sp.effect] or sp.effect
            love.graphics.print(string.format("%s · %s", kindLabel, effectLabel),
                cx + cardH + 4, cy + 22)
            love.graphics.setColor(0.55, 0.7, 0.95)
            love.graphics.print("arraste até a skillbar →", cx + cardH + 4, cy + 38)
        end
    end

    if #Spells.list == 0 then
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.printf("Nenhuma spell ainda.\nClique em \"+ Nova Spell\" para criar.",
            lx + 12, ly + 80, lw - 24, "center")
    end
end

local function drawForm()
    local fx, fy, fw, fh = formRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", fx, fy, fw, fh, 4, 4)

    local spell = selected()
    if not spell then
        love.graphics.setFont(State.fonts.ui)
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.printf(
            "Selecione uma spell na lista ao lado ou clique em \"+ Nova Spell\" para criar.",
            fx + 16, fy + 24, fw - 32, "left")
        return
    end

    local rows = formFields(spell)
    love.graphics.setFont(State.fonts.ui)

    for _, r in ipairs(rows) do
        if r.type == "text" then
            love.graphics.setColor(0.7, 0.75, 0.85)
            love.graphics.print(r.label, r.x, r.y + 6)
            local tx = r.x + LABEL_W
            local tw = r.w - LABEL_W
            local focused = State.editorFocus == r.name
            love.graphics.setColor(focused and 0.20 or 0.13,
                                   focused and 0.25 or 0.15,
                                   focused and 0.32 or 0.20)
            love.graphics.rectangle("fill", tx, r.y, tw, r.h, 4, 4)
            love.graphics.setColor(focused and 0.7 or 0.4, 0.5, 0.7)
            love.graphics.rectangle("line", tx, r.y, tw, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            local txt = r.value or ""
            if focused and (math.floor(love.timer.getTime() * 2) % 2) == 0 then
                txt = txt .. "_"
            end
            love.graphics.print(txt, tx + 6, r.y + 6)
            if r.tip and pointIn(mx, my, tx, r.y, tw, r.h) then
                Tooltip.hover(r.tip)
            end
        elseif r.type == "toggle" then
            love.graphics.setColor(0.7, 0.75, 0.85)
            love.graphics.print(r.label, r.x, r.y + 6)
            local ox = r.x + LABEL_W
            for _, opt in ipairs(r.options) do
                local lbl = (r.optionLabels and r.optionLabels[opt]) or opt
                local ow = State.fonts.ui:getWidth(lbl) + 22
                if r.value == opt then
                    love.graphics.setColor(0.25, 0.42, 0.65)
                else
                    love.graphics.setColor(0.13, 0.15, 0.20)
                end
                love.graphics.rectangle("fill", ox, r.y, ow, r.h, 4, 4)
                love.graphics.setColor(0.4, 0.5, 0.6)
                love.graphics.rectangle("line", ox, r.y, ow, r.h, 4, 4)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(lbl, ox + 11, r.y + 6)
                if pointIn(mx, my, ox, r.y, ow, r.h) then
                    local optTip = r.optionTips and r.optionTips[opt]
                    Tooltip.hover(optTip or r.tip or "")
                end
                ox = ox + ow + 6
            end
        elseif r.type == "stepper" then
            love.graphics.setColor(0.7, 0.75, 0.85)
            love.graphics.print(r.label, r.x, r.y + 6)
            local sx = r.x + LABEL_W
            local sw = r.w - LABEL_W
            local btnW = 26

            love.graphics.setColor(0.20, 0.30, 0.45)
            love.graphics.rectangle("fill", sx, r.y, btnW, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("-", sx + btnW / 2 - 4, r.y + 6)

            love.graphics.setColor(0.13, 0.15, 0.20)
            love.graphics.rectangle("fill", sx + btnW + 4, r.y,
                sw - btnW * 2 - 8, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            local vstr
            if r.decimals then
                vstr = string.format("%." .. r.decimals .. "f", r.value)
            else
                vstr = tostring(r.value)
            end
            love.graphics.print(vstr, sx + btnW + 12, r.y + 6)

            love.graphics.setColor(0.20, 0.30, 0.45)
            love.graphics.rectangle("fill", sx + sw - btnW, r.y,
                btnW, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("+", sx + sw - btnW + btnW / 2 - 4, r.y + 6)
            if r.tip and pointIn(mx, my, sx, r.y, sw, r.h) then
                Tooltip.hover(r.tip)
            end
        elseif r.type == "button" then
            local hover = pointIn(mx, my, r.x, r.y, r.w, r.h)
            love.graphics.setColor(r.color)
            love.graphics.rectangle("fill", r.x, r.y, r.w, r.h, 4, 4)
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("line", r.x, r.y, r.w, r.h, 4, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(r.label, r.x + 12, r.y + 6)
            if hover and r.tip then Tooltip.hover(r.tip) end
        elseif r.type == "label" then
            love.graphics.setColor(0.65, 0.75, 0.9)
            love.graphics.print(r.text, r.x, r.y)
        end
    end
end

function M.drawContent()
    drawListAndCards()
    drawForm()
end

M.panelRect = panelRect
M.listRect  = listRect
M.formRect  = formRect

-- ---------------------------------------------------------------------------
-- Input
-- ---------------------------------------------------------------------------

local function listClick(x, y)
    local lx, ly, lw, lh = listRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end

    if pointIn(x, y, lx + 6, ly + 6, lw - 12, 28) then
        local sp = Spells.add(newSpell())
        State.editorSelected = sp.id
        State.editorFocus = nil
        registerWithServer(sp)
        return true
    end

    local cardH = 56
    local cardY = ly + 44
    for i, sp in ipairs(Spells.list) do
        local cx = lx + 6
        local cy = cardY + (i - 1) * (cardH + 6)
        if cy + cardH > ly + lh then break end
        if pointIn(x, y, cx, cy, lw - 12, cardH) then
            State.editorSelected = sp.id
            State.editorFocus = nil
            State.drag = { spellId = sp.id, source = "editor" }
            return true
        end
    end
    return true -- absorvido: clique dentro da lista
end

local function formClick(x, y)
    local fx, fy, fw, fh = formRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end
    local spell = selected()
    if not spell then return true end

    local rows = formFields(spell)
    for _, r in ipairs(rows) do
        if r.type == "text" then
            local tx = r.x + LABEL_W
            local tw = r.w - LABEL_W
            if pointIn(x, y, tx, r.y, tw, r.h) then
                State.editorFocus = r.name
                return true
            end
        elseif r.type == "toggle" then
            local ox = r.x + LABEL_W
            for _, opt in ipairs(r.options) do
                local lbl = (r.optionLabels and r.optionLabels[opt]) or opt
                local ow = State.fonts.ui:getWidth(lbl) + 22
                if pointIn(x, y, ox, r.y, ow, r.h) then
                    spell[r.name] = opt
                    State.editorFocus = nil
                    persist(spell)
                    return true
                end
                ox = ox + ow + 6
            end
        elseif r.type == "stepper" then
            local sx = r.x + LABEL_W
            local sw = r.w - LABEL_W
            local btnW = 26
            if pointIn(x, y, sx, r.y, btnW, r.h) then
                applyStep(spell, r, -r.step)
                State.editorFocus = nil
                persist(spell)
                return true
            elseif pointIn(x, y, sx + sw - btnW, r.y, btnW, r.h) then
                applyStep(spell, r, r.step)
                State.editorFocus = nil
                persist(spell)
                return true
            end
        elseif r.type == "button" then
            if pointIn(x, y, r.x, r.y, r.w, r.h) then
                if r.name == "delete" then
                    local id = spell.id
                    Spells.remove(id)
                    for i = 1, 5 do
                        if State.skillbar[i] == id then
                            State.skillbar[i] = nil
                        end
                    end
                    State.editorSelected = nil
                    unregisterWithServer(id)
                end
                State.editorFocus = nil
                return true
            end
        end
    end
    State.editorFocus = nil
    return true
end

function M.mousepressedContent(x, y)
    if listClick(x, y) then return true end
    if formClick(x, y) then return true end
    State.editorFocus = nil
    return true
end

function M.textinput(t)
    if not State.editorOpen then return false end
    if not State.editorFocus then return false end
    local sp = selected()
    if not sp then return false end
    local field = State.editorFocus
    if field == "name" and #(sp.name or "") < 24 then
        if t:match("[%w _%-]") then
            sp.name = (sp.name or "") .. t
        end
    end
    return true
end

function M.keypressed(key)
    if not State.editorOpen then return false end
    if State.editorFocus then
        local sp = selected()
        if sp and key == "backspace" then
            if State.editorFocus == "name" then
                sp.name = (sp.name or ""):sub(1, -2)
            end
            return true
        elseif key == "return" or key == "kpenter" then
            if sp then registerWithServer(sp) end
            State.editorFocus = nil
            return true
        end
        return true
    end
    return false
end

return M
