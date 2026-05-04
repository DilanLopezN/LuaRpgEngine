local M = {}

M.SCENE_NAME       = "name"
M.SCENE_CONNECTING = "connecting"
M.SCENE_PLAYING    = "playing"

M.scene       = M.SCENE_NAME
M.nameInput   = ""
M.status      = "Digite seu nome"
M.serverHost  = "127.0.0.1"
M.serverPort  = 7777
M.mapSize     = 20
M.mapWidth    = 20
M.mapHeight   = 20
-- Phase 2 — name of the map the player is currently on. Updated by
-- WELCOME (defaults to "world") and re-set by MAP_CHANGE on warp.
M.currentMapName = "world"
M.myId        = nil
M.myName      = nil
M.players     = {}
M.enemies     = {}
M.npcs        = {}
M.camera      = { x = 0, y = 0 }
M.lastSent    = { dx = 0, dy = 0 }
M.skillbar    = { nil, nil, nil, nil, nil }
M.activeSpells = {}
M.drag        = nil
M.mouse       = { x = 0, y = 0 }

M.editorOpen     = false
M.editorTab      = "map"   -- "map" | "spells" | "npcs" | "quests"
M.editorSelected = nil
M.editorFocus    = nil

-- Movable panel geometry. Initialized lazily by editor_layout.ensureInit().
M.editorPanel = {
    x = 0, y = 0, w = 0, h = 0,
    initialized = false,
}
-- When the user grabs the title bar, this stores the click offset within the
-- panel so dragging keeps the cursor anchored to the same spot.
M.editorDrag = nil

-- Map editor state. The editor reads `Map.current` directly for tile data
-- and only keeps tool/UI selection here.
M.mapEditor = {
    tool          = "paint",     -- paint | fill | erase | select | entity
    layer         = "ground",    -- ground | decoration | collision | logic
    tilesetIndex  = 1,           -- 1-based index into Tilesets.list()
    tileIndex     = 0,           -- 0-based tile inside that tileset
    showGrid      = true,
    paintingButton = nil,        -- 1=paint, 2=erase while dragging
    selection     = nil,         -- { x1, y1, x2, y2 }
    selectionStart = nil,        -- drag origin during a select drag
    clipboard     = nil,         -- { w, h, layers = { name -> grid } }
    entityType    = "spawn",
    entityKind    = "orc",
    -- Phase 2 — when entityType=trigger and entityKind=warp, these
    -- fields are written into the placed entity so the server knows
    -- where to teleport the player.
    warpTargetMap = "world",
    warpTargetX   = 0,
    warpTargetY   = 0,
    pendingSave   = false,
    saveStatus    = "",
    paletteScroll = 0,
    history       = {},          -- undo stack of map snapshots
    redo          = {},
    activeStroke  = nil,         -- snapshot pushed at drag start
}

-- NPC editor (Criar NPCs tab). Tem três regiões:
--   draft        → o NPC sendo editado no formulário
--   placement    → o que será posicionado ao clicar no mundo
--   selectedId   → id do NPC selecionado no catálogo (esquerda)
-- O catálogo em si (lista de NPCs) é alimentado por State.npcDefs, que o
-- servidor envia via NPC_DEF.
M.npcEditor = {
    spriteId      = "npc_knight",    -- legacy: usado como sprite default
    saveStatus    = "",
    formScroll    = 0,
    catalogScroll = 0,
    listScroll    = 0,
    paletteScroll = 0,
    selectedId    = nil,
    placement     = { kind = "", sprite = "" },
    draft         = nil,             -- preenchido por ensureEditorState()
}

-- Quest editor (Criar Quests tab). Mesmo padrão do npcEditor: catálogo
-- à esquerda alimentado por State.questDefs (servidor envia QUEST_DEF
-- JSON), formulário central com a quest sendo editada, draft local
-- até clicar Salvar (manda SAVE_QUEST_DEF).
M.questEditor = {
    saveStatus    = "",
    formScroll    = 0,
    catalogScroll = 0,
    selectedId    = nil,
    draft         = nil,
}

-- Item editor (Criar Itens tab). Mesmo padrão dos editores acima:
--   catálogo  → State.itemDefs (alimentado por ITEM_DEF JSON)
--   draft     → cópia local do item sendo editado
--   selected  → id do item selecionado no catálogo
-- Persistência via SAVE_ITEM_DEF / DELETE_ITEM_DEF.
M.itemEditor = {
    saveStatus    = "",
    formScroll    = 0,
    catalogScroll = 0,
    selectedId    = nil,
    draft         = nil,
}

-- Phase 4 — character sheet. Populated by STATS / SKILL_POINTS frames.
M.character = {
    level = 1,
    xp    = 0,
    nextX = 0,
    str   = 0, dex = 0, intel = 0, vit = 0,
    gold  = 0,
    skillPoints = 0,
}

-- Phase 4 — inventory and equipment. INV_SET / EQUIP_SET rebuild these.
M.inventory = {}            -- list of { id, qty }
M.equipped  = {}            -- slot -> id
M.itemDefs  = {}            -- id -> { name, slot, rarity, stack, bound }
M.skillDefs = {}            -- id -> { name, type, dmg, mana, cd, range, radius }
M.learned   = {}            -- id -> true
M.npcDefs   = {}            -- id -> { name, title }
M.questDefs = {}            -- id -> { name, killTarget, killCount, ... }
M.quests    = {}            -- id -> { stage, killCount, done }

-- Phase 4 — chat and toast feeds.
M.chat = {
    open    = false,
    input   = "",
    history = {},   -- list of { kind, who, msg, t }
    max     = 60,
}
M.toasts = {}       -- list of { text, color, expires }

-- Phase 6 — floating combat text (números de dano/heal/mana sobem
-- acima das entidades). Lista de { kind, x, y, value, start, duration }.
M.fctEntries = {}

-- Phase 6 — captura de keybind em curso. Quando setado, inputBlocked()
-- retorna true e a UI pinta "Pressione uma tecla..." na linha da ação.
-- Estrutura: { action, startedAt, timeout }.
M.keybindCapture = nil

-- Phase 4 — active NPC dialog. Set by DIALOG / DIALOG_OPT.
M.dialog = nil      -- { npc, node, text, options = { { idx, text } } }

-- Phase 4 — character panel (F2) toggles.
M.charPanelOpen = false
M.charPanelTab  = "stats"  -- stats | inventory | quests

M.fonts = {}

return M
