-- Aba "Criar NPCs" do editor unificado.
--
-- Layout:
--   esquerda  → catálogo (NPCs já cadastrados; clique seleciona; "+ Novo NPC")
--   centro    → formulário do NPC selecionado (id, nome, papel, facção,
--               sprite, stats, quest, loot, diálogo gerado/customizável)
--   direita   → lista de NPCs *posicionados* no mapa (kind/sprite + remoção)
--
-- Persistência:
--   • A definição do NPC viaja por SAVE_NPC_DEF <json> (servidor escreve
--     em data/scripts/npcs_user/<id>.json e re-broadcasta NPC_DEF).
--   • A *posição* do NPC vai pelo SAVE_MAP existente (campo entities[]
--     com kind = id do NPC, sprite = sprite escolhido).
--
-- O catálogo é recheado pelos NPC_DEF que o servidor envia ao conectar
-- (State.npcDefs); criar/atualizar/excluir é feito *aqui* e os
-- broadcasts mantêm todos os clientes em sincronia.

local State   = require("src.state")
local World   = require("src.world")
local Map     = require("src.map")
local Sprites = require("src.sprites")
local Network = require("src.network")
local JSON    = require("src.json")
local Layout  = require("src.editor_layout")
local Tooltip = require("src.tooltip")
local Pickers = require("src.editor_pickers")
local Items   = require("src.items")

local M = {}

M.panelRect = Layout.panelRect

local FIELD_H = 26

local ROLE_LABELS = {
    friendly    = "Amigo",
    merchant    = "Mercador",
    quest_giver = "Doador de Missão",
    guardian    = "Guardião",
    enemy       = "Inimigo",
}
local ROLE_ORDER = { "friendly", "merchant", "quest_giver", "guardian", "enemy" }

local FACTION_LABELS = {
    ally    = "Aliado",
    neutral = "Neutro",
    hostile = "Hostil",
}
local FACTION_ORDER = { "ally", "neutral", "hostile" }

-- Roles que disparam comportamento de combate. Usado para esconder/exibir
-- campos como HP/dano que só fazem sentido quando o NPC luta.
local function isCombatRole(role)
    return role == "guardian" or role == "enemy"
end

-- ---------------------------------------------------------------------------
-- Helpers --------------------------------------------------------------------
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Layout ---------------------------------------------------------------------
-- ---------------------------------------------------------------------------

local CATALOG_W = 260
local LIST_W    = 280

local function catalogRect()
    local cx, cy, _, ch = Layout.contentRect()
    return cx + 16, cy + 14, CATALOG_W, ch - 30
end

local function formRect()
    local cx, cy, cw, ch = Layout.contentRect()
    local cax, _, caw = catalogRect()
    local x = cax + caw + 14
    local rightW = LIST_W
    return x, cy + 14, cw - (cax - cx) - caw - rightW - 30, ch - 30
end

local function listRect()
    local cx, cy, cw, ch = Layout.contentRect()
    return cx + cw - LIST_W - 16, cy + 14, LIST_W, ch - 30
end

-- ---------------------------------------------------------------------------
-- Editor state ---------------------------------------------------------------
-- ---------------------------------------------------------------------------

-- O draft é o NPC sendo editado. Quando salvamos, viramos o draft em JSON
-- e mandamos pro servidor; ao receber NPC_DEF de volta o catálogo se
-- atualiza sozinho (não reescrevemos draft pra evitar perder edições
-- locais não salvas).
local function freshDraft()
    return {
        id      = "",
        name    = "Novo NPC",
        title   = "",
        role    = "friendly",
        faction = "ally",
        sprite  = State.npcEditor.spriteId or "npc_knight",
        hp      = 0,
        damage  = 0,
        speed   = 1.0,
        aggro   = 4,
        xp      = 0,
        quest   = "",
        loot    = {},          -- list of { item, qty, chance }
        dialog  = nil,         -- nil = backend autogera; lista de nodes opcional
    }
end

local function ensureEditorState()
    State.npcEditor.draft       = State.npcEditor.draft or freshDraft()
    State.npcEditor.selectedId  = State.npcEditor.selectedId  -- id no catálogo
    State.npcEditor.placement   = State.npcEditor.placement
        or { kind = "", sprite = "" }
    State.npcEditor.formScroll  = State.npcEditor.formScroll  or 0
    State.npcEditor.catalogScroll = State.npcEditor.catalogScroll or 0
end

-- ---------------------------------------------------------------------------
-- Persistence ----------------------------------------------------------------
-- ---------------------------------------------------------------------------

local function defToWire(def)
    -- Apenas campos não vazios para manter o JSON pequeno e legível.
    local out = {
        id      = def.id,
        name    = def.name,
        title   = def.title or "",
        role    = def.role,
        faction = def.faction,
    }
    if def.sprite ~= "" then out.sprite = def.sprite end
    if (def.hp or 0) > 0 then out.hp = def.hp end
    if (def.damage or 0) > 0 then out.damage = def.damage end
    if (def.speed or 0) > 0 then out.speed = def.speed end
    if (def.aggro or 0) > 0 then out.aggro = def.aggro end
    if (def.xp or 0) > 0 then out.xp = def.xp end
    if def.quest and def.quest ~= "" then out.quest = def.quest end
    if def.loot and #def.loot > 0 then
        out.loot = {}
        for _, l in ipairs(def.loot) do
            if l.item and l.item ~= "" then
                out.loot[#out.loot + 1] = {
                    item   = l.item,
                    qty    = l.qty or 1,
                    chance = l.chance or 1000,
                }
            end
        end
    end
    if def.dialog and next(def.dialog) ~= nil then
        out.dialog = def.dialog
    end
    return out
end

-- Phase 1 — verifica se cada id referenciado pelo draft existe no
-- catálogo correspondente. Reportar antes de mandar para o servidor
-- evita "quebra silenciosa" descrita no roadmap.
local function validateDraftRefs(d)
    if d.quest and d.quest ~= "" and not (State.questDefs or {})[d.quest] then
        return false, "quest '" .. d.quest .. "' não existe no catálogo"
    end
    for i, l in ipairs(d.loot or {}) do
        if l.item and l.item ~= "" and not (State.itemDefs or {})[l.item] then
            return false, "loot " .. i .. ": item '" .. l.item .. "' não existe"
        end
    end
    return true
end

local function saveDraftToServer()
    ensureEditorState()
    local d = State.npcEditor.draft
    if not d.id or d.id == "" then
        State.npcEditor.saveStatus = "id obrigatório"
        return
    end
    local ok, err = validateDraftRefs(d)
    if not ok then
        State.npcEditor.saveStatus = err
        return
    end
    if Network.connected and not Network.connected() then
        State.npcEditor.saveStatus = "offline"
        return
    end
    local payload = JSON.encode(defToWire(d))
    Network.send("SAVE_NPC_DEF " .. payload)
    State.npcEditor.saveStatus  = "NPC salvo"
    State.npcEditor.selectedId  = d.id
    State.npcEditor.placement.kind = d.id
    State.npcEditor.placement.sprite = d.sprite
end

local function deleteCatalogId(id)
    if not id or id == "" then return end
    if Network.connected and not Network.connected() then return end
    Network.send("DELETE_NPC_DEF " .. id)
    if State.npcEditor.selectedId == id then
        State.npcEditor.selectedId = nil
        State.npcEditor.draft = freshDraft()
    end
    State.npcEditor.saveStatus = "NPC removido"
end

local function saveMapToServer()
    if not Map.current then return end
    if Network.connected and not Network.connected() then
        State.npcEditor.saveStatus = "offline (mapa)"
        return
    end
    local payload = JSON.encode(Map.current)
    Network.send("SAVE_MAP " .. payload)
    State.npcEditor.saveStatus = "mapa salvo"
end

-- ---------------------------------------------------------------------------
-- Catalog (left column) ------------------------------------------------------
-- ---------------------------------------------------------------------------

-- Lista ordenada de IDs no catálogo (State.npcDefs é um dict).
local function catalogList()
    local out = {}
    for id, def in pairs(State.npcDefs or {}) do
        out[#out + 1] = { id = id, def = def }
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

local function loadDefIntoDraft(def)
    -- Copia os campos conhecidos de `def` (vindo do servidor) para o draft.
    local d = freshDraft()
    d.id      = def.id      or ""
    d.name    = def.name    or d.id
    d.title   = def.title   or ""
    d.role    = def.role    or "friendly"
    d.faction = def.faction or "ally"
    d.sprite  = def.sprite  or "npc_knight"
    d.hp      = def.hp      or 0
    d.damage  = def.damage  or 0
    d.speed   = def.speed   or 1
    d.aggro   = def.aggro   or 4
    d.xp      = def.xp      or 0
    d.quest   = def.quest   or ""
    d.loot    = deepCopy(def.loot) or {}
    -- O servidor não envia o dialog inteiro pelo NPC_DEF (só meta-dados);
    -- mantemos nil para que o backend continue usando os nodes salvos
    -- em disco. Editar o diálogo só faz sentido criando do zero.
    d.dialog  = nil
    State.npcEditor.draft = d
    State.npcEditor.selectedId = d.id
    State.npcEditor.placement.kind   = d.id
    State.npcEditor.placement.sprite = d.sprite
    State.npcEditor.saveStatus = ""
end

-- ---------------------------------------------------------------------------
-- Form rows ------------------------------------------------------------------
-- ---------------------------------------------------------------------------

local function buildRows(d, fx, fy, fw)
    local rows = {}
    local y = fy + 12 - State.npcEditor.formScroll

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
    row{ kind = "text", field = "id", label = "ID", value = d.id,
         tip = "Identificador único (a-z, 0-9, _). Usado em SAVE_MAP e em scripts." }
    row{ kind = "text", field = "name", label = "Nome", value = d.name,
         tip = "Nome de exibição mostrado acima do NPC." }
    row{ kind = "text", field = "title", label = "Título", value = d.title,
         tip = "Sub-título mostrado abaixo do nome (ex.: 'Guarda da Vila')." }

    pad(4)
    row{ kind = "header", label = "Papel & facção" }
    row{ kind = "toggle", field = "role", label = "Papel",
         value = d.role, options = ROLE_ORDER, optionLabels = ROLE_LABELS,
         tip  = "amigo/mercador/dom missão são pacíficos; guardião e inimigo lutam." }
    row{ kind = "toggle", field = "faction", label = "Facção",
         value = d.faction, options = FACTION_ORDER, optionLabels = FACTION_LABELS,
         tip = "ally nunca ataca; hostile sempre; neutro só em retaliação." }

    pad(4)
    row{ kind = "header", label = "Aparência" }
    row{ kind = "sprite", field = "sprite", label = "Sprite",
         value = d.sprite,
         tip = "Use o picker no clique abaixo para escolher um sprite." }
    -- Mini sprite picker — três colunas.
    local pickerH = 132
    rows[#rows + 1] = {
        kind = "sprite_grid", x = fx + 14, y = y,
        w = fw - 28, h = pickerH, value = d.sprite,
        tip = "Clique numa célula para selecionar o sprite que aparece no mundo.",
    }
    y = y + pickerH + 6

    if isCombatRole(d.role) then
        pad(4)
        row{ kind = "header", label = "Combate" }
        row{ kind = "stepper", field = "hp",     label = "HP",      value = d.hp,
             step = 5, min = 1, max = 9999,
             tip = "HP máximo. 0 ignora — papel de combate exige HP > 0." }
        row{ kind = "stepper", field = "damage", label = "Dano",    value = d.damage,
             step = 1, min = 0, max = 999,
             tip = "Dano por ataque corpo-a-corpo." }
        row{ kind = "stepper", field = "aggro",  label = "Aggro",   value = d.aggro,
             step = 1, min = 0, max = 20,
             tip = "Raio (em tiles) de detecção do alvo. Guardião só ataca dentro disso." }
        row{ kind = "stepper", field = "xp",     label = "XP ao morrer", value = d.xp,
             step = 5, min = 0, max = 9999,
             tip = "Experiência concedida ao jogador que matar este NPC." }
    end

    if d.role == "quest_giver" or d.role == "guardian" or d.role == "friendly" then
        pad(4)
        row{ kind = "header", label = "Missão" }
        row{ kind = "id_picker", field = "quest", pickerKind = "quest",
             label = "Missão", value = d.quest,
             tip = "Clique para escolher a quest. Vazio = sem missão; diálogo padrão é gerado automaticamente." }
    end

    if isCombatRole(d.role) then
        pad(4)
        row{ kind = "header", label = "Loot ao morrer" }
        for i, l in ipairs(d.loot) do
            row{ kind = "loot_row", index = i, value = l,
                 tip = "Item dropado na morte (chance em milésimos: 1000 = 100%)." }
        end
        row{ kind = "button", action = "add_loot", label = "+ Adicionar loot",
             color = { 0.20, 0.45, 0.25 }, h = 26,
             tip = "Adiciona um novo entry ao loot." }
    end

    pad(8)
    row{ kind = "header", label = "Ações" }
    rows[#rows + 1] = {
        kind = "button", action = "save_def", label = "Salvar NPC (Ctrl+S)",
        x = fx + 14, y = y, w = (fw - 36) / 2, h = 30,
        color = { 0.20, 0.45, 0.25 },
        tip = "Persiste a definição do NPC em data/scripts/npcs_user/<id>.json." }
    rows[#rows + 1] = {
        kind = "button", action = "new_npc", label = "+ Novo",
        x = fx + 14 + (fw - 36) / 2 + 8, y = y, w = (fw - 36) / 2, h = 30,
        color = { 0.20, 0.32, 0.55 },
        tip = "Limpa o formulário para criar outro NPC." }
    y = y + 36
    rows[#rows + 1] = {
        kind = "button", action = "delete_def",
        label = "Excluir NPC", x = fx + 14, y = y,
        w = fw - 28, h = 26, color = { 0.50, 0.20, 0.20 },
        tip = "Remove o NPC do catálogo (não toca posições já no mapa)." }
    y = y + 32

    rows[#rows + 1] = {
        kind = "button", action = "save_map",
        label = "Salvar Mapa", x = fx + 14, y = y,
        w = fw - 28, h = 28, color = { 0.36, 0.34, 0.18 },
        tip = "Persiste posições de NPCs no mapa via SAVE_MAP." }
    y = y + 34

    return rows, y
end

-- ---------------------------------------------------------------------------
-- Drawing helpers ------------------------------------------------------------
-- ---------------------------------------------------------------------------

local SPRITE_THUMB = 36

local function drawSpriteThumb(sprite, x, y, size)
    if not sprite then
        love.graphics.setColor(0.30, 0.32, 0.38)
        love.graphics.rectangle("fill", x, y, size, size, 4, 4)
        return
    end
    local img, quad, fw, fh = Sprites.frame(sprite.animName, love.timer.getTime())
    if not img then
        love.graphics.setColor(0.40, 0.30, 0.34)
        love.graphics.rectangle("fill", x, y, size, size, 4, 4)
        return
    end
    local scale = math.min((size - 4) / fw, (size - 4) / fh) * 1.4
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, quad,
        x + size / 2, y + size - 2,
        0, scale, scale, fw / 2, fh)
end

local function drawCatalog()
    local lx, ly, lw, lh = catalogRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", lx, ly, lw, lh, 6, 6)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.95, 0.97, 1.0)
    love.graphics.print("Catálogo de NPCs", lx + 12, ly + 10)

    -- Botão "+ Novo".
    local btnX, btnY, btnW, btnH = lx + 8, ly + 36, lw - 16, 26
    local hover = pointIn(mx, my, btnX, btnY, btnW, btnH)
    love.graphics.setColor(hover and 0.26 or 0.20, hover and 0.55 or 0.45,
                           hover and 0.32 or 0.25)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4, 4)
    love.graphics.setColor(0.50, 0.7, 0.55)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4, 4)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("+ Novo NPC", btnX, btnY + 5, btnW, "center")
    if hover then
        Tooltip.hover("Limpa o formulário e começa um NPC do zero.")
    end

    local list = catalogList()
    local areaY = btnY + btnH + 6
    local areaH = lh - (areaY - ly) - 8
    love.graphics.setScissor(lx + 4, areaY, lw - 8, areaH)
    love.graphics.setFont(State.fonts.name)
    local rowH = 50
    for i, item in ipairs(list) do
        local rx = lx + 8
        local ry = areaY + (i - 1) * (rowH + 4) - State.npcEditor.catalogScroll
        if ry + rowH >= areaY - 4 and ry <= areaY + areaH then
            local active = item.id == State.npcEditor.selectedId
            local rh = rowH
            local rw = lw - 16
            local rhover = pointIn(mx, my, rx, ry, rw, rh)
            love.graphics.setColor(active and 0.20 or (rhover and 0.16 or 0.11),
                                   active and 0.36 or (rhover and 0.20 or 0.14),
                                   active and 0.60 or (rhover and 0.28 or 0.20))
            love.graphics.rectangle("fill", rx, ry, rw, rh, 4, 4)
            love.graphics.setColor(0.30, 0.42, 0.66, 0.6)
            love.graphics.rectangle("line", rx, ry, rw, rh, 4, 4)

            local sp = item.def.sprite and Sprites.npcSprite(item.def.sprite) or nil
            drawSpriteThumb(sp, rx + 4, ry + 4, rh - 8)

            love.graphics.setFont(State.fonts.ui)
            love.graphics.setColor(1, 1, 1)
            local nm = item.def.name or item.id
            love.graphics.print(nm, rx + rh, ry + 4)
            love.graphics.setFont(State.fonts.name)
            love.graphics.setColor(0.62, 0.74, 0.92)
            local roleLbl = ROLE_LABELS[item.def.role or "friendly"] or "?"
            local factLbl = FACTION_LABELS[item.def.faction or "ally"] or "?"
            love.graphics.print(roleLbl .. " · " .. factLbl, rx + rh, ry + 22)
            if item.def.quest and item.def.quest ~= "" then
                love.graphics.setColor(1.0, 0.85, 0.4)
                love.graphics.print("⚔ " .. item.def.quest, rx + rh, ry + 36)
            elseif (item.def.hp or 0) > 0 then
                love.graphics.setColor(0.95, 0.5, 0.5)
                love.graphics.print(string.format("HP %d · DMG %d",
                    item.def.hp, item.def.damage or 0), rx + rh, ry + 36)
            end
        end
    end
    if #list == 0 then
        love.graphics.setColor(0.7, 0.78, 0.92)
        love.graphics.printf("Nenhum NPC no catálogo.\nClique em \"+ Novo NPC\" e salve para criar.",
            lx + 8, areaY + 12, lw - 16, "center")
    end
    love.graphics.setScissor()
end

local function spritesPerRow(w)
    return math.max(2, math.floor(w / (SPRITE_THUMB + 6)))
end

-- Desenha o picker de sprites, mostrando a célula que casa com d.sprite
-- selecionada. Retorna o retângulo do grid pra hit-test.
local function drawSpriteGrid(row, currentSprite)
    local gx, gy, gw, gh = row.x, row.y, row.w, row.h
    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", gx, gy, gw, gh, 4, 4)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.6)
    love.graphics.rectangle("line", gx, gy, gw, gh, 4, 4)

    local cols = spritesPerRow(gw - 8)
    local cellW = (gw - 8) / cols
    local cellH = SPRITE_THUMB + 18
    love.graphics.setScissor(gx + 4, gy + 4, gw - 8, gh - 8)
    for i, sp in ipairs(Sprites.npcSprites) do
        local col = (i - 1) % cols
        local rrow = math.floor((i - 1) / cols)
        local cx = gx + 4 + col * cellW
        local cy = gy + 4 + rrow * cellH
        local hover = pointIn(State.mouse.x or 0, State.mouse.y or 0,
                              cx, cy, cellW - 4, cellH - 4)
        local active = sp.id == currentSprite
        love.graphics.setColor(active and 0.22 or (hover and 0.18 or 0.10),
                               active and 0.42 or (hover and 0.22 or 0.13),
                               active and 0.66 or (hover and 0.28 or 0.18))
        love.graphics.rectangle("fill", cx + 2, cy + 2, cellW - 6, cellH - 6, 4, 4)
        drawSpriteThumb(sp, cx + (cellW - SPRITE_THUMB) / 2, cy + 4, SPRITE_THUMB)
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf(sp.label or sp.id,
            cx + 2, cy + SPRITE_THUMB + 6, cellW - 4, "center")
        if hover then
            Tooltip.hover(string.format("%s\nID: %s\nClique para selecionar.",
                sp.label or sp.id, sp.id))
        end
    end
    love.graphics.setScissor()
end

local LABEL_W = 110

local function drawTextRow(row, focused)
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
    love.graphics.print(txt, tx + 6, row.y + 5)
end

local function drawToggleRow(row)
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
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(1, 1, 1)
        local lbl = (row.optionLabels and row.optionLabels[opt]) or opt
        love.graphics.printf(lbl, sx + 1, row.y + 5, segW - 2, "center")
    end
end

local function drawStepperRow(row)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local btnW = 24
    local fw = row.w - LABEL_W
    -- ←
    love.graphics.setColor(0.13, 0.16, 0.22)
    love.graphics.rectangle("fill", tx, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78)
    love.graphics.rectangle("line", tx, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("−", tx, row.y + 4, btnW, "center")
    -- valor
    love.graphics.setColor(0.10, 0.13, 0.18)
    love.graphics.rectangle("fill", tx + btnW + 2, row.y, fw - btnW * 2 - 4, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78, 0.6)
    love.graphics.rectangle("line", tx + btnW + 2, row.y, fw - btnW * 2 - 4, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(tostring(row.value or 0),
        tx + btnW + 2, row.y + 5, fw - btnW * 2 - 4, "center")
    -- →
    love.graphics.setColor(0.13, 0.16, 0.22)
    love.graphics.rectangle("fill", tx + fw - btnW, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78)
    love.graphics.rectangle("line", tx + fw - btnW, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("+", tx + fw - btnW, row.y + 4, btnW, "center")
end

local function drawLootRow(row)
    local l = row.value
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print("loot " .. row.index, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local fw = row.w - LABEL_W
    -- Item picker: ícone + id (clicável). Ícone à esquerda, label/id à direita.
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local pickerW = fw - 130
    local hover = pointIn(mx, my, tx, row.y, pickerW, row.h)
    local missing = l.item and l.item ~= "" and not (State.itemDefs or {})[l.item]
    love.graphics.setColor(hover and 0.18 or 0.13,
                           hover and 0.22 or 0.16,
                           hover and 0.30 or 0.22)
    love.graphics.rectangle("fill", tx, row.y, pickerW, row.h, 4, 4)
    if missing then
        love.graphics.setColor(0.95, 0.40, 0.40)
    else
        love.graphics.setColor(0.4, 0.55, 0.78)
    end
    love.graphics.rectangle("line", tx, row.y, pickerW, row.h, 4, 4)
    if l.item and l.item ~= "" then
        local def = (State.itemDefs or {})[l.item]
        local iconId = def and Items.iconForItem(def) or Items.defaultFor("material")
        Items.draw(iconId, tx + 2, row.y + 1, row.h - 2,
            { rarity = def and def.rarity or nil })
        love.graphics.setColor(1, 1, 1)
        local label = (def and def.name) or l.item
        love.graphics.print(label, tx + row.h + 4, row.y + 5)
    else
        love.graphics.setColor(0.65, 0.78, 0.92, 0.7)
        love.graphics.print("Clique para escolher item...", tx + 6, row.y + 5)
    end
    if hover then
        Tooltip.hover("Clique para abrir o picker de itens.")
    end

    -- qty stepper
    love.graphics.setColor(0.10, 0.13, 0.18)
    love.graphics.rectangle("fill", tx + fw - 122, row.y, 56, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78, 0.6)
    love.graphics.rectangle("line", tx + fw - 122, row.y, 56, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("qty " .. (l.qty or 1),
        tx + fw - 122, row.y + 5, 56, "center")
    -- chance stepper
    love.graphics.setColor(0.10, 0.13, 0.18)
    love.graphics.rectangle("fill", tx + fw - 60, row.y, 60, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78, 0.6)
    love.graphics.rectangle("line", tx + fw - 60, row.y, 60, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf((l.chance or 1000) .. "‰",
        tx + fw - 60, row.y + 5, 60, "center")
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
    love.graphics.printf(row.label, row.x, row.y + (row.h - State.fonts.ui:getHeight()) / 2,
        row.w, "center")
    if hover and row.tip then Tooltip.hover(row.tip) end
end

local function drawHeader(row)
    love.graphics.setColor(0.45, 0.78, 1.0, 0.18)
    love.graphics.rectangle("fill", row.x - 6, row.y, row.w + 12, row.h, 4, 4)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.85, 0.95, 1.0)
    love.graphics.print(row.label, row.x, row.y + 4)
end

-- Phase 1 — desenho do row "id_picker": label à esquerda, área clicável
-- com o id atual à direita (ou placeholder). Borda fica vermelha quando o
-- id atual não existe mais no catálogo correspondente, sinalizando que o
-- usuário precisa abrir o picker e escolher de novo.
local function drawIdPickerRow(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local tw = row.w - LABEL_W
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local hover = pointIn(mx, my, tx, row.y, tw, row.h)

    local catalog = nil
    if row.pickerKind == "quest" then catalog = State.questDefs
    elseif row.pickerKind == "item" then catalog = State.itemDefs
    elseif row.pickerKind == "npc"  then catalog = State.npcDefs
    end
    local missing = row.value and row.value ~= ""
        and catalog and not catalog[row.value]

    love.graphics.setColor(hover and 0.18 or 0.13,
                           hover and 0.22 or 0.16,
                           hover and 0.30 or 0.22)
    love.graphics.rectangle("fill", tx, row.y, tw, row.h, 4, 4)
    if missing then
        love.graphics.setColor(0.95, 0.40, 0.40)
    else
        love.graphics.setColor(0.4, 0.55, 0.78)
    end
    love.graphics.rectangle("line", tx, row.y, tw, row.h, 4, 4)

    love.graphics.setColor(1, 1, 1)
    if row.value and row.value ~= "" then
        local def = catalog and catalog[row.value]
        local label = (def and def.name) or row.value
        love.graphics.print(label, tx + 6, row.y + 5)
        if def and def.name then
            love.graphics.setColor(0.55, 0.70, 0.92)
            love.graphics.printf("[" .. row.value .. "]",
                tx + 6, row.y + 5, tw - 12, "right")
        end
    else
        love.graphics.setColor(0.65, 0.78, 0.92, 0.7)
        love.graphics.print("Clique para escolher...", tx + 6, row.y + 5)
    end

    if hover then
        local kindLbl = row.pickerKind == "quest" and "quest" or
                        row.pickerKind == "item"  and "item"  or "NPC"
        local tip = "Clique para abrir o picker de " .. kindLbl .. "."
        if missing then tip = tip .. "\n⚠ id atual não existe mais." end
        Tooltip.hover(tip)
    end
end

local function drawForm()
    ensureEditorState()
    local d = State.npcEditor.draft
    local fx, fy, fw, fh = formRect()

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", fx, fy, fw, fh, 6, 6)

    love.graphics.setScissor(fx + 2, fy + 2, fw - 4, fh - 4)

    local rows = buildRows(d, fx, fy, fw)
    love.graphics.setFont(State.fonts.name)
    for _, r in ipairs(rows) do
        if r.kind == "header" then
            drawHeader(r)
        elseif r.kind == "text" then
            drawTextRow(r, State.editorFocus == r.field)
        elseif r.kind == "toggle" then
            drawToggleRow(r)
        elseif r.kind == "stepper" then
            drawStepperRow(r)
        elseif r.kind == "sprite" then
            -- Sprite atual com label.
            love.graphics.setColor(0.7, 0.78, 0.92)
            love.graphics.print(r.label, r.x, r.y + 5)
            local sp = Sprites.npcSprite(r.value)
            drawSpriteThumb(sp, r.x + LABEL_W, r.y - 4, r.h + 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(r.value or "—", r.x + LABEL_W + r.h + 24, r.y + 5)
        elseif r.kind == "sprite_grid" then
            drawSpriteGrid(r, d.sprite)
        elseif r.kind == "loot_row" then
            drawLootRow(r)
        elseif r.kind == "id_picker" then
            drawIdPickerRow(r)
        elseif r.kind == "button" then
            drawButton(r)
        end
    end

    love.graphics.setScissor()

    -- Status string (canto inferior).
    if State.npcEditor.saveStatus and State.npcEditor.saveStatus ~= "" then
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(0.95, 0.85, 0.40)
        love.graphics.print("status: " .. State.npcEditor.saveStatus,
            fx + 14, fy + fh - 18)
    end
end

-- ---------------------------------------------------------------------------
-- Right-column placement list ------------------------------------------------
-- ---------------------------------------------------------------------------

local function placedNPCs()
    local m = Map.current
    if not m or not m.entities then return {} end
    local out = {}
    for i, e in ipairs(m.entities) do
        if e.type == "npc" then
            out[#out + 1] = { idx = i, entity = e }
        end
    end
    return out
end

local function drawList()
    local lx, ly, lw, lh = listRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10, 0.96)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 6, 6)
    love.graphics.setColor(0.30, 0.42, 0.66, 0.85)
    love.graphics.rectangle("line", lx, ly, lw, lh, 6, 6)

    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.95, 0.97, 1.0)
    love.graphics.print("NPCs no Mapa", lx + 12, ly + 10)

    -- Hint do NPC que será posicionado.
    love.graphics.setFont(State.fonts.name)
    local kind = State.npcEditor.placement.kind or ""
    if kind == "" then
        love.graphics.setColor(0.85, 0.5, 0.5)
        love.graphics.print("nenhum NPC pronto pra colocar", lx + 12, ly + 32)
    else
        love.graphics.setColor(0.55, 0.85, 0.6)
        love.graphics.print("clicar no mundo coloca: " .. kind, lx + 12, ly + 32)
    end

    local list = placedNPCs()
    local rowH = 42
    local areaY = ly + 56
    local areaH = lh - (areaY - ly) - 6
    love.graphics.setScissor(lx + 4, areaY, lw - 8, areaH)
    for i, item in ipairs(list) do
        local rx = lx + 8
        local ry = areaY + (i - 1) * (rowH + 4)
        local rw = lw - 16
        local rh = rowH
        local hover = pointIn(mx, my, rx, ry, rw, rh)
        love.graphics.setColor(hover and 0.16 or 0.11, hover and 0.20 or 0.14,
                               hover and 0.28 or 0.20)
        love.graphics.rectangle("fill", rx, ry, rw, rh, 4, 4)
        love.graphics.setColor(0.30, 0.42, 0.66, 0.5)
        love.graphics.rectangle("line", rx, ry, rw, rh, 4, 4)
        local sp = item.entity.sprite and Sprites.npcSprite(item.entity.sprite) or nil
        drawSpriteThumb(sp, rx + 4, ry + 4, rh - 8)
        love.graphics.setFont(State.fonts.ui)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(item.entity.kind or "?", rx + rh, ry + 4)
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(0.65, 0.74, 0.88)
        love.graphics.print(string.format("(%d, %d)",
            item.entity.x, item.entity.y), rx + rh, ry + 22)

        local delX = rx + rw - 28
        local delY = ry + (rh - 22) / 2
        local delHover = pointIn(mx, my, delX, delY, 24, 22)
        love.graphics.setColor(delHover and 0.85 or 0.45,
                               delHover and 0.30 or 0.18,
                               delHover and 0.30 or 0.22)
        love.graphics.rectangle("fill", delX, delY, 24, 22, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(State.fonts.ui)
        love.graphics.printf("✕", delX, delY + 1, 24, "center")
    end
    if #list == 0 then
        love.graphics.setColor(0.7, 0.78, 0.92)
        love.graphics.printf("Nenhum NPC posicionado.\nClique no mundo para colocar.",
            lx + 8, areaY + 12, lw - 16, "center")
    end
    love.graphics.setScissor()
end

function M.drawContent()
    ensureEditorState()
    drawCatalog()
    drawForm()
    drawList()
end

-- ---------------------------------------------------------------------------
-- World cursor preview -------------------------------------------------------
-- ---------------------------------------------------------------------------

local function ensureCursorTile(sx, sy)
    local wx = sx + State.camera.x
    local wy = sy + State.camera.y
    local tx = math.floor(wx / World.TILE_W) + 1
    local ty = math.floor(wy / World.TILE_H) + 1
    return tx, ty
end

function M.drawCursor()
    if State.editorTab ~= "npcs" or not State.editorOpen then return end
    if not Map.current then return end
    ensureEditorState()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local px, py, pw, ph = Layout.panelRect()
    if pointIn(mx, my, px, py, pw, ph) then return end

    local tx, ty = ensureCursorTile(mx, my)
    if not Map.inBounds(tx, ty) then return end

    local sx = (tx - 1) * World.TILE_W - State.camera.x
    local sy = (ty - 1) * World.TILE_H - State.camera.y

    love.graphics.setColor(0.45, 0.78, 1.0, 0.85)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", sx, sy, World.TILE_W, World.TILE_H, 2, 2)
    love.graphics.setLineWidth(1)

    local sprite = Sprites.npcSprite(State.npcEditor.placement.sprite or "")
    if sprite then
        local img, quad, fw, fh = Sprites.frame(sprite.animName, love.timer.getTime())
        if img then
            love.graphics.setColor(1, 1, 1, 0.55)
            love.graphics.draw(img, quad,
                sx + World.TILE_W / 2, sy + World.TILE_H + 2,
                0, 1.4, 1.4, fw / 2, fh)
        end
    end

    love.graphics.setFont(State.fonts.name)
    local kind = State.npcEditor.placement.kind or "?"
    local label = string.format("%s @ (%d,%d)", kind, tx - 1, ty - 1)
    local lw = State.fonts.name:getWidth(label) + 8
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", mx + 14, my + 14, lw, 18, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label, mx + 18, my + 16)
end

-- ---------------------------------------------------------------------------
-- World click ----------------------------------------------------------------
-- ---------------------------------------------------------------------------

function M.worldClick(sx, sy, button)
    if not Map.current then return end
    ensureEditorState()
    local tx, ty = ensureCursorTile(sx, sy)
    if not Map.inBounds(tx, ty) then return end
    button = button or 1

    if button == 2 then
        for i = #Map.current.entities, 1, -1 do
            local e = Map.current.entities[i]
            if e.type == "npc" and e.x == tx - 1 and e.y == ty - 1 then
                table.remove(Map.current.entities, i)
                return
            end
        end
        return
    end

    local kind = State.npcEditor.placement.kind or ""
    if kind == "" then
        State.npcEditor.saveStatus = "salve um NPC antes de posicionar"
        return
    end
    Map.current.entities[#Map.current.entities + 1] = {
        type   = "npc",
        kind   = kind,
        sprite = State.npcEditor.placement.sprite ~= "" and
                 State.npcEditor.placement.sprite or nil,
        x      = tx - 1,
        y      = ty - 1,
    }
    State.npcEditor.saveStatus = "posicionado — não esqueça de salvar mapa"
end

-- ---------------------------------------------------------------------------
-- Input dispatch -------------------------------------------------------------
-- ---------------------------------------------------------------------------

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
    if row.field then d[row.field] = cur end
end

local function handleToggleClick(d, row, x)
    local tx = row.x + LABEL_W
    local segW = (row.w - LABEL_W) / #row.options
    local idx = math.floor((x - tx) / segW) + 1
    local opt = row.options[idx]
    if opt then d[row.field] = opt end
end

local function handleSpriteGridClick(d, row, x, y)
    local cols = spritesPerRow(row.w - 8)
    local cellW = (row.w - 8) / cols
    local cellH = SPRITE_THUMB + 18
    local relX = x - (row.x + 4)
    local relY = y - (row.y + 4)
    if relX < 0 or relY < 0 then return end
    local col = math.floor(relX / cellW)
    local rrow = math.floor(relY / cellH)
    local idx = rrow * cols + col + 1
    local sp = Sprites.npcSprites[idx]
    if sp then
        d.sprite = sp.id
        State.npcEditor.placement.sprite = sp.id
    end
end

local function handleLootClick(d, row, x)
    local tx = row.x + LABEL_W
    local fw = row.w - LABEL_W
    local l = row.value
    if x < tx + (fw - 130) then
        -- Phase 1 — abre o picker de itens em vez de focar text input.
        local lootIdx = row.index
        Pickers.openItem(l.item, function(id)
            d.loot[lootIdx].item = id or ""
        end)
        State.editorFocus = nil
        return
    end
    local qtyX = tx + fw - 122
    if x >= qtyX and x < qtyX + 56 then
        l.qty = (l.qty or 1) + 1
        if l.qty > 99 then l.qty = 1 end
        return
    end
    local chanceX = tx + fw - 60
    if x >= chanceX and x < chanceX + 60 then
        l.chance = (l.chance or 1000) + 100
        if l.chance > 1000 then l.chance = 100 end
        return
    end
end

-- Phase 1 — abre o picker apropriado pra um id_picker row, e gravar o
-- id escolhido no campo correspondente do draft.
local function handleIdPickerClick(d, row)
    local field = row.field
    local cb = function(id)
        d[field] = id or ""
    end
    if row.pickerKind == "quest" then
        Pickers.openQuest(d[field], cb)
    elseif row.pickerKind == "item" then
        Pickers.openItem(d[field], cb)
    elseif row.pickerKind == "npc" then
        Pickers.openNPC(row.filter, d[field], cb)
    end
    State.editorFocus = nil
end

local function formClick(x, y, button)
    button = button or 1
    ensureEditorState()
    local d = State.npcEditor.draft
    local fx, fy, fw, fh = formRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end
    local rows = buildRows(d, fx, fy, fw)
    for _, r in ipairs(rows) do
        if pointIn(x, y, r.x, r.y, r.w, r.h) then
            if r.kind == "text" then
                State.editorFocus = r.field
                return true
            elseif r.kind == "stepper" then
                handleStepperClick(d, r, x)
                return true
            elseif r.kind == "toggle" then
                handleToggleClick(d, r, x)
                return true
            elseif r.kind == "sprite_grid" then
                handleSpriteGridClick(d, r, x, y)
                return true
            elseif r.kind == "loot_row" then
                handleLootClick(d, r, x)
                return true
            elseif r.kind == "id_picker" then
                handleIdPickerClick(d, r)
                return true
            elseif r.kind == "button" then
                if r.action == "save_def" then
                    saveDraftToServer()
                elseif r.action == "new_npc" then
                    State.npcEditor.draft = freshDraft()
                    State.npcEditor.selectedId = nil
                    State.editorFocus = nil
                elseif r.action == "delete_def" then
                    deleteCatalogId(d.id)
                elseif r.action == "save_map" then
                    saveMapToServer()
                elseif r.action == "add_loot" then
                    d.loot[#d.loot + 1] = { item = "", qty = 1, chance = 1000 }
                end
                State.editorFocus = nil
                return true
            end
        end
    end
    -- Click "vazio" no form: tira foco, absorve.
    State.editorFocus = nil
    return true
end

local function catalogClick(x, y)
    local lx, ly, lw, lh = catalogRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end
    -- Botão "+ Novo NPC".
    local btnX, btnY, btnW, btnH = lx + 8, ly + 36, lw - 16, 26
    if pointIn(x, y, btnX, btnY, btnW, btnH) then
        State.npcEditor.draft = freshDraft()
        State.npcEditor.selectedId = nil
        State.editorFocus = "id"
        State.npcEditor.saveStatus = ""
        return true
    end
    -- Linhas do catálogo.
    local list = catalogList()
    local areaY = btnY + btnH + 6
    local rowH = 50
    for i, item in ipairs(list) do
        local rx = lx + 8
        local ry = areaY + (i - 1) * (rowH + 4) - State.npcEditor.catalogScroll
        if pointIn(x, y, rx, ry, lw - 16, rowH) then
            loadDefIntoDraft(item.def)
            return true
        end
    end
    return true
end

local function listClick(x, y)
    local lx, ly, lw, lh = listRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end
    local list = placedNPCs()
    local rowH = 42
    local areaY = ly + 56
    for i, item in ipairs(list) do
        local rx = lx + 8
        local ry = areaY + (i - 1) * (rowH + 4)
        local delX = rx + (lw - 16) - 28
        local delY = ry + (rowH - 22) / 2
        if pointIn(x, y, delX, delY, 24, 22) then
            table.remove(Map.current.entities, item.idx)
            return true
        end
    end
    return true
end

function M.mousepressedContent(x, y, button)
    button = button or 1
    if catalogClick(x, y) then return true end
    if listClick(x, y) then return true end
    if formClick(x, y, button) then return true end
    return true
end

function M.wheelmoved(_, dy)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    if pointIn(mx, my, formRect()) then
        State.npcEditor.formScroll = math.max(0,
            (State.npcEditor.formScroll or 0) - dy * 30)
        return
    end
    if pointIn(mx, my, catalogRect()) then
        State.npcEditor.catalogScroll = math.max(0,
            (State.npcEditor.catalogScroll or 0) - dy * 30)
    end
end

function M.textinput(t)
    if not State.editorFocus then return false end
    ensureEditorState()
    local d = State.npcEditor.draft
    local f = State.editorFocus
    if f == "id" then
        if #(d.id or "") >= 32 then return true end
        if t:match("[%w_%-]") then d.id = (d.id or "") .. t end
        return true
    elseif f == "name" or f == "title" then
        local cur = d[f] or ""
        if #cur >= 64 then return true end
        if t:match("[%w%s_%-]") then d[f] = cur .. t end
        return true
    end
    return false
end

function M.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    if ctrl and key == "s" then saveDraftToServer(); return true end

    if not State.editorFocus then return false end
    ensureEditorState()
    local d = State.npcEditor.draft
    local f = State.editorFocus
    if key == "backspace" then
        if f == "id" then
            d.id = (d.id or ""):sub(1, -2)
            return true
        elseif f == "name" or f == "title" then
            d[f] = (d[f] or ""):sub(1, -2)
            return true
        end
    elseif key == "return" or key == "kpenter" or key == "escape" then
        State.editorFocus = nil
        return true
    end
    return true  -- absorve outras teclas enquanto edita
end

return M
