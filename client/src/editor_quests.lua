-- Aba "Criar Quests" do editor unificado.
--
-- Layout:
--   esquerda → catálogo de quests (vindo de State.questDefs, populado por
--              QUEST_DEF) com botão "+ Nova Quest"
--   centro   → formulário rolável: identidade, NPC giver, repetível,
--              pré-requisitos, lista de objetivos (multi-objetivo:
--              kill / collect / visit / level / talk), bundle de
--              recompensas, mensagens, botões salvar/excluir
--
-- Persistência:
--   • SAVE_QUEST_DEF <json>   → servidor escreve em
--     data/scripts/quests_user/<id>.json e re-broadcasta QUEST_DEF.
--   • DELETE_QUEST_DEF <id>   → servidor remove o arquivo + def.

local State   = require("src.state")
local Network = require("src.network")
local JSON    = require("src.json")
local Layout  = require("src.editor_layout")
local Tooltip = require("src.tooltip")
local Pickers = require("src.editor_pickers")
local Items   = require("src.items")

local M = {}

M.panelRect = Layout.panelRect

local FIELD_H = 26
local LABEL_W = 150

-- Tipos de objetivo. Mantemos o id em inglês (vai pra rede) e a label
-- em pt-BR pra UI.
local OBJ_LABELS = {
    kill    = "Matar",
    collect = "Coletar item",
    visit   = "Visitar (x,y)",
    level   = "Atingir nível",
    talk    = "Conversar com",
}
local OBJ_ORDER = { "kill", "collect", "visit", "level", "talk" }

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
        name        = "Nova Missão",
        description = "",
        giver       = "",
        repeatable  = false,
        prerequisites = { level = 0, quest = "", class = "" },
        objectives  = { { type = "kill", target = "", count = 1 } },
        reward      = {
            xp = 0, gold = 0, skill_points = 0, learn_skill = "",
            items = {},   -- list of { id, qty }
        },
        intro       = "",
        in_progress = "",
        complete    = "",
    }
end

local function ensureEditorState()
    State.questEditor.draft         = State.questEditor.draft or freshDraft()
    State.questEditor.formScroll    = State.questEditor.formScroll or 0
    State.questEditor.catalogScroll = State.questEditor.catalogScroll or 0
    State.questEditor.selectedId    = State.questEditor.selectedId
end

-- Catálogo -------------------------------------------------------------------

local function catalogList()
    local out = {}
    for id, def in pairs(State.questDefs or {}) do
        out[#out + 1] = { id = id, def = def }
    end
    table.sort(out, function(a, b) return a.id < b.id end)
    return out
end

local function loadDefIntoDraft(def)
    local d = freshDraft()
    d.id          = def.id or ""
    d.name        = def.name or d.id
    d.description = def.description or ""
    d.giver       = def.giver or ""
    d.repeatable  = def.repeatable and true or false
    if def.prerequisites then
        d.prerequisites.level = def.prerequisites.level or 0
        d.prerequisites.quest = def.prerequisites.quest or ""
        d.prerequisites.class = def.prerequisites.class or ""
    end
    d.objectives = {}
    for _, o in ipairs(def.objectives or {}) do
        d.objectives[#d.objectives + 1] = {
            type   = o.type or "kill",
            target = o.target or "",
            count  = o.count  or 1,
            map    = o.map    or "",
            x      = o.x      or 0,
            y      = o.y      or 0,
            range  = o.range  or 0,
            note   = o.note   or "",
        }
    end
    if #d.objectives == 0 then
        d.objectives[1] = { type = "kill", target = "", count = 1 }
    end
    if def.reward then
        d.reward.xp           = def.reward.xp or 0
        d.reward.gold         = def.reward.gold or 0
        d.reward.skill_points = def.reward.skill_points or 0
        d.reward.learn_skill  = def.reward.learn_skill or ""
        d.reward.items = {}
        for _, it in ipairs(def.reward.items or {}) do
            d.reward.items[#d.reward.items + 1] = {
                id = it.id or "", qty = it.qty or 1,
            }
        end
    end
    d.intro       = def.intro       or ""
    d.in_progress = def.in_progress or ""
    d.complete    = def.complete    or ""
    State.questEditor.draft = d
    State.questEditor.selectedId = d.id
    State.questEditor.saveStatus = ""
end

-- Persistence ----------------------------------------------------------------

local function defToWire(d)
    local out = { id = d.id, name = d.name }
    if d.description ~= "" then out.description = d.description end
    if d.giver ~= ""       then out.giver = d.giver end
    if d.repeatable        then out.repeatable = true end
    local pre = {}
    if (d.prerequisites.level or 0) > 0 then pre.level = d.prerequisites.level end
    if d.prerequisites.quest ~= ""       then pre.quest = d.prerequisites.quest end
    if d.prerequisites.class ~= ""       then pre.class = d.prerequisites.class end
    if next(pre) ~= nil then out.prerequisites = pre end
    if #d.objectives > 0 then
        out.objectives = {}
        for _, o in ipairs(d.objectives) do
            local om = { type = o.type }
            if o.target and o.target ~= "" then om.target = o.target end
            if (o.count or 0) > 0 then om.count = o.count end
            if o.map and o.map ~= "" then om.map = o.map end
            if (o.x or 0) ~= 0 then om.x = o.x end
            if (o.y or 0) ~= 0 then om.y = o.y end
            if (o.range or 0) > 0 then om.range = o.range end
            if o.note and o.note ~= "" then om.note = o.note end
            out.objectives[#out.objectives + 1] = om
        end
    end
    local rew = {}
    if (d.reward.xp or 0) > 0 then rew.xp = d.reward.xp end
    if (d.reward.gold or 0) > 0 then rew.gold = d.reward.gold end
    if (d.reward.skill_points or 0) > 0 then rew.skill_points = d.reward.skill_points end
    if d.reward.learn_skill and d.reward.learn_skill ~= "" then
        rew.learn_skill = d.reward.learn_skill
    end
    if #d.reward.items > 0 then
        rew.items = {}
        for _, it in ipairs(d.reward.items) do
            if it.id ~= "" then
                rew.items[#rew.items + 1] = { id = it.id, qty = it.qty or 1 }
            end
        end
    end
    if next(rew) ~= nil then out.reward = rew end
    if d.intro ~= ""       then out.intro = d.intro end
    if d.in_progress ~= "" then out.in_progress = d.in_progress end
    if d.complete ~= ""    then out.complete = d.complete end
    return out
end

-- Phase 1 — verifica se cada id referenciado pelo draft existe no
-- catálogo correspondente. Reportar antes de mandar para o servidor
-- evita "quebra silenciosa" descrita no roadmap.
local function validateDraftRefs(d)
    if d.giver and d.giver ~= "" and not (State.npcDefs or {})[d.giver] then
        return false, "giver '" .. d.giver .. "' não existe no catálogo de NPCs"
    end
    for i, o in ipairs(d.objectives or {}) do
        if (o.type == "kill" or o.type == "talk") and o.target and o.target ~= "" then
            if not (State.npcDefs or {})[o.target] then
                return false, "obj " .. i .. ": npc '" .. o.target .. "' não existe"
            end
        elseif o.type == "collect" and o.target and o.target ~= "" then
            if not (State.itemDefs or {})[o.target] then
                return false, "obj " .. i .. ": item '" .. o.target .. "' não existe"
            end
        end
    end
    for i, it in ipairs(d.reward.items or {}) do
        if it.id and it.id ~= "" and not (State.itemDefs or {})[it.id] then
            return false, "reward " .. i .. ": item '" .. it.id .. "' não existe"
        end
    end
    return true
end

local function saveDraft()
    ensureEditorState()
    local d = State.questEditor.draft
    if not d.id or d.id == "" then
        State.questEditor.saveStatus = "id obrigatório"
        return
    end
    local ok, err = validateDraftRefs(d)
    if not ok then
        State.questEditor.saveStatus = err
        return
    end
    if Network.connected and not Network.connected() then
        State.questEditor.saveStatus = "offline"
        return
    end
    Network.send("SAVE_QUEST_DEF " .. JSON.encode(defToWire(d)))
    State.questEditor.saveStatus = "quest salva"
    State.questEditor.selectedId = d.id
end

local function deleteDraft(id)
    if not id or id == "" then return end
    if Network.connected and not Network.connected() then return end
    Network.send("DELETE_QUEST_DEF " .. id)
    if State.questEditor.selectedId == id then
        State.questEditor.draft = freshDraft()
        State.questEditor.selectedId = nil
    end
    State.questEditor.saveStatus = "quest excluída"
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
    love.graphics.print("Catálogo de Quests", lx + 12, ly + 10)

    local btnX, btnY, btnW, btnH = lx + 8, ly + 36, lw - 16, 26
    local hover = pointIn(mx, my, btnX, btnY, btnW, btnH)
    love.graphics.setColor(hover and 0.26 or 0.20, hover and 0.55 or 0.45,
                           hover and 0.32 or 0.25)
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4, 4)
    love.graphics.setColor(0.50, 0.7, 0.55)
    love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("+ Nova Quest", btnX, btnY + 5, btnW, "center")
    if hover then Tooltip.hover("Limpa o formulário para criar uma nova quest do zero.") end

    local list = catalogList()
    local areaY = btnY + btnH + 6
    local areaH = lh - (areaY - ly) - 8
    love.graphics.setScissor(lx + 4, areaY, lw - 8, areaH)
    love.graphics.setFont(State.fonts.name)
    local rowH = 56
    for i, item in ipairs(list) do
        local rx, ry = lx + 8, areaY + (i - 1) * (rowH + 4) - State.questEditor.catalogScroll
        if ry + rowH >= areaY - 4 and ry <= areaY + areaH then
            local active = item.id == State.questEditor.selectedId
            local rh = rowH
            local rw = lw - 16
            local rhover = pointIn(mx, my, rx, ry, rw, rh)
            love.graphics.setColor(active and 0.20 or (rhover and 0.16 or 0.11),
                                   active and 0.36 or (rhover and 0.20 or 0.14),
                                   active and 0.60 or (rhover and 0.28 or 0.20))
            love.graphics.rectangle("fill", rx, ry, rw, rh, 4, 4)
            love.graphics.setColor(0.30, 0.42, 0.66, 0.6)
            love.graphics.rectangle("line", rx, ry, rw, rh, 4, 4)

            love.graphics.setFont(State.fonts.ui)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(item.def.name or item.id, rx + 8, ry + 6)
            love.graphics.setFont(State.fonts.name)
            love.graphics.setColor(0.65, 0.74, 0.88)

            local meta = string.format("%d obj • %d xp",
                #(item.def.objectives or {}),
                (item.def.reward or {}).xp or 0)
            if item.def.giver and item.def.giver ~= "" then
                meta = meta .. " • " .. item.def.giver
            end
            if item.def.repeatable then
                meta = meta .. " • repetível"
            end
            love.graphics.print(meta, rx + 8, ry + 26)

            local prereq = ""
            if item.def.prerequisites then
                if (item.def.prerequisites.level or 0) > 0 then
                    prereq = "lvl " .. item.def.prerequisites.level
                end
                if item.def.prerequisites.quest and
                   item.def.prerequisites.quest ~= "" then
                    prereq = prereq ~= "" and (prereq .. " • ") or ""
                    prereq = prereq .. "após " .. item.def.prerequisites.quest
                end
            end
            if prereq ~= "" then
                love.graphics.setColor(0.95, 0.85, 0.40)
                love.graphics.print("⚠ " .. prereq, rx + 8, ry + 40)
            end
        end
    end
    if #list == 0 then
        love.graphics.setColor(0.7, 0.78, 0.92)
        love.graphics.printf("Nenhuma quest no catálogo.\nClique em \"+ Nova Quest\" e salve.",
            lx + 8, areaY + 12, lw - 16, "center")
    end
    love.graphics.setScissor()
end

-- Form rows construction ----------------------------------------------------

local function buildRows(d, fx, fy, fw)
    local rows = {}
    local y = fy + 12 - State.questEditor.formScroll

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
         tip = "Identificador único (a-z, 0-9, _)." }
    row{ kind = "text", field = "name", label = "Nome", value = d.name }
    row{ kind = "text", field = "description", label = "Descrição",
         value = d.description, h = 44,
         tip = "Texto curto exibido no diário do jogador." }
    row{ kind = "id_picker", field = "giver", pickerKind = "npc",
         pickerFilter = "quest_giver",
         label = "NPC giver", value = d.giver,
         tip = "Clique para escolher o NPC quest_giver. Ele recebe um marcador '!' no mapa." }
    row{ kind = "checkbox", field = "repeatable", label = "Repetível",
         value = d.repeatable,
         tip = "Permite ao jogador refazer a quest após completar." }

    pad(4)
    row{ kind = "header", label = "Pré-requisitos" }
    row{ kind = "stepper", path = "prerequisites.level",
         label = "Nível mínimo", value = d.prerequisites.level,
         step = 1, min = 0, max = 99 }
    row{ kind = "text", path = "prerequisites.quest",
         label = "Quest anterior", value = d.prerequisites.quest,
         tip = "ID de outra quest que precisa estar concluída." }

    pad(4)
    row{ kind = "header", label = "Objetivos" }
    for i, o in ipairs(d.objectives) do
        row{ kind = "obj_type", index = i, value = o.type,
             label = "Tipo " .. i }
        if o.type == "kill" or o.type == "collect" or o.type == "talk" then
            -- Phase 1 — substitui text input por picker, escolhendo o
            -- catálogo certo conforme o tipo do objetivo.
            local pickerKind, pickerFilter
            if o.type == "kill" then
                pickerKind = "npc"
                pickerFilter = { "enemy", "guardian" }
            elseif o.type == "collect" then
                pickerKind = "item"
            elseif o.type == "talk" then
                pickerKind = "npc"
            end
            row{ kind = "obj_target", index = i, value = o.target,
                 pickerKind = pickerKind, pickerFilter = pickerFilter,
                 label = "Alvo",
                 tip = o.type == "kill" and "Clique para escolher o enemy/guardian alvo." or
                       o.type == "collect" and "Clique para escolher o item a coletar." or
                       "Clique para escolher o NPC para conversar." }
            row{ kind = "obj_count", index = i, value = o.count,
                 label = "Quantidade", step = 1, min = 1, max = 999 }
        elseif o.type == "level" then
            row{ kind = "obj_count", index = i, value = o.count,
                 label = "Nível alvo", step = 1, min = 1, max = 99 }
        elseif o.type == "visit" then
            row{ kind = "obj_xy", index = i, value = { x = o.x, y = o.y },
                 label = "Tile (x, y)" }
            row{ kind = "obj_range", index = i, value = o.range,
                 label = "Raio", step = 1, min = 0, max = 20,
                 tip = "Distância em tiles para considerar a chegada (0 = exato)." }
        end
        row{ kind = "obj_note", index = i, value = o.note,
             label = "Nota",
             tip = "Texto exibido no diário do jogador para esse objetivo." }
        row{ kind = "obj_remove", index = i,
             label = "Remover objetivo", h = 22,
             color = { 0.50, 0.20, 0.20 } }
    end
    row{ kind = "button", action = "add_objective",
         label = "+ Adicionar objetivo",
         color = { 0.20, 0.45, 0.25 }, h = 26,
         tip = "Adiciona um novo objetivo à lista." }

    pad(4)
    row{ kind = "header", label = "Recompensas" }
    row{ kind = "stepper", path = "reward.xp", label = "XP",
         value = d.reward.xp, step = 25, min = 0, max = 99999 }
    row{ kind = "stepper", path = "reward.gold", label = "Gold",
         value = d.reward.gold, step = 10, min = 0, max = 99999 }
    row{ kind = "stepper", path = "reward.skill_points",
         label = "Skill Points", value = d.reward.skill_points,
         step = 1, min = 0, max = 99 }
    row{ kind = "text", path = "reward.learn_skill",
         label = "Aprender Skill", value = d.reward.learn_skill,
         tip = "ID de uma skill a aprender automaticamente ao completar." }
    for i, it in ipairs(d.reward.items) do
        row{ kind = "reward_item", index = i, value = it,
             label = "Item " .. i }
    end
    row{ kind = "button", action = "add_reward_item",
         label = "+ Adicionar item",
         color = { 0.20, 0.45, 0.25 }, h = 22,
         tip = "Adiciona um item à lista de recompensas." }

    pad(4)
    row{ kind = "header", label = "Mensagens (chat SYS)" }
    row{ kind = "text", field = "intro", label = "Ao aceitar",
         value = d.intro, h = 30 }
    row{ kind = "text", field = "in_progress", label = "Em andamento",
         value = d.in_progress, h = 30 }
    row{ kind = "text", field = "complete", label = "Ao completar",
         value = d.complete, h = 30 }

    pad(8)
    rows[#rows + 1] = {
        kind = "button", action = "save",
        label = "Salvar Quest (Ctrl+S)", x = fx + 14, y = y,
        w = (fw - 36) / 2, h = 30, color = { 0.20, 0.45, 0.25 } }
    rows[#rows + 1] = {
        kind = "button", action = "new",
        label = "+ Nova", x = fx + 14 + (fw - 36) / 2 + 8, y = y,
        w = (fw - 36) / 2, h = 30, color = { 0.20, 0.32, 0.55 } }
    y = y + 36
    rows[#rows + 1] = {
        kind = "button", action = "delete",
        label = "Excluir Quest", x = fx + 14, y = y,
        w = fw - 28, h = 26, color = { 0.50, 0.20, 0.20 } }
    y = y + 32

    return rows
end

-- Drawing helpers ------------------------------------------------------------

local function drawHeader(row)
    love.graphics.setColor(0.45, 0.78, 1.0, 0.18)
    love.graphics.rectangle("fill", row.x - 6, row.y, row.w + 12, row.h, 4, 4)
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(0.85, 0.95, 1.0)
    love.graphics.print(row.label, row.x, row.y + 4)
end

-- Phase 1 — desenho do row "id_picker": label + área clicável que abre
-- o picker correspondente. Borda fica vermelha quando o id atual não
-- existe mais no catálogo (o usuário renomeou ou apagou o referenciado).
local function catalogFor(kind)
    if kind == "quest" then return State.questDefs end
    if kind == "item"  then return State.itemDefs end
    if kind == "npc"   then return State.npcDefs end
end

local function drawIdPickerRow(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local tw = row.w - LABEL_W
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local hover = pointIn(mx, my, tx, row.y, tw, row.h)

    local catalog = catalogFor(row.pickerKind)
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
        -- Para item, desenha o ícone à esquerda como preview.
        if row.pickerKind == "item" and def then
            Items.draw(Items.iconForItem(def), tx + 2, row.y + 1, row.h - 2,
                { rarity = def.rarity })
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(label, tx + row.h + 4, row.y + 5)
        else
            love.graphics.print(label, tx + 6, row.y + 5)
        end
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
    love.graphics.setColor(1, 1, 1)
    if row.value then
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

local function drawObjType(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local segW = (row.w - LABEL_W) / #OBJ_ORDER
    for i, opt in ipairs(OBJ_ORDER) do
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
        love.graphics.printf(OBJ_LABELS[opt] or opt, sx + 1, row.y + 5,
            segW - 2, "center")
    end
end

local function drawObjXY(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local fw = row.w - LABEL_W
    -- Two side-by-side steppers (x, y).
    local half = (fw - 8) / 2
    for i, axis in ipairs({ "x", "y" }) do
        local hx = tx + (i - 1) * (half + 8)
        local btnW = 22
        local val = row.value[axis] or 0
        love.graphics.setColor(0.13, 0.16, 0.22)
        love.graphics.rectangle("fill", hx, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(0.4, 0.55, 0.78)
        love.graphics.rectangle("line", hx, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("−", hx, row.y + 4, btnW, "center")
        love.graphics.setColor(0.10, 0.13, 0.18)
        love.graphics.rectangle("fill", hx + btnW + 2, row.y,
            half - btnW * 2 - 4, row.h, 4, 4)
        love.graphics.setColor(0.4, 0.55, 0.78, 0.6)
        love.graphics.rectangle("line", hx + btnW + 2, row.y,
            half - btnW * 2 - 4, row.h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(axis .. "=" .. tostring(val),
            hx + btnW + 2, row.y + 5, half - btnW * 2 - 4, "center")
        love.graphics.setColor(0.13, 0.16, 0.22)
        love.graphics.rectangle("fill", hx + half - btnW, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(0.4, 0.55, 0.78)
        love.graphics.rectangle("line", hx + half - btnW, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("+", hx + half - btnW, row.y + 4, btnW, "center")
    end
end

local function drawRewardItem(row)
    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(0.7, 0.78, 0.92)
    love.graphics.print(row.label, row.x, row.y + 5)
    local tx = row.x + LABEL_W
    local fw = row.w - LABEL_W
    -- Phase 1 — id agora é uma área clicável que abre o picker de itens.
    local idW = fw - 130
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local hover = pointIn(mx, my, tx, row.y, idW, row.h)
    local def = (State.itemDefs or {})[row.value.id or ""]
    local missing = row.value.id and row.value.id ~= "" and not def
    love.graphics.setColor(hover and 0.18 or 0.13,
                           hover and 0.22 or 0.16,
                           hover and 0.30 or 0.22)
    love.graphics.rectangle("fill", tx, row.y, idW, row.h, 4, 4)
    if missing then
        love.graphics.setColor(0.95, 0.40, 0.40)
    else
        love.graphics.setColor(0.4, 0.55, 0.78)
    end
    love.graphics.rectangle("line", tx, row.y, idW, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    if row.value.id and row.value.id ~= "" then
        if def then
            Items.draw(Items.iconForItem(def), tx + 2, row.y + 1, row.h - 2,
                { rarity = def.rarity })
            love.graphics.print(def.name or row.value.id,
                tx + row.h + 4, row.y + 5)
        else
            love.graphics.print(row.value.id, tx + 6, row.y + 5)
        end
    else
        love.graphics.setColor(0.65, 0.78, 0.92, 0.7)
        love.graphics.print("Clique para escolher item...", tx + 6, row.y + 5)
    end
    if hover then
        Tooltip.hover("Clique para abrir o picker de itens.")
    end

    love.graphics.setColor(0.10, 0.13, 0.18)
    love.graphics.rectangle("fill", tx + idW + 2, row.y, 80, row.h, 4, 4)
    love.graphics.setColor(0.4, 0.55, 0.78, 0.6)
    love.graphics.rectangle("line", tx + idW + 2, row.y, 80, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("qty " .. (row.value.qty or 1),
        tx + idW + 2, row.y + 5, 80, "center")

    love.graphics.setColor(0.50, 0.20, 0.20)
    love.graphics.rectangle("fill", tx + fw - 40, row.y, 40, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("✕", tx + fw - 40, row.y + 5, 40, "center")
end

local function drawObjRemove(row)
    love.graphics.setFont(State.fonts.name)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local hover = pointIn(mx, my, row.x, row.y, row.w, row.h)
    love.graphics.setColor(hover and 0.65 or 0.40, 0.20, 0.22)
    love.graphics.rectangle("fill", row.x, row.y, row.w, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.rectangle("line", row.x, row.y, row.w, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Remover objetivo " .. row.index, row.x, row.y + 4,
        row.w, "center")
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

local function drawForm()
    ensureEditorState()
    local d = State.questEditor.draft
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
            local fkey = r.field or r.path
            drawTextRow(r, State.editorFocus == fkey)
        elseif r.kind == "checkbox" then
            drawCheckbox(r)
        elseif r.kind == "stepper" then
            drawStepperRow(r)
        elseif r.kind == "obj_type" then
            drawObjType(r)
        elseif r.kind == "obj_target" then
            -- Phase 1 — obj_target vira id_picker (kind/filter
            -- vêm preenchidos pelo buildRows).
            drawIdPickerRow(r)
        elseif r.kind == "id_picker" then
            drawIdPickerRow(r)
        elseif r.kind == "obj_count" then
            drawStepperRow(r)
        elseif r.kind == "obj_xy" then
            drawObjXY(r)
        elseif r.kind == "obj_range" then
            drawStepperRow(r)
        elseif r.kind == "obj_note" then
            drawTextRow(r, State.editorFocus == ("obj_note_" .. r.index))
        elseif r.kind == "obj_remove" then
            drawObjRemove(r)
        elseif r.kind == "reward_item" then
            drawRewardItem(r)
        elseif r.kind == "button" then
            drawButton(r)
        end
    end
    love.graphics.setScissor()

    if State.questEditor.saveStatus and State.questEditor.saveStatus ~= "" then
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(0.95, 0.85, 0.40)
        love.graphics.print("status: " .. State.questEditor.saveStatus,
            fx + 14, fy + fh - 18)
    end
end

function M.drawContent()
    ensureEditorState()
    drawCatalog()
    drawForm()
end

-- Input ----------------------------------------------------------------------

-- Helpers para mexer em paths "reward.xp" / "prerequisites.level".
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
    elseif row.kind == "obj_count" then
        d.objectives[row.index].count = cur
    elseif row.kind == "obj_range" then
        d.objectives[row.index].range = cur
    end
end

local function handleObjTypeClick(d, row, x)
    local tx = row.x + LABEL_W
    local segW = (row.w - LABEL_W) / #OBJ_ORDER
    local idx = math.floor((x - tx) / segW) + 1
    local opt = OBJ_ORDER[idx]
    if opt then d.objectives[row.index].type = opt end
end

local function handleObjXYClick(d, row, x)
    local tx = row.x + LABEL_W
    local fw = row.w - LABEL_W
    local half = (fw - 8) / 2
    local btnW = 22
    for i, axis in ipairs({ "x", "y" }) do
        local hx = tx + (i - 1) * (half + 8)
        local cur = d.objectives[row.index][axis] or 0
        if x >= hx and x < hx + btnW then
            cur = cur - 1
        elseif x >= hx + half - btnW and x < hx + half then
            cur = cur + 1
        else
            cur = nil
        end
        if cur ~= nil then
            d.objectives[row.index][axis] = clamp(cur, 0, 999)
            return
        end
    end
end

local function handleRewardItemClick(d, row, x)
    local tx = row.x + LABEL_W
    local fw = row.w - LABEL_W
    local idW = fw - 130
    if x >= tx and x < tx + idW then
        -- Phase 1 — abre o picker em vez de focar text input.
        local rewIdx = row.index
        Pickers.openItem(d.reward.items[rewIdx].id, function(id)
            d.reward.items[rewIdx].id = id or ""
        end)
        State.editorFocus = nil
        return
    end
    if x >= tx + idW + 2 and x < tx + idW + 82 then
        local cur = d.reward.items[row.index].qty or 1
        cur = cur + 1
        if cur > 99 then cur = 1 end
        d.reward.items[row.index].qty = cur
        return
    end
    if x >= tx + fw - 40 then
        table.remove(d.reward.items, row.index)
        return
    end
end

-- Phase 1 — handler genérico para qualquer row id_picker (giver no topo
-- e obj_target nos objetivos). Resolve o catálogo certo via row.pickerKind
-- e empurra o id escolhido de volta no campo correspondente do draft.
local function handleIdPickerClick(d, row)
    local cb
    if row.kind == "obj_target" then
        local idx = row.index
        cb = function(id) d.objectives[idx].target = id or "" end
    else
        local field = row.field
        cb = function(id) d[field] = id or "" end
    end
    if row.pickerKind == "quest" then
        Pickers.openQuest(row.value, cb)
    elseif row.pickerKind == "item" then
        Pickers.openItem(row.value, cb)
    elseif row.pickerKind == "npc" then
        Pickers.openNPC(row.pickerFilter, row.value, cb)
    end
    State.editorFocus = nil
end

local function formClick(x, y, button)
    button = button or 1
    ensureEditorState()
    local d = State.questEditor.draft
    local fx, fy, fw, fh = formRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end
    local rows = buildRows(d, fx, fy, fw)
    for _, r in ipairs(rows) do
        if pointIn(x, y, r.x, r.y, r.w, r.h) then
            if r.kind == "text" then
                State.editorFocus = r.field or r.path
                return true
            elseif r.kind == "checkbox" then
                d[r.field] = not d[r.field]
                return true
            elseif r.kind == "stepper" then
                handleStepperClick(d, r, x)
                return true
            elseif r.kind == "obj_type" then
                handleObjTypeClick(d, r, x)
                return true
            elseif r.kind == "obj_target" then
                handleIdPickerClick(d, r)
                return true
            elseif r.kind == "id_picker" then
                handleIdPickerClick(d, r)
                return true
            elseif r.kind == "obj_count" or r.kind == "obj_range" then
                handleStepperClick(d, r, x)
                return true
            elseif r.kind == "obj_xy" then
                handleObjXYClick(d, r, x)
                return true
            elseif r.kind == "obj_note" then
                State.editorFocus = "obj_note_" .. r.index
                return true
            elseif r.kind == "obj_remove" then
                if #d.objectives > 1 then
                    table.remove(d.objectives, r.index)
                end
                State.editorFocus = nil
                return true
            elseif r.kind == "reward_item" then
                handleRewardItemClick(d, r, x)
                return true
            elseif r.kind == "button" then
                if r.action == "save" then
                    saveDraft()
                elseif r.action == "new" then
                    State.questEditor.draft = freshDraft()
                    State.questEditor.selectedId = nil
                    State.editorFocus = "id"
                elseif r.action == "delete" then
                    deleteDraft(d.id)
                elseif r.action == "add_objective" then
                    d.objectives[#d.objectives + 1] = {
                        type = "kill", target = "", count = 1,
                    }
                elseif r.action == "add_reward_item" then
                    d.reward.items[#d.reward.items + 1] = { id = "", qty = 1 }
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
        State.questEditor.draft = freshDraft()
        State.questEditor.selectedId = nil
        State.editorFocus = "id"
        State.questEditor.saveStatus = ""
        return true
    end
    local list = catalogList()
    local areaY = btnY + btnH + 6
    local rowH = 56
    for i, item in ipairs(list) do
        local rx, ry = lx + 8, areaY + (i - 1) * (rowH + 4) - State.questEditor.catalogScroll
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
        State.questEditor.formScroll = math.max(0,
            (State.questEditor.formScroll or 0) - dy * 30)
        return
    end
    if pointIn(mx, my, catalogRect()) then
        State.questEditor.catalogScroll = math.max(0,
            (State.questEditor.catalogScroll or 0) - dy * 30)
    end
end

function M.textinput(t)
    if not State.editorFocus then return false end
    ensureEditorState()
    local d = State.questEditor.draft
    local f = State.editorFocus
    -- Top-level text fields. (giver virou id_picker — ver Phase 1.)
    local topFields = { id = true, name = true, description = true,
        intro = true, in_progress = true, complete = true }
    if topFields[f] then
        if #(d[f] or "") >= (f == "description" and 256 or 64) then return true end
        if t:match("[%w%s_%-%.,!%?%(%)%/]") then
            d[f] = (d[f] or "") .. t
        end
        return true
    end
    if f == "prerequisites.quest" or f == "prerequisites.class" then
        local cur = getByPath(d, f) or ""
        if #cur >= 32 then return true end
        if t:match("[%w_%-]") then
            setByPath(d, f, cur .. t)
        end
        return true
    end
    if f == "reward.learn_skill" then
        local cur = d.reward.learn_skill or ""
        if #cur >= 32 then return true end
        if t:match("[%w_%-]") then
            d.reward.learn_skill = cur .. t
        end
        return true
    end
    -- Per-objective text fields (target virou id_picker — ver Phase 1).
    local objField, objIdx = f:match("^obj_(%a+)_(%d+)$")
    if objField and objIdx then
        objIdx = tonumber(objIdx)
        local obj = d.objectives[objIdx]
        if obj and objField == "note" then
            local cur = obj.note or ""
            if #cur >= 64 then return true end
            if t:match("[%w%s_%-%.,!%?]") then
                obj.note = cur .. t
            end
            return true
        end
    end
    return false
end

function M.keypressed(key)
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")
    if ctrl and key == "s" then saveDraft(); return true end
    if not State.editorFocus then return false end
    ensureEditorState()
    local d = State.questEditor.draft
    local f = State.editorFocus

    local function doBackspace()
        local topFields = { id = true, name = true, description = true,
            intro = true, in_progress = true, complete = true }
        if topFields[f] then
            d[f] = (d[f] or ""):sub(1, -2)
            return true
        end
        if f == "prerequisites.quest" or f == "prerequisites.class" then
            local cur = getByPath(d, f) or ""
            setByPath(d, f, cur:sub(1, -2))
            return true
        end
        if f == "reward.learn_skill" then
            d.reward.learn_skill = (d.reward.learn_skill or ""):sub(1, -2)
            return true
        end
        local objField, objIdx = f:match("^obj_(%a+)_(%d+)$")
        if objField and objIdx then
            objIdx = tonumber(objIdx)
            local obj = d.objectives[objIdx]
            if obj and objField == "note" then
                obj.note = (obj.note or ""):sub(1, -2)
                return true
            end
        end
        return false
    end

    if key == "backspace" then
        if doBackspace() then return true end
    elseif key == "return" or key == "kpenter" or key == "escape" then
        State.editorFocus = nil
        return true
    end
    return true
end

return M
