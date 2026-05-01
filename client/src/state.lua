local M = {}

M.SCENE_NAME       = "name"
M.SCENE_CONNECTING = "connecting"
M.SCENE_PLAYING    = "playing"

M.scene       = M.SCENE_NAME
M.nameInput   = ""
M.status      = "Enter your name"
M.serverHost  = "127.0.0.1"
M.serverPort  = 7777
M.mapSize     = 20
M.mapWidth    = 20
M.mapHeight   = 20
M.myId        = nil
M.myName      = nil
M.players     = {}
M.enemies     = {}
M.camera      = { x = 0, y = 0 }
M.lastSent    = { dx = 0, dy = 0 }
M.skillbar    = { nil, nil, nil, nil, nil }
M.activeSpells = {}
M.drag        = nil
M.mouse       = { x = 0, y = 0 }

M.editorOpen     = false
M.editorTab      = "map"
M.editorSelected = nil
M.editorFocus    = nil

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
    pendingSave   = false,
    saveStatus    = "",
    paletteScroll = 0,
    history       = {},          -- undo stack of map snapshots
    redo          = {},
    activeStroke  = nil,         -- snapshot pushed at drag start
}

M.fonts = {}

return M
