-- Aba "Criador de NPCs" do editor unificado. Inspirada em frmEditor_NPC.frm
-- da reference_engine: lista de NPCs à esquerda, formulário à direita com
-- nome/título e a árvore de diálogo. Toda mudança grava no servidor via
-- REGNPC (que escreve em data/scripts/npcs_user/<id>.json e faz broadcast
-- de NPC_FULL para todos os clientes). Excluir manda DELNPC.
--
-- Modelo do NPC (espelho do NPCDef em server/npc.go):
--   { id, name, title, dialog = { [nodeId] = { text, options, on_enter } } }
-- Uma `option` é { text, next_node, hook = { type, quest, item, qty } }.
-- O nó "start" é obrigatório.

local State   = require("src.state")
local Network = require("src.network")
local Layout  = require("src.editor_layout")
local Tooltip = require("src.tooltip")
local JSON    = require("src.json")

local M = {}

local LABEL_W = 110
local FIELD_H = 26
local ROW_GAP = 6

-- Tipos de hook permitidos no servidor (validateHook em npc.go).
local HOOK_TYPES = {
    "",
    "quest_start",
    "quest_complete",
    "quest_advance",
    "give_item",
    "take_item",
}
local HOOK_LABELS = {
    [""]               = "(nenhum)",
    quest_start        = "Iniciar quest",
    quest_complete     = "Concluir quest",
    quest_advance      = "Avançar quest",
    give_item          = "Dar item",
    take_item          = "Tomar item",
}
local HOOK_TIPS = {
    [""]               = "A opção/no apenas conduz a próxima fala — sem efeito colateral.",
    quest_start        = "Inicia a quest informada para o jogador.",
    quest_complete     = "Conclui a quest e entrega a recompensa (se objetivos cumpridos).",
    quest_advance      = "Move a quest para o estágio informado em 'stage'.",
    give_item          = "Adiciona o item informado ao inventário.",
    take_item          = "Remove o item informado do inventário (falha silenciosa se faltar).",
}

local function pointIn(px, py, x, y, w, h)
    return px >= x and py >= y and px < x + w and py < y + h
end

local function panelRect()    return Layout.panelRect() end
local function listRect()
    local cx, cy, _, ch = Layout.contentRect()
    return cx + 12, cy + 10, 230, ch - 24
end
local function formRect()
    local cx, cy, cw, ch = Layout.contentRect()
    local lw = 230
    return cx + 12 + lw + 12, cy + 10, cw - lw - 36, ch - 24
end

-- ---------------------------------------------------------------------------
-- Estado local: cópia editável do NPC selecionado, índice do nó focado, e
-- offset de rolagem do formulário (a árvore pode ser maior que a área).
-- ---------------------------------------------------------------------------

local edit = {
    id          = nil,   -- id do NPC sendo editado
    selectedNode = "start",
    scroll      = 0,
    -- Cache de IDs de NPC (lista ordenada) para a coluna esquerda.
    listOrder   = {},
}

local function listAll()
    local ids = {}
    for id in pairs(State.npcFull) do ids[#ids + 1] = id end
    table.sort(ids)
    edit.listOrder = ids
    return ids
end

local function ensureSelection()
    listAll()
    if edit.id and not State.npcFull[edit.id] then
        edit.id = nil
        edit.selectedNode = "start"
    end
    if not edit.id and #edit.listOrder > 0 then
        edit.id = edit.listOrder[1]
        edit.selectedNode = "start"
    end
end

local function current()
    return edit.id and State.npcFull[edit.id] or nil
end

local function nodeIDs(def)
    local out = {}
    if not def or not def.dialog then return out end
    for k in pairs(def.dialog) do out[#out + 1] = k end
    table.sort(out, function(a, b)
        if a == "start" then return true end
        if b == "start" then return false end
        return a < b
    end)
    return out
end

local function uniqueID(prefix, taken)
    for i = 1, 999 do
        local cand = string.format("%s_%d", prefix, i)
        if not taken[cand] then return cand end
    end
    return prefix .. "_x"
end

local function newDef()
    local taken = {}
    for id in pairs(State.npcFull) do taken[id] = true end
    local id = uniqueID("npc", taken)
    return {
        id    = id,
        name  = "Novo NPC",
        title = "Aldeão",
        dialog = {
            start = {
                text = "Olá, viajante.",
                options = {
                    { text = "Adeus.", next_node = "end", hook = {} },
                },
                on_enter = {},
            },
        },
    }
end

-- cleanForServer devolve uma cópia profunda do def removendo hooks/option
-- vazias. Necessário porque o encoder JSON do cliente serializa tabelas
-- vazias como [] (ambíguo) e o Go unmarshal espera um struct.
local function cleanHook(h)
    if type(h) ~= "table" or not h.type or h.type == "" then return nil end
    local out = { type = h.type }
    if h.quest and h.quest ~= "" then out.quest = h.quest end
    if h.stage and h.stage ~= "" then out.stage = h.stage end
    if h.item  and h.item  ~= "" then out.item  = h.item  end
    if h.qty   and h.qty   ~= 0  then out.qty   = h.qty   end
    return out
end

local function cleanForServer(def)
    local out = { id = def.id, name = def.name, title = def.title, dialog = {} }
    for nid, node in pairs(def.dialog or {}) do
        local n = { text = node.text or "" }
        local oe = cleanHook(node.on_enter)
        if oe then n.on_enter = oe end
        local opts = {}
        for i, opt in ipairs(node.options or {}) do
            local o = { text = opt.text or "" }
            if opt.next_node and opt.next_node ~= "" then o.next_node = opt.next_node end
            local oh = cleanHook(opt.hook)
            if oh then o.hook = oh end
            opts[i] = o
        end
        if #opts > 0 then n.options = opts end
        out.dialog[nid] = n
    end
    return out
end

-- registerWithServer envia o NPC inteiro como JSON. O servidor valida,
-- persiste em npcs_user/<id>.json e faz broadcast para todos os clientes
-- (inclusive este, que recebe NPC_FULL de volta — autoritativo).
local function registerWithServer(def)
    if not Network.connected or not Network.connected() then return end
    if not def.id or def.id == "" then return end
    local blob = JSON.encode(cleanForServer(def))
    Network.send("REGNPC " .. blob)
end

local function unregisterWithServer(id)
    if not Network.connected or not Network.connected() then return end
    Network.send("DELNPC " .. id)
end

-- ---------------------------------------------------------------------------
-- Layout dinâmico do formulário. As coordenadas são compartilhadas por draw
-- e click para que nada saia de sincronia (mesmo padrão do editor_spells).
-- ---------------------------------------------------------------------------

local function formFields(def)
    local fx, fy, fw, fh = formRect()
    local rows = {}
    local y = fy + 10 - edit.scroll

    local function row(field)
        field.x = fx + 12
        field.y = y
        field.w = fw - 24
        field.h = field.h or FIELD_H
        rows[#rows + 1] = field
        y = y + field.h + ROW_GAP
    end

    -- Cabeçalho do NPC: id (read-only — id é a chave do arquivo em
    -- npcs_user/, renomear in-place teria que orquestrar DELNPC+REGNPC e
    -- não vale a complexidade), name, title.
    row{ name = "id",    type = "text", label = "ID",
         value = def.id or "", readOnly = true,
         tip = "Identificador imutável. É o nome do arquivo em npcs_user/." }
    row{ name = "name",  type = "text", label = "Nome",
         value = def.name or "",
         tip = "Nome exibido no diálogo." }
    row{ name = "title", type = "text", label = "Título",
         value = def.title or "",
         tip = "Subtítulo (ex.: 'Velho do vilarejo')." }

    -- Separador / cabeçalho da árvore de diálogo.
    row{ type = "separator", label = "Diálogo",
         h = 22 }

    -- Lista de nós (cliques selecionam). O nó "start" é fixo.
    local ids = nodeIDs(def)
    local nodeBarH = 24
    local nodeRow = { type = "node_bar", h = nodeBarH, ids = ids }
    row(nodeRow)

    -- Edição do nó selecionado.
    local nodeID = edit.selectedNode
    local node = def.dialog and def.dialog[nodeID]
    if not node then return rows end

    row{ name = "node_id", type = "text", label = "ID do nó",
         value = nodeID,
         readOnly = (nodeID == "start"),
         tip = "Identificador interno do nó. 'start' não pode ser renomeado." }
    row{ name = "node_text", type = "text", label = "Fala",
         value = node.text or "",
         multi = true, h = 50,
         tip = "Texto que o NPC diz quando o jogador chega neste nó." }

    -- on_enter hook do nó.
    local oe = node.on_enter or {}
    row{ name = "node_oe_type", type = "select", label = "OnEnter",
         options = HOOK_TYPES, optionLabels = HOOK_LABELS,
         optionTips = HOOK_TIPS,
         value = oe.type or "",
         tip = "Hook disparado ao entrar neste nó (antes de mostrar opções)." }
    if oe.type and oe.type ~= "" then
        if oe.type == "quest_start" or oe.type == "quest_complete" or oe.type == "quest_advance" then
            row{ name = "node_oe_quest", type = "text", label = "Quest",
                 value = oe.quest or "", tip = "ID da quest (ex.: orc_hunt)." }
        end
        if oe.type == "quest_advance" then
            row{ name = "node_oe_stage", type = "text", label = "Estágio",
                 value = oe.stage or "", tip = "Novo estágio para a quest." }
        end
        if oe.type == "give_item" or oe.type == "take_item" then
            row{ name = "node_oe_item", type = "text", label = "Item",
                 value = oe.item or "", tip = "ID do item (ex.: health_potion)." }
            row{ name = "node_oe_qty", type = "stepper", label = "Qtd",
                 value = oe.qty or 1, step = 1, min = 1, max = 99,
                 tip = "Quantidade do item." }
        end
    end

    -- Opções (lista). Cada opção é renderizada em uma "linha de opção" que
    -- agrupa text + next_node + hook em vários sub-campos.
    row{ type = "separator", label = "Opções", h = 20 }

    local options = node.options or {}
    for i, opt in ipairs(options) do
        row{ type = "opt_header", label = "Opção " .. i, idx = i,
             h = 18 }
        row{ name = "opt_text",   type = "text",   label = "Texto",
             optIdx = i, value = opt.text or "",
             tip = "Texto que o jogador vê como resposta." }
        row{ name = "opt_next",   type = "select_node",   label = "Próximo",
             optIdx = i, value = opt.next_node or "",
             nodeIDs = ids,
             tip = "Para qual nó essa opção leva. 'end' fecha o diálogo." }
        local hook = opt.hook or {}
        row{ name = "opt_hook_type", type = "select", label = "Hook",
             optIdx = i, options = HOOK_TYPES, optionLabels = HOOK_LABELS,
             optionTips = HOOK_TIPS,
             value = hook.type or "",
             tip = "Efeito colateral disparado quando o jogador escolhe a opção." }
        if hook.type and hook.type ~= "" then
            if hook.type == "quest_start" or hook.type == "quest_complete" or hook.type == "quest_advance" then
                row{ name = "opt_hook_quest", type = "text", label = "Quest",
                     optIdx = i, value = hook.quest or "" }
            end
            if hook.type == "quest_advance" then
                row{ name = "opt_hook_stage", type = "text", label = "Estágio",
                     optIdx = i, value = hook.stage or "" }
            end
            if hook.type == "give_item" or hook.type == "take_item" then
                row{ name = "opt_hook_item", type = "text", label = "Item",
                     optIdx = i, value = hook.item or "" }
                row{ name = "opt_hook_qty", type = "stepper", label = "Qtd",
                     optIdx = i, value = hook.qty or 1, step = 1, min = 1, max = 99 }
            end
        end
        row{ type = "opt_remove", optIdx = i, label = "Remover opção",
             h = 22 }
    end

    row{ type = "button", name = "add_option", label = "+ Adicionar opção",
         color = { 0.18, 0.40, 0.22 }, h = 24,
         tip = "Cria uma nova resposta para o jogador escolher." }

    -- Botões finais: salvar, excluir.
    row{ type = "spacer", h = 8 }
    row{ type = "button", name = "save", label = "Salvar (envia ao servidor)",
         color = { 0.20, 0.45, 0.65 }, h = 28,
         tip = "Persiste o NPC em data/scripts/npcs_user/ e faz broadcast." }
    row{ type = "button", name = "delete", label = "Excluir NPC",
         color = { 0.50, 0.20, 0.20 }, h = 24,
         tip = "Remove o NPC do servidor (apenas NPCs criados via editor)." }

    return rows
end

-- ---------------------------------------------------------------------------
-- Drawing
-- ---------------------------------------------------------------------------

local function drawList()
    local lx, ly, lw, lh = listRect()
    local mx, my = State.mouse.x or 0, State.mouse.y or 0

    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", lx, ly, lw, lh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", lx, ly, lw, lh, 4, 4)

    love.graphics.setFont(State.fonts.ui)
    local btnX, btnY, btnW, btnH = lx + 6, ly + 6, lw - 12, 26
    if pointIn(mx, my, btnX, btnY, btnW, btnH) then
        love.graphics.setColor(0.26, 0.55, 0.32)
        Tooltip.hover("Cria um novo NPC com diálogo padrão. Ajuste no formulário.")
    else
        love.graphics.setColor(0.20, 0.45, 0.25)
    end
    love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("+ Novo NPC", btnX + 14, btnY + 5)

    love.graphics.setFont(State.fonts.name)
    local cardH = 38
    local cardY = ly + 40
    for i, id in ipairs(edit.listOrder) do
        local def = State.npcFull[id]
        local cx, cy = lx + 6, cardY + (i - 1) * (cardH + 4)
        if cy + cardH > ly + lh then break end
        local cw = lw - 12
        if pointIn(mx, my, cx, cy, cw, cardH) then
            Tooltip.hover("Selecionar para editar.")
        end
        if id == edit.id then
            love.graphics.setColor(0.22, 0.34, 0.55)
        else
            love.graphics.setColor(0.13, 0.15, 0.20)
        end
        love.graphics.rectangle("fill", cx, cy, cw, cardH, 4, 4)
        love.graphics.setColor(0.35, 0.40, 0.50)
        love.graphics.rectangle("line", cx, cy, cw, cardH, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(def.name or id, cx + 6, cy + 4)
        love.graphics.setColor(0.7, 0.75, 0.85)
        local nodeCount = 0
        for _ in pairs(def.dialog or {}) do nodeCount = nodeCount + 1 end
        love.graphics.print(string.format("%s · %d nós", id, nodeCount),
            cx + 6, cy + 20)
    end

    if #edit.listOrder == 0 then
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.printf("Nenhum NPC.\nClique em \"+ Novo NPC\".",
            lx + 12, ly + 80, lw - 24, "center")
    end
end

local function fieldBox(x, y, w, h, focused)
    love.graphics.setColor(focused and 0.20 or 0.13,
                           focused and 0.25 or 0.15,
                           focused and 0.32 or 0.20)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    love.graphics.setColor(focused and 0.7 or 0.4, 0.5, 0.7)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)
end

local function drawText(row, def)
    local fx, fy, fw = formRect()
    love.graphics.setColor(0.7, 0.75, 0.85)
    love.graphics.print(row.label, row.x, row.y + 6)
    local tx = row.x + LABEL_W
    local tw = row.w - LABEL_W
    local key = row.name
    if row.optIdx then key = key .. ":" .. row.optIdx end
    local focused = State.editorFocus == ("npc:" .. key)
    fieldBox(tx, row.y, tw, row.h, focused)
    love.graphics.setColor(row.readOnly and 0.6 or 1, row.readOnly and 0.6 or 1, 1)
    local txt = tostring(row.value or "")
    if focused and (math.floor(love.timer.getTime() * 2) % 2) == 0 then
        txt = txt .. "_"
    end
    if row.multi then
        love.graphics.printf(txt, tx + 6, row.y + 6, tw - 12, "left")
    else
        love.graphics.print(txt, tx + 6, row.y + 6)
    end
    if row.tip and pointIn(State.mouse.x, State.mouse.y, tx, row.y, tw, row.h) then
        Tooltip.hover(row.tip)
    end
end

local function drawSelect(row)
    love.graphics.setColor(0.7, 0.75, 0.85)
    love.graphics.print(row.label, row.x, row.y + 6)
    local sx = row.x + LABEL_W
    local sw = row.w - LABEL_W
    local n = #row.options
    local btnW = math.max(60, math.floor(sw / n) - 4)
    local x = sx
    for _, opt in ipairs(row.options) do
        local lbl = (row.optionLabels and row.optionLabels[opt]) or opt
        local active = (row.value or "") == opt
        if active then
            love.graphics.setColor(0.25, 0.42, 0.65)
        else
            love.graphics.setColor(0.13, 0.15, 0.20)
        end
        love.graphics.rectangle("fill", x, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(0.4, 0.5, 0.6)
        love.graphics.rectangle("line", x, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(lbl, x + 4, row.y + 6, btnW - 8, "center")
        if pointIn(State.mouse.x, State.mouse.y, x, row.y, btnW, row.h) then
            Tooltip.hover((row.optionTips and row.optionTips[opt]) or row.tip or "")
        end
        x = x + btnW + 4
    end
end

local function drawSelectNode(row)
    love.graphics.setColor(0.7, 0.75, 0.85)
    love.graphics.print(row.label, row.x, row.y + 6)
    local sx = row.x + LABEL_W
    local sw = row.w - LABEL_W
    local choices = { "end" }
    for _, id in ipairs(row.nodeIDs) do
        if id ~= "start" then -- start raramente é destino
            choices[#choices + 1] = id
        end
    end
    -- Sempre incluir start no fim (caso o designer queira loopar)
    choices[#choices + 1] = "start"
    local btnW = math.max(48, math.floor(sw / #choices) - 4)
    local x = sx
    for _, opt in ipairs(choices) do
        local active = (row.value or "") == opt or
                       (row.value == "" and opt == "end")
        if active then
            love.graphics.setColor(0.25, 0.42, 0.65)
        else
            love.graphics.setColor(0.13, 0.15, 0.20)
        end
        love.graphics.rectangle("fill", x, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(0.4, 0.5, 0.6)
        love.graphics.rectangle("line", x, row.y, btnW, row.h, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(opt, x + 2, row.y + 6, btnW - 4, "center")
        x = x + btnW + 4
    end
    if row.tip and pointIn(State.mouse.x, State.mouse.y, sx, row.y, sw, row.h) then
        Tooltip.hover(row.tip)
    end
end

local function drawStepper(row)
    love.graphics.setColor(0.7, 0.75, 0.85)
    love.graphics.print(row.label, row.x, row.y + 6)
    local sx = row.x + LABEL_W
    local sw = row.w - LABEL_W
    local btnW = 24
    love.graphics.setColor(0.20, 0.30, 0.45)
    love.graphics.rectangle("fill", sx, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("-", sx + btnW / 2 - 4, row.y + 5)
    love.graphics.setColor(0.13, 0.15, 0.20)
    love.graphics.rectangle("fill", sx + btnW + 4, row.y, sw - btnW * 2 - 8, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(row.value), sx + btnW + 12, row.y + 5)
    love.graphics.setColor(0.20, 0.30, 0.45)
    love.graphics.rectangle("fill", sx + sw - btnW, row.y, btnW, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("+", sx + sw - btnW + btnW / 2 - 4, row.y + 5)
end

local function drawNodeBar(row, def)
    local x = row.x
    local h = row.h
    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", row.x, row.y, row.w, h, 4, 4)

    local cur = x + 4
    for _, id in ipairs(row.ids) do
        local lw = State.fonts.ui:getWidth(id) + 14
        if cur + lw > row.x + row.w - 50 then break end
        local active = id == edit.selectedNode
        if active then
            love.graphics.setColor(0.25, 0.42, 0.65)
        else
            love.graphics.setColor(0.13, 0.15, 0.20)
        end
        love.graphics.rectangle("fill", cur, row.y + 2, lw, h - 4, 4, 4)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(id, cur + 7, row.y + 5)
        cur = cur + lw + 4
    end

    -- Botões "+ Nó" e "Excluir nó" alinhados à direita.
    local addW, delW = 48, 78
    local addX = row.x + row.w - addW - delW - 8
    local delX = row.x + row.w - delW - 4
    love.graphics.setColor(0.20, 0.45, 0.25)
    love.graphics.rectangle("fill", addX, row.y + 2, addW, h - 4, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("+ Nó", addX + 6, row.y + 5)
    if pointIn(State.mouse.x, State.mouse.y, addX, row.y, addW, h) then
        Tooltip.hover("Cria um novo nó vazio na árvore deste NPC.")
    end

    love.graphics.setColor(edit.selectedNode == "start" and 0.30 or 0.55, 0.20, 0.20)
    love.graphics.rectangle("fill", delX, row.y + 2, delW, h - 4, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Excluir nó", delX + 6, row.y + 5)
    if pointIn(State.mouse.x, State.mouse.y, delX, row.y, delW, h) then
        Tooltip.hover(edit.selectedNode == "start"
            and "O nó 'start' é obrigatório e não pode ser removido."
            or  "Remove o nó selecionado e quaisquer opções que apontam para ele.")
    end
end

local function drawSeparator(row)
    love.graphics.setColor(0.5, 0.6, 0.8)
    love.graphics.print(row.label or "", row.x, row.y + 4)
    love.graphics.setColor(0.3, 0.4, 0.6, 0.6)
    love.graphics.rectangle("fill", row.x + 80, row.y + 12, row.w - 80, 1)
end

local function drawOptHeader(row)
    love.graphics.setColor(0.55, 0.7, 0.95)
    love.graphics.print(row.label, row.x, row.y + 2)
    love.graphics.setColor(0.3, 0.4, 0.6, 0.4)
    love.graphics.rectangle("fill", row.x + 80, row.y + 8, row.w - 80, 1)
end

local function drawOptRemove(row)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local w, h = 130, row.h
    local x = row.x + row.w - w
    local hover = pointIn(mx, my, x, row.y, w, h)
    love.graphics.setColor(hover and 0.55 or 0.40, 0.20, 0.20)
    love.graphics.rectangle("fill", x, row.y, w, h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("× Remover opção", x + 8, row.y + 3)
    if hover then Tooltip.hover("Remove esta opção do nó.") end
end

local function drawButton(row)
    local mx, my = State.mouse.x or 0, State.mouse.y or 0
    local hover = pointIn(mx, my, row.x, row.y, row.w, row.h)
    love.graphics.setColor(row.color)
    love.graphics.rectangle("fill", row.x, row.y, row.w, row.h, 4, 4)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("line", row.x, row.y, row.w, row.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(row.label, row.x + 6, row.y + (row.h - 14) / 2,
        row.w - 12, "center")
    if hover and row.tip then Tooltip.hover(row.tip) end
end

local function drawForm()
    local fx, fy, fw, fh = formRect()
    love.graphics.setColor(0.06, 0.07, 0.10)
    love.graphics.rectangle("fill", fx, fy, fw, fh, 4, 4)
    love.graphics.setColor(0.3, 0.4, 0.6)
    love.graphics.rectangle("line", fx, fy, fw, fh, 4, 4)

    local def = current()
    if not def then
        love.graphics.setFont(State.fonts.ui)
        love.graphics.setColor(0.7, 0.75, 0.85)
        love.graphics.printf(
            "Selecione um NPC à esquerda ou clique em \"+ Novo NPC\".",
            fx + 16, fy + 24, fw - 32, "left")
        return
    end

    -- Recortar o desenho à área do formulário (rolagem).
    love.graphics.push()
    love.graphics.setScissor(fx + 1, fy + 1, fw - 2, fh - 2)

    love.graphics.setFont(State.fonts.ui)
    local rows = formFields(def)
    for _, r in ipairs(rows) do
        if     r.type == "text"        then drawText(r, def)
        elseif r.type == "select"      then drawSelect(r)
        elseif r.type == "select_node" then drawSelectNode(r)
        elseif r.type == "stepper"     then drawStepper(r)
        elseif r.type == "node_bar"    then drawNodeBar(r, def)
        elseif r.type == "separator"   then drawSeparator(r)
        elseif r.type == "opt_header"  then drawOptHeader(r)
        elseif r.type == "opt_remove"  then drawOptRemove(r)
        elseif r.type == "button"      then drawButton(r)
        end
    end

    love.graphics.setScissor()
    love.graphics.pop()
end

function M.drawContent()
    ensureSelection()
    drawList()
    drawForm()
end

M.panelRect = panelRect
M.listRect  = listRect
M.formRect  = formRect

-- ---------------------------------------------------------------------------
-- Mutations: aplicam mudanças no def em memória; o caller decide quando
-- gravar com registerWithServer (em "Salvar" ou em mudanças estruturais).
-- ---------------------------------------------------------------------------

local function setFocus(field, optIdx)
    local key = field
    if optIdx then key = key .. ":" .. optIdx end
    State.editorFocus = "npc:" .. key
end

local function focusedKey()
    if not State.editorFocus then return nil end
    local k = State.editorFocus:match("^npc:(.+)$")
    return k
end

local function focusedField()
    local k = focusedKey()
    if not k then return nil end
    local name, idx = k:match("^([^:]+):(%d+)$")
    if name then return name, tonumber(idx) end
    return k, nil
end

-- ---------------------------------------------------------------------------
-- Click handling. Cada widget identifica o que foi clicado e ou
-- atualiza o def + persiste, ou só seta foco para captura de texto.
-- ---------------------------------------------------------------------------

-- Forward declaration: selectClick/stepperClick chamam applyValue, que
-- precisa do contexto do def + estado de seleção; declarado como local
-- para não vazar globals.
local applyValue

local function listClick(x, y)
    local lx, ly, lw, lh = listRect()
    if not pointIn(x, y, lx, ly, lw, lh) then return false end
    if pointIn(x, y, lx + 6, ly + 6, lw - 12, 26) then
        local def = newDef()
        State.npcFull[def.id] = def
        edit.id = def.id
        edit.selectedNode = "start"
        edit.scroll = 0
        State.editorFocus = nil
        registerWithServer(def)
        return true
    end
    local cardH = 38
    local cardY = ly + 40
    for i, id in ipairs(edit.listOrder) do
        local cx, cy = lx + 6, cardY + (i - 1) * (cardH + 4)
        if cy + cardH > ly + lh then break end
        if pointIn(x, y, cx, cy, lw - 12, cardH) then
            edit.id = id
            edit.selectedNode = "start"
            edit.scroll = 0
            State.editorFocus = nil
            return true
        end
    end
    return true
end

local function nodeBarClick(row, x, y, def)
    local cur = row.x + 4
    for _, id in ipairs(row.ids) do
        local lw = State.fonts.ui:getWidth(id) + 14
        if pointIn(x, y, cur, row.y + 2, lw, row.h - 4) then
            edit.selectedNode = id
            State.editorFocus = nil
            return true
        end
        cur = cur + lw + 4
    end
    local addW, delW = 48, 78
    local addX = row.x + row.w - addW - delW - 8
    local delX = row.x + row.w - delW - 4
    if pointIn(x, y, addX, row.y + 2, addW, row.h - 4) then
        local taken = {}
        for k in pairs(def.dialog) do taken[k] = true end
        local nid = uniqueID("node", taken)
        def.dialog[nid] = {
            text = "Texto do nó.",
            options = {
                { text = "Voltar.", next_node = "start", hook = {} },
            },
            on_enter = {},
        }
        edit.selectedNode = nid
        registerWithServer(def)
        return true
    end
    if pointIn(x, y, delX, row.y + 2, delW, row.h - 4) then
        if edit.selectedNode ~= "start" then
            local removed = edit.selectedNode
            def.dialog[removed] = nil
            -- Limpar opções que apontavam para o nó removido.
            for _, n in pairs(def.dialog) do
                for _, opt in ipairs(n.options or {}) do
                    if opt.next_node == removed then
                        opt.next_node = "end"
                    end
                end
            end
            edit.selectedNode = "start"
            registerWithServer(def)
        end
        return true
    end
    return true -- absorve o clique dentro da barra
end

local function selectClick(row, x, y, def)
    local sx = row.x + LABEL_W
    local sw = row.w - LABEL_W
    local n = #row.options
    local btnW = math.max(60, math.floor(sw / n) - 4)
    local cx = sx
    for _, opt in ipairs(row.options) do
        if pointIn(x, y, cx, row.y, btnW, row.h) then
            applyValue(row, opt, def)
            return true
        end
        cx = cx + btnW + 4
    end
    return false
end

-- selectNodeClick é como selectClick, mas para a lista dinâmica de nodes.
local function selectNodeClick(row, x, y, def)
    local sx = row.x + LABEL_W
    local sw = row.w - LABEL_W
    local choices = { "end" }
    for _, id in ipairs(row.nodeIDs) do
        if id ~= "start" then choices[#choices + 1] = id end
    end
    choices[#choices + 1] = "start"
    local btnW = math.max(48, math.floor(sw / #choices) - 4)
    local cx = sx
    for _, opt in ipairs(choices) do
        if pointIn(x, y, cx, row.y, btnW, row.h) then
            applyValue(row, opt, def)
            return true
        end
        cx = cx + btnW + 4
    end
    return false
end

-- stepperClick aumenta/diminui o valor numérico.
local function stepperClick(row, x, y, def)
    local sx = row.x + LABEL_W
    local sw = row.w - LABEL_W
    local btnW = 24
    local function delta(d)
        local v = (row.value or 0) + d * row.step
        if v < row.min then v = row.min end
        if v > row.max then v = row.max end
        applyValue(row, v, def)
    end
    if pointIn(x, y, sx, row.y, btnW, row.h) then
        delta(-1); return true
    end
    if pointIn(x, y, sx + sw - btnW, row.y, btnW, row.h) then
        delta(1); return true
    end
    return false
end

-- applyValue centraliza a aplicação do valor de cada widget no def.
-- Cabeçalho do NPC (id/name/title), node, opções, hooks: tudo passa aqui.
applyValue = function(row, value, def)
    local node = def.dialog[edit.selectedNode]
    local opt = row.optIdx and node and node.options and node.options[row.optIdx]

    if     row.name == "name"  then def.name  = tostring(value); registerWithServer(def)
    elseif row.name == "title" then def.title = tostring(value); registerWithServer(def)
    elseif row.name == "node_text" then
        if node then node.text = tostring(value); registerWithServer(def) end
    elseif row.name == "node_oe_type" then
        node.on_enter = node.on_enter or {}
        node.on_enter.type = value
        if value == "" then node.on_enter = {} end
        registerWithServer(def)
    elseif row.name == "node_oe_quest" then node.on_enter.quest = value; registerWithServer(def)
    elseif row.name == "node_oe_stage" then node.on_enter.stage = value; registerWithServer(def)
    elseif row.name == "node_oe_item"  then node.on_enter.item  = value; registerWithServer(def)
    elseif row.name == "node_oe_qty"   then node.on_enter.qty   = value; registerWithServer(def)
    elseif row.name == "opt_text" and opt then opt.text = value; registerWithServer(def)
    elseif row.name == "opt_next" and opt then opt.next_node = value; registerWithServer(def)
    elseif row.name == "opt_hook_type" and opt then
        opt.hook = opt.hook or {}
        opt.hook.type = value
        if value == "" then opt.hook = {} end
        registerWithServer(def)
    elseif row.name == "opt_hook_quest" and opt then opt.hook.quest = value; registerWithServer(def)
    elseif row.name == "opt_hook_stage" and opt then opt.hook.stage = value; registerWithServer(def)
    elseif row.name == "opt_hook_item"  and opt then opt.hook.item  = value; registerWithServer(def)
    elseif row.name == "opt_hook_qty"   and opt then opt.hook.qty   = value; registerWithServer(def)
    end
end

local function formClick(x, y)
    local fx, fy, fw, fh = formRect()
    if not pointIn(x, y, fx, fy, fw, fh) then return false end
    local def = current()
    if not def then return true end

    local rows = formFields(def)
    for _, r in ipairs(rows) do
        if r.type == "text" then
            local tx = r.x + LABEL_W
            local tw = r.w - LABEL_W
            if pointIn(x, y, tx, r.y, tw, r.h) then
                if not r.readOnly then
                    setFocus(r.name, r.optIdx)
                end
                return true
            end
        elseif r.type == "select" then
            if selectClick(r, x, y, def) then
                State.editorFocus = nil
                return true
            end
        elseif r.type == "select_node" then
            if selectNodeClick(r, x, y, def) then
                State.editorFocus = nil
                return true
            end
        elseif r.type == "stepper" then
            if stepperClick(r, x, y, def) then
                State.editorFocus = nil
                return true
            end
        elseif r.type == "node_bar" then
            if pointIn(x, y, r.x, r.y, r.w, r.h) then
                return nodeBarClick(r, x, y, def)
            end
        elseif r.type == "opt_remove" then
            local w = 130
            local rx = r.x + r.w - w
            if pointIn(x, y, rx, r.y, w, r.h) then
                local node = def.dialog[edit.selectedNode]
                if node and node.options and node.options[r.optIdx] then
                    table.remove(node.options, r.optIdx)
                    registerWithServer(def)
                end
                return true
            end
        elseif r.type == "button" then
            if pointIn(x, y, r.x, r.y, r.w, r.h) then
                if r.name == "add_option" then
                    local node = def.dialog[edit.selectedNode]
                    node.options = node.options or {}
                    node.options[#node.options + 1] = {
                        text = "Nova resposta", next_node = "end", hook = {},
                    }
                    registerWithServer(def)
                elseif r.name == "save" then
                    registerWithServer(def)
                elseif r.name == "delete" then
                    local id = def.id
                    State.npcFull[id] = nil
                    State.npcDefs[id] = nil
                    edit.id = nil
                    edit.selectedNode = "start"
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

function M.wheelmoved(_, dy)
    local fx, fy, fw, fh = formRect()
    if not pointIn(State.mouse.x, State.mouse.y, fx, fy, fw, fh) then return end
    edit.scroll = edit.scroll - dy * 24
    if edit.scroll < 0 then edit.scroll = 0 end
end

function M.textinput(t)
    local def = current()
    if not def then return false end
    local field, idx = focusedField()
    if not field then return false end
    if not t:match("[%w _%-%.,;:!%?%(%)/]") then return true end
    local node = def.dialog[edit.selectedNode]
    local opt = idx and node and node.options and node.options[idx]

    local function append(prev) return (prev or "") .. t end

    if field == "name"  then def.name  = append(def.name)
    elseif field == "title" then def.title = append(def.title)
    elseif field == "node_id" and edit.selectedNode ~= "start" then
        if t:match("[%w_%-]") then
            local newId = append(edit.selectedNode)
            -- só renomeia visualmente; commit no enter via applyValue.
            -- Aqui mantemos o nome local do nó até o usuário confirmar.
            -- Para UX simples, renomeia direto agora se válido.
            if not def.dialog[newId] then
                def.dialog[newId] = def.dialog[edit.selectedNode]
                def.dialog[edit.selectedNode] = nil
                local old = edit.selectedNode
                edit.selectedNode = newId
                for _, n in pairs(def.dialog) do
                    for _, o in ipairs(n.options or {}) do
                        if o.next_node == old then o.next_node = newId end
                    end
                end
            end
        end
    elseif field == "node_text" and node then
        node.text = append(node.text)
    elseif field == "node_oe_quest" and node then node.on_enter.quest = append(node.on_enter.quest)
    elseif field == "node_oe_stage" and node then node.on_enter.stage = append(node.on_enter.stage)
    elseif field == "node_oe_item"  and node then node.on_enter.item  = append(node.on_enter.item)
    elseif field == "opt_text"  and opt then opt.text = append(opt.text)
    elseif field == "opt_hook_quest" and opt then opt.hook.quest = append(opt.hook.quest)
    elseif field == "opt_hook_stage" and opt then opt.hook.stage = append(opt.hook.stage)
    elseif field == "opt_hook_item"  and opt then opt.hook.item  = append(opt.hook.item)
    end
    return true
end

local function backspaceField(def)
    local field, idx = focusedField()
    if not field then return end
    local node = def.dialog[edit.selectedNode]
    local opt = idx and node and node.options and node.options[idx]
    local function chop(s) return (s or ""):sub(1, -2) end
    if     field == "name"  then def.name  = chop(def.name)
    elseif field == "title" then def.title = chop(def.title)
    elseif field == "node_text"      and node then node.text = chop(node.text)
    elseif field == "node_oe_quest"  and node then node.on_enter.quest = chop(node.on_enter.quest)
    elseif field == "node_oe_stage"  and node then node.on_enter.stage = chop(node.on_enter.stage)
    elseif field == "node_oe_item"   and node then node.on_enter.item  = chop(node.on_enter.item)
    elseif field == "opt_text"       and opt then opt.text = chop(opt.text)
    elseif field == "opt_hook_quest" and opt then opt.hook.quest = chop(opt.hook.quest)
    elseif field == "opt_hook_stage" and opt then opt.hook.stage = chop(opt.hook.stage)
    elseif field == "opt_hook_item"  and opt then opt.hook.item  = chop(opt.hook.item)
    end
end

function M.keypressed(key)
    local def = current()
    if not def then return false end
    if not State.editorFocus then return false end
    if key == "backspace" then
        backspaceField(def)
        return true
    elseif key == "return" or key == "kpenter" then
        registerWithServer(def)
        State.editorFocus = nil
        return true
    end
    return true
end

return M
