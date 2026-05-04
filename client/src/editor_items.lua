-- Aba "Criar Itens" do editor unificado.
--
-- Layout:
--   esquerda → catálogo (itens vindos de State.itemDefs; clique seleciona;
--              "+ Novo Item" zera o formulário)
--   centro   → formulário do item: identidade, tipo (drives o slot),
--              raridade, stack, bound, sprite (picker), stats (damage/
--              defense/attrs), level_req, value, two_handed, descrição,
--              on_use (consumíveis), botões salvar/excluir
--
-- Persistência:
--   • SAVE_ITEM_DEF <json>   → servidor escreve em items_user/<id>.json
--                              e re-broadcasta ITEM_DEF.
--   • DELETE_ITEM_DEF <id>   → servidor remove o arquivo + def.

local State   = require("src.state")
local Network = require("src.network")
local JSON    = require("src.json")
local Layout  = require("src.editor_layout")
local Tooltip = require("src.tooltip")
local Items   = require("src.items")

local M = {}

M.panelRect = Layout.panelRect

local FIELD_H  = 26
local LABEL_W  = 130
local SPRITE_THUMB = 36

local TYPE_LABELS = {
    weapon     = "Arma",
    staff      = "Cajado",
    shield     = "Escudo",
    armor      = "Armadura",
    helmet     = "Elmo",
    boots      = "Botas",
    ring       = "Anel",
    amulet     = "Amuleto",
    consumable = "Consumível",
    quest      = "Item de Missão",
    key        = "Chave",
    material   = "Material",
    currency   = "Moeda",
}
local TYPE_ORDER = {
    "weapon", "staff", "shield", "armor", "helmet", "boots",
    "ring", "amulet", "consumable", "quest", "key", "material", "currency",
}

local RARITY_LABELS = {
    common    = "Comum",
    uncommon  = "Incomum",
    rare      = "Raro",
    epic      = "Épico",
    legendary = "Lendário",
}
local RARITY_ORDER = { "common", "uncommon", "rare", "epic", "legendary" }

-- Helpers --------------------------------------------------------------------

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function deepCopy(v)
    if type(v) ~= "table" then return v end
    local out = {}
    for k, val in pairs(v) do out[k] = deepCopy(val) end
    return out
end

local function isEquippableType(t)
    return t == "weapon" or t == "staff" or t == "shield" or
           t == "armor"  or t == "helmet" or t == "boots" or
           t == "ring"   or t == "amulet"
end

local function isConsumableType(t) return t == "consumable" end

-- Layout ---------------------------------------------------------------------

local CATALOG_W = 280

local function catalogRect()
    local cx, cy, _, ch = Layout.contentRect()
    return cx + 16, cy + 14, CATALOG_W, ch - 30
end

local function formRect()
    local cx, cy, cw, ch = Layout.contentRect()
    local lx, _, lw = catalogRect()
    local x = lx + lw + 14
    return x, cy + 14, cx + cw - x - 16, ch - 30
end

-- Editor state ---------------------------------------------------------------

local function freshDraft()
    return {
        id          = "",
        name        = "Novo Item",
        type        = "weapon",
        stack       = 1,
        rarity      = "common",
        bound       = false,
        sprite      = "icon_sword_iron",
        description = "",
        damage      = 0,
        defense     = 0,
        level_req   = 1,
        value       = 0,
        two_handed  = false,
        attrs       = { str = 0, dex = 0, intel = 0, vit = 0, atk = 0, def = 0 },
        on_use      = { heal_hp = 0, heal_mp = 0 },
    }
end

local function ensureEditorState()
    State.itemEditor.draft         = State.itemEditor.draft or freshDraft()
    State.itemEditor.formScroll    = State.itemEditor.formScroll or 0
    State.itemEditor.catalogScroll = State.itemEditor.catalogScroll or 0
    State.itemEditor.selectedId    = State.itemEditor.selectedId
end

-- Catálogo -------------------------------------------------------------------

local function catalogList()
    local out = {}
    for id, def in pairs(State.itemDefs or {}) do
        out[#out + 1] = { id = id, def = def }
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

local function loadDefIntoDraft(def)
    local d = freshDraft()
    d.id          = def.id   or ""
    d.name        = def.name or d.id
    d.type        = def.type or "material"
    d.stack       = def.stack or 1
    d.rarity      = def.rarity or "common"
    d.bound       = def.bound and true or false
    d.sprite      = def.sprite or Items.defaultFor(d.type)
    d.description = def.description or ""
    d.damage      = def.damage or 0
    d.defense     = def.defense or 0
    d.level_req   = def.level_req or 0
    d.value       = def.value or 0
    d.two_handed  = def.two_handed and true or false
    -- Attrs: copy known keys plus anything custom.
    d.attrs = { str = 0, dex = 0, intel = 0, vit = 0, atk = 0, def = 0 }
    for k, v in pairs(def.attrs or {}) do
        d.attrs[k] = v
    end
    d.on_use = { heal_hp = 0, heal_mp = 0 }
    if def.on_use then
        d.on_use.heal_hp = def.on_use.heal_hp or 0
        d.on_use.heal_mp = def.on_use.heal_mp or 0
    end
    State.itemEditor.draft       = d
    State.itemEditor.selectedId  = d.id
    State.itemEditor.saveStatus  = ""
end

-- Persistence ----------------------------------------------------------------

local function defToWire(d)
    local out = {
        id     = d.id,
        name   = d.name,
        type   = d.type,
        stack  = d.stack,
        rarity = d.rarity,
    }
    if d.bound       then out.bound      = true end
    if d.sprite ~= "" then out.sprite     = d.sprite end
    if d.description ~= "" then out.description = d.description end
    if (d.damage or 0)    > 0 then out.damage    = d.damage end
    if (d.defense or 0)   > 0 then out.defense   = d.defense end
    if (d.level_req or 0) > 0 then out.level_req = d.level_req end
    if (d.value or 0)     > 0 then out.value     = d.value end
    if d.two_handed then out.two_handed = true end
    local attrs = {}
    for k, v in pairs(d.attrs or {}) do
        if v and v ~= 0 then attrs[k] = v end
    end
    if next(attrs) ~= nil then out.attrs = attrs end
    if isConsumableType(d.type) then
        local ou = {}
        if (d.on_use.heal_hp or 0) > 0 then ou.heal_hp = d.on_use.heal_hp end
        if (d.on_use.heal_mp or 0) > 0 then ou.heal_mp = d.on_use.heal_mp end
        if next(ou) ~= nil then out.on_use = ou end
    end
    return out
end

local function saveDraft()
    ensureEditorState()
    local d = State.itemEditor.draft
    if not d.id or d.id == "" then
        State.itemEditor.saveStatus = "id obrigatório"
        return
    end
    if Network.connected and not Network.connected() then
        State.itemEditor.saveStatus = "offline"
        return
    end
    Network.send("SAVE_ITEM_DEF " .. JSON.encode(defToWire(d)))
    State.itemEditor.saveStatus = "item salvo"
    State.itemEditor.selectedId = d.id
end

local function deleteDraft(id)
    if not id or id == "" then return end
    if Network.connected and not Network.connected() then return end
    Network.send("DELETE_ITEM_DEF " .. id)
    if State.itemEditor.selectedId == id then
        State.itemEditor.draft       = freshDraft()
        State.itemEditor.selectedId  = nil
    end
    State.itemEditor.saveStatus = "item excluído"
end

-- Drawing helpers ------------------------------------------------------------

local function drawHeader(row)
    love.graphics.setColor(0.45, 0.78, 1.0, 0.18)
    love.graphics.rectangle("fill", row.x - 6, row.y, row.w + 12, row.h, 4, 4)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.85, 0.95, 1.0)
    love.graphics.print(row.label, row.x, row.y + 4)
end

local function drawTextRow(row, focused)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local tw = row.w - LABEL_W
    love.graphics.setColor(focused and 0.20 or 0.13,
                           focused and 0.27 or 0.16,
                           focused and 0.36 or 0.22)
    love.graphics.rectangle("fill", tx, row.y, tw, row.h, 4, 4)
    love.graphics.setColor(focused and 0.65 or 0.36, 0.55, 0.78)
    love.graphics.rectangle("line", tx, row.y, tw, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    local txt = row.value or ""
    if focused and (math.floor(love.timer.getTime() * 2) % 2) == 0 then
        txt = txt .. "_"
    end
    love.graphics.printf(txt, tx + 6, row.y + 5, tw - 12, "left")
end

local function drawCheckbox(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    love.graphics.setColor(row.value and 0.22 or 0.10,
                           row.value and 0.42 or 0.13,
                           row.value and 0.66 or 0.18)
    love.graphics.rectangle("fill", tx, row.y, 24, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78)
    love.graphics.rectangle("line", tx, row.y, 24, row.h, 4, 4)
    if row.value then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("✓", tx, row.y + 5, 24, "center")
    end
end

local function drawStepperRow(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local btnW = 24
    local fw = row.w - LABEL_W
    love.graphics.setColor(0.13, 0.16, 0.22)
    love.graphics.rectangle("fill", tx, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78)
    love.graphics.rectangle("line", tx, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("−", tx, row.y + 4, btnW, "center")
    love.graphics.setColor(0.10, 0.13, 0.18)
    love.graphics.rectangle("fill", tx + btnW + 2, row.y, fw - btnW * 2 - 4, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78, 0.6)
    love.graphics.rectangle("line", tx + btnW + 2, row.y, fw - btnW * 2 - 4, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(tostring(row.value or 0),
        tx + btnW + 2, row.y + 5, fw - btnW * 2 - 4, "center")
    love.graphics.setColor(0.13, 0.16, 0.22)
    love.graphics.rectangle("fill", tx + fw - btnW, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78)
    love.graphics.rectangle("line", tx + fw - btnW, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("+", tx + fw - btnW, row.y + 4, btnW, "center")
end

local function drawSegRow(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local segW = (row.w - LABEL_W) / #row.options
    for i, opt in ipairs(row.options) do
        local sx = tx + (i - 1) * segW
        local active = opt == row.value
        local hover = pointIn(State.mouse.x or 0, State.mouse.y or 0,
                              sx, row.y, segW, row.h)
        love.graphics.setColor(active and 0.22 or (hover and 0.16 or 0.10),
                               active and 0.42 or (hover and 0.20 or 0.13),
                               active and 0.66 or (hover and 0.28 or 0.20))
        love.graphics.rectangle("fill", sx + 1, row.y, segW - 2, row.h, 4, 4)
        love.graphics.setColor(active and 0.55 or 0.35, 0.60, 0.85, 0.7)
        love.graphics.rectangle("line", sx + 1, row.y, segW - 2, row.h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        local lbl = (row.optionLabels and row.optionLabels[opt]) or opt
        love.graphics.printf(lbl, sx + 1, row.y + 5, segW - 2, "center")
    end
end

local function spritesPerRow(w)
    return math.max(2, math.floor(w / (SPRITE_THUMB + 6)))
end

local function drawSpriteGrid(row, currentSprite)
    local gx, gy, gw, gh = row.x, row.y, row.w, row.h
    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", gx, gy, gw, gh, 4, 4)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.6)
    love.graphics.rectangle("line", gx, gy, gw, gh, 4, 4)

    local ids = Items.allIds()
    local cols = spritesPerRow(gw - 8)
    local cellW = (gw - 8) / cols
    local cellH = SPRITE_THUMB + 18
    love.graphics.setScissor(gx + 4, gy + 4, gw - 8, gh - 8)
    for i, id in ipairs(ids) do
        local col = (i - 1) % cols
        local rrow = math.floor((i - 1) / cols)
        local cx = gx + 4 + col * cellW
        local cy = gy + 4 + rrow * cellH
        local hover = pointIn(State.mouse.x or 0, State.mouse.y or 0,
                              cx, cy, cellW - 4, cellH - 4)
        local active = id == currentSprite
        love.graphics.setColor(active and 0.22 or (hover and 0.18 or 0.10),
                               active and 0.42 or (hover and 0.22 or 0.13),
                               active and 0.66 or (hover and 0.28 or 0.18))
        love.graphics.rectangle("fill", cx + 2, cy + 2, cellW - 6, cellH - 6, 4, 4)
        Items.draw(id, cx + (cellW - SPRITE_THUMB) / 2, cy + 4, SPRITE_THUMB)
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(1, 1, 1, 0.9)
        local label = Items.icons[id] and Items.icons[id].label or id
        love.graphics.printf(label,
            cx + 2, cy + SPRITE_THUMB + 6, cellW - 4, "center")
        if hover then
            Tooltip.hover(string.format("%s\nID: %s\nClique para selecionar.",
                label, id))
        end
    end
    love.graphics.setScissor()
end

-- Form rows ------------------------------------------------------------------

local function buildRows(d, fx, fy, fw)
    local rows = {}
    local y = fy + 12 - State.itemEditor.formScroll

    local function pad(h) y = y + h end
    local function row(t)
        t.x = fx + 14
        t.y = y
        t.w = fw - 28
        t.h = t.h or FIELD_H
        rows[#rows + 1] = t
        y = y + t.h + 6
    end

    row{ kind = "header", label = "Identidade" }
    row{ kind = "text", field = "id",   label = "ID",   value = d.id,
         tip = "Identificador único (a-z, 0-9, _). Usado em loot, quests e EQUIP." }
    row{ kind = "text", field = "name", label = "Nome", value = d.name,
         tip = "Nome de exibição no inventário." }
    row{ kind = "text", field = "description", label = "Descrição",
         value = d.description, h = 44,
         tip = "Texto de tooltip mostrado ao passar o mouse no inventário." }

    pad(4)
    row{ kind = "header", label = "Tipo & raridade" }
    row{ kind = "seg", field = "type", label = "Tipo", value = d.type,
         options = TYPE_ORDER, optionLabels = TYPE_LABELS,
         tip = "O tipo decide o slot de equipamento e o ícone padrão." }
    row{ kind = "seg", field = "rarity", label = "Raridade", value = d.rarity,
         options = RARITY_ORDER, optionLabels = RARITY_LABELS,
         tip = "Raridade pinta a borda do ícone e o nome no inventário." }
    row{ kind = "stepper", field = "stack", label = "Stack", value = d.stack,
         step = 1, min = 1, max = 9999,
         tip = "Quantidade máxima por slot (1 = item único, 99 = potion-like)." }
    row{ kind = "checkbox", field = "bound", label = "Bound on pickup",
         value = d.bound,
         tip = "Bound impede dropar/trocar — usado para itens de quest." }

    pad(4)
    row{ kind = "header", label = "Aparência (sprite)" }
    -- Sprite preview row + picker.
    rows[#rows + 1] = {
        kind = "sprite_preview", x = fx + 14, y = y,
        w = fw - 28, h = SPRITE_THUMB + 4, value = d.sprite,
    }
    y = y + SPRITE_THUMB + 10
    rows[#rows + 1] = {
        kind = "sprite_grid", x = fx + 14, y = y,
        w = fw - 28, h = 220, value = d.sprite,
    }
    y = y + 226

    if isEquippableType(d.type) then
        pad(4)
        row{ kind = "header", label = "Combate" }
        if d.type == "weapon" or d.type == "staff" then
            row{ kind = "stepper", field = "damage", label = "Dano",
                 value = d.damage, step = 1, min = 0, max = 999,
                 tip = "Dano somado ao ataque corpo-a-corpo do jogador." }
            row{ kind = "checkbox", field = "two_handed",
                 label = "Duas mãos", value = d.two_handed,
                 tip = "Ocupa weapon + offhand. Equipar libera o offhand." }
        end
        if d.type == "shield" or d.type == "armor" or d.type == "helmet"
           or d.type == "boots" then
            row{ kind = "stepper", field = "defense", label = "Defesa",
                 value = d.defense, step = 1, min = 0, max = 999,
                 tip = "Defesa subtraída do dano recebido (mínimo 1 sempre)." }
        end
        row{ kind = "stepper", field = "level_req", label = "Nível mínimo",
             value = d.level_req, step = 1, min = 0, max = 99,
             tip = "Nível necessário para equipar. 0 = livre." }
        row{ kind = "stepper", field = "value", label = "Valor (gold)",
             value = d.value, step = 5, min = 0, max = 999999,
             tip = "Valor de venda em gold." }

        pad(4)
        row{ kind = "header", label = "Atributos extras" }
        row{ kind = "stepper", path = "attrs.str", label = "Força (str)",
             value = d.attrs.str, step = 1, min = -20, max = 50 }
        row{ kind = "stepper", path = "attrs.dex", label = "Destreza (dex)",
             value = d.attrs.dex, step = 1, min = -20, max = 50 }
        row{ kind = "stepper", path = "attrs.intel", label = "Inteligência (int)",
             value = d.attrs.intel, step = 1, min = -20, max = 50 }
        row{ kind = "stepper", path = "attrs.vit", label = "Vitalidade (vit)",
             value = d.attrs.vit, step = 1, min = -20, max = 50 }
    end

    if isConsumableType(d.type) then
        pad(4)
        row{ kind = "header", label = "Ao usar (consumível)" }
        row{ kind = "stepper", path = "on_use.heal_hp", label = "Curar HP",
             value = d.on_use.heal_hp, step = 5, min = 0, max = 9999,
             tip = "Quantos pontos de HP recuperar ao consumir." }
        row{ kind = "stepper", path = "on_use.heal_mp", label = "Curar MP",
             value = d.on_use.heal_mp, step = 5, min = 0, max = 9999,
             tip = "Quantos pontos de MP recuperar ao consumir." }
        row{ kind = "stepper", field = "value", label = "Valor (gold)",
             value = d.value, step = 1, min = 0, max = 999999 }
    end

    if not isEquippableType(d.type) and not isConsumableType(d.type) then
        pad(4)
        row{ kind = "header", label = "Comércio" }
        row{ kind = "stepper", field = "value", label = "Valor (gold)",
             value = d.value, step = 1, min = 0, max = 999999,
             tip = "Valor de venda em gold." }
    end

    pad(8)
    rows[#rows + 1] = {
        kind = "button", action = "save",
        label = "Salvar Item (Ctrl+S)", x = fx + 14, y = y,
        w = (fw - 36) / 2, h = 30, color = { 0.20, 0.45, 0.25 },
        tip = "Persiste o item em items_user/<id>.json." }
    rows[#rows + 1] = {
        kind = "button", action = "new",
        label = "+ Novo", x = fx + 14 + (fw - 36) / 2 + 8, y = y,
        w = (fw - 36) / 2, h = 30, color = { 0.20, 0.32, 0.55 },
        tip = "Limpa o formulário para criar outro item." }
    y = y + 36
    rows[#rows + 1] = {
        kind = "button", action = "delete",
        label = "Excluir Item", x = fx + 14, y = y,
        w = fw - 28, h = 26, color = { 0.50, 0.20, 0.20 },
        tip = "Remove o item do catálogo." }
    y = y + 32

    return rows
end

-- Drawing --------------------------------------------------------------------

local function drawCatalog()
    local lx, ly, lw, lh = catalogRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", lx, ly, lw, lh, 6, 6)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.95, 0.97, 1.0)
    love.graphics.print("Catálogo de Itens", lx + 12, ly + 10)

    local btnX, btnY, btnW, btnH = lx + 8, ly + 36, lw - 16, 26
    local hover = pointIn(mx, my, btnX, btnY, btnW, btnH)
    love.graphics.setColor(hover and 0.26 or 0.20, hover and 0.55 or 0.45,
                           hover and 0.32 or 0.25)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4, 4)
    love.graphics.setColor(0.50, 0.7, 0.55)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("+ Novo Item", btnX, btnY + 5, btnW, "center")
    if hover then Tooltip.hover("Limpa o formulário para criar um item do zero.") end

    local list = catalogList()
    local areaY = btnY + btnH + 6
    local areaH = lh - (areaY - ly) - 8
    love.graphics.setScissor(lx + 4, areaY, lw - 8, areaH)
    love.graphics.setFont(State.fonts.name)
    local rowH = 50
    for i, item in ipairs(list) do
        local rx, ry = lx + 8, areaY + (i - 1) * (rowH + 4) - State.itemEditor.catalogScroll
        if ry + rowH >= areaY - 4 and ry <= areaY + areaH then
            local active = item.id == State.itemEditor.selectedId
            local rh = rowH
            local rw = lw - 16
            local rhover = pointIn(mx, my, rx, ry, rw, rh)
            love.graphics.setColor(active and 0.20 or (rhover and 0.16 or 0.11),
                                   active and 0.36 or (rhover and 0.20 or 0.14),
                                   active and 0.60 or (rhover and 0.28 or 0.20))
            love.graphics.rectangle("fill", rx, ry, rw, rh, 4, 4)
            love.graphics.setColor(0.30, 0.42, 0.66, 0.6)
            love.graphics.rectangle("line", rx, ry, rw, rh, 4, 4)

            Items.draw(Items.iconForItem(item.def), rx + 6, ry + 7, 36,
                { rarity = item.def.rarity })

            love.graphics.setFont(State.fonts.ui)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(item.def.name or item.id, rx + 50, ry + 4)
            love.graphics.setFont(State.fonts.name)
            love.graphics.setColor(0.62, 0.74, 0.92)
            local typLbl = TYPE_LABELS[item.def.type or ""] or "?"
            local rarLbl = RARITY_LABELS[item.def.rarity or "common"] or "?"
            love.graphics.print(typLbl .. " · " .. rarLbl, rx + 50, ry + 22)

            local meta = ""
            if (item.def.damage or 0) > 0 then
                meta = "DMG " .. item.def.damage
            end
            if (item.def.defense or 0) > 0 then
                if meta ~= "" then meta = meta .. " · " end
                meta = meta .. "DEF " .. item.def.defense
            end
            if (item.def.on_use and (item.def.on_use.heal_hp or 0) > 0) then
                if meta ~= "" then meta = meta .. " · " end
                meta = meta .. "HP+" .. item.def.on_use.heal_hp
            end
            if meta ~= "" then
                love.graphics.setColor(0.95, 0.85, 0.55)
                love.graphics.print(meta, rx + 50, ry + 36)
            end
        end
    end
    if #list == 0 then
        love.graphics.setColor(0.7, 0.78, 0.92)
        love.graphics.printf("Nenhum item no catálogo.\nClique em \"+ Novo Item\" e salve.",
            lx + 8, areaY + 12, lw - 16, "center")
    end
    love.graphics.setScissor()
end

local function drawButton(row)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local hover = pointIn(mx, my, row.x, row.y, row.w, row.h)
    local c = row.color or { 0.20, 0.32, 0.55 }
    love.graphics.setColor(c[1] * (hover and 1.25 or 1),
                           c[2] * (hover and 1.25 or 1),
                           c[3] * (hover and 1.25 or 1))
    love.graphics.rectangle("fill", row.x, row.y, row.w, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.rectangle("line", row.x, row.y, row.w, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.printf(row.label, row.x,
        row.y + (row.h - State.fonts.ui:getHeight()) / 2, row.w, "center")
    if hover and row.tip then Tooltip.hover(row.tip) end
end

local function drawSpritePreview(row, draft)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print("Ícone atual", row.x, row.y + 10)
    Items.draw(row.value, row.x + LABEL_W, row.y, SPRITE_THUMB,
        { rarity = draft.rarity })
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(row.value or "—",
        row.x + LABEL_W + SPRITE_THUMB + 12, row.y + 10)
end

local function drawForm()
    ensureEditorState()
    local d = State.itemEditor.draft
    local fx, fy, fw, fh = formRect()

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", fx, fy, fw, fh, 6, 6)

    love.graphics.setScissor(fx + 2, fy + 2, fw - 4, fh - 4)
    local rows = buildRows(d, fx, fy, fw)
    for _, r in ipairs(rows) do
        if r.kind == "header" then
            drawHeader(r)
        elseif r.kind == "text" then
            drawTextRow(r, State.editorFocus == r.field)
        elseif r.kind == "checkbox" then
            drawCheckbox(r)
        elseif r.kind == "stepper" then
            drawStepperRow(r)
        elseif r.kind == "seg" then
            drawSegRow(r)
        elseif r.kind == "sprite_preview" then
            drawSpritePreview(r, d)
        elseif r.kind == "sprite_grid" then
            drawSpriteGrid(r, d.sprite)
        elseif r.kind == "button" then
            drawButton(r)
        end
    end
    love.graphics.setScissor()

    if State.itemEditor.saveStatus and State.itemEditor.saveStatus ~= "" then
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(0.95, 0.85, 0.40)
        love.graphics.print("status: " .. State.itemEditor.saveStatus,
            fx + 14, fy + fh - 18)
    end
end

function M.drawContent()
    ensureEditorState()
    drawCatalog()
    drawForm()
end

-- Input ----------------------------------------------------------------------

local function getByPath(d, path)
    local k1, k2 = path:match("^([^.]+)%.([^.]+)$")
    if k1 then return d[k1] and d[k1][k2] end
    return d[path]
end

local function setByPath(d, path, val)
    local k1, k2 = path:match("^([^.]+)%.([^.]+)$")
    if k1 then
        d[k1] = d[k1] or {}
        d[k1][k2] = val
        return
    end
    d[path] = val
end

local function handleStepperClick(d, row, x)
    local tx = row.x + LABEL_W
    local btnW = 24
    local fw = row.w - LABEL_W
    local cur = row.value or 0
    local step = row.step or 1
    local minV = row.min or 0
    local maxV = row.max or 9999
    if x >= tx and x < tx + btnW then
        cur = cur - step
    elseif x >= tx + fw - btnW and x < tx + fw then
        cur = cur + step
    else
        return
    end
    cur = clamp(cur, minV, maxV)
    if row.path then
        setByPath(d, row.path, cur)
    elseif row.field then
        d[row.field] = cur
    end
end

local function handleSegClick(d, row, x)
    local tx = row.x + LABEL_W
    local segW = (row.w - LABEL_W) / #row.options
    local idx = math.floor((x - tx) / segW) + 1
    local opt = row.options[idx]
    if opt then
        d[row.field] = opt
        -- Type change can switch the default sprite if the user never
        -- picked one, so the editor doesn't show a stale weapon icon
        -- for a brand-new shield.
        if row.field == "type" then
            local current = d.sprite or ""
            if current == "" or not Items.icons[current] then
                d.sprite = Items.defaultFor(opt)
            end
        end
    end
end

local function handleSpriteGridClick(d, row, x, y)
    local ids = Items.allIds()
    local cols = spritesPerRow(row.w - 8)
    local cellW = (row.w - 8) / cols
    local cellH = SPRITE_THUMB + 18
    local relX = x - (row.x + 4)
    local relY = y - (row.y + 4)
    if relX < 0 or relY < 0 then return end
    local col = math.floor(relX / cellW)
    local rrow = math.floor(relY / cellH)
    local idx = rrow * cols + col + 1
    local id = ids[idx]
    if id then d.sprite = id end
end

local function formClick(x, y, button)
    button = button or 1
    ensureEditorState()
    local d = State.itemEditor.draft
    local fx, fy, fw, fh = formRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end
    local rows = buildRows(d, fx, fy, fw)
    for _, r in ipairs(rows) do
        if pointIn(x, y, r.x, r.y, r.w, r.h) then
            if r.kind == "text" then
                State.editorFocus = r.field
                return true
            elseif r.kind == "checkbox" then
                d[r.field] = not d[r.field]
                return true
            elseif r.kind == "stepper" then
                handleStepperClick(d, r, x)
                return true
            elseif r.kind == "seg" then
                handleSegClick(d, r, x)
                return true
            elseif r.kind == "sprite_grid" then
                handleSpriteGridClick(d, r, x, y)
                return true
            elseif r.kind == "button" then
                if r.action == "save" then
                    saveDraft()
                elseif r.action == "new" then
                    State.itemEditor.draft       = freshDraft()
                    State.itemEditor.selectedId  = nil
                    State.editorFocus = "id"
                elseif r.action == "delete" then
                    deleteDraft(d.id)
                end
                State.editorFocus = nil
                return true
            end
        end
    end
    State.editorFocus = nil
    return true
end

local function catalogClick(x, y)
    local lx, ly, lw, lh = catalogRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end
    local btnX, btnY, btnW, btnH = lx + 8, ly + 36, lw - 16, 26
    if pointIn(x, y, btnX, btnY, btnW, btnH) then
        State.itemEditor.draft       = freshDraft()
        State.itemEditor.selectedId  = nil
        State.editorFocus = "id"
        State.itemEditor.saveStatus  = ""
        return true
    end
    local list = catalogList()
    local areaY = btnY + btnH + 6
    local rowH = 50
    for i, item in ipairs(list) do
        local rx, ry = lx + 8, areaY + (i - 1) * (rowH + 4) - State.itemEditor.catalogScroll
        if pointIn(x, y, rx, ry, lw - 16, rowH) then
            loadDefIntoDraft(item.def)
            return true
        end
    end
    return true
end

function M.mousepressedContent(x, y, button)
    if catalogClick(x, y) then return true end
    if formClick(x, y, button) then return true end
    return true
end

function M.wheelmoved(_, dy)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    if pointIn(mx, my, formRect()) then
        State.itemEditor.formScroll = math.max(0,
            (State.itemEditor.formScroll or 0) - dy * 30)
        return
    end
    if pointIn(mx, my, catalogRect()) then
        State.itemEditor.catalogScroll = math.max(0,
            (State.itemEditor.catalogScroll or 0) - dy * 30)
    end
end

function M.textinput(t)
    if not State.editorFocus then return false end
    ensureEditorState()
    local d = State.itemEditor.draft
    local f = State.editorFocus
    if f == "id" then
        if #(d.id or "") >= 32 then return true end
        if t:match("[%w_%-]") then d.id = (d.id or "") .. t end
        return true
    elseif f == "name" or f == "description" then
        local cur = d[f] or ""
        local cap = (f == "description") and 256 or 64
        if #cur >= cap then return true end
        if t:match("[%w%s_%-%.,!%?%(%)%/]") then d[f] = cur .. t end
        return true
    end
    return false
end

function M.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    if ctrl and key == "s" then saveDraft(); return true end
    if not State.editorFocus then return false end
    ensureEditorState()
    local d = State.itemEditor.draft
    local f = State.editorFocus
    if key == "backspace" then
        if f == "id" or f == "name" or f == "description" then
            d[f] = (d[f] or ""):sub(1, -2)
            return true
        end
    elseif key == "return" or key == "kpenter" or key == "escape" then
        State.editorFocus = nil
        return true
    end
    return true
end

return M
