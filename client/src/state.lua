local M = {}

M.SCENE_NAME       = "name"
M.SCENE_CONNECTING = "connecting"
M.SCENE_PLAYING    = "playing"

M.scene       = M.SCENE_NAME
M.nameInput   = ""
M.status      = "Enter your name"
M.serverHost  = "127.0.0.1"
M.serverPort  = 7777
M.mapSize     = 8
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
M.editorTab      = "spells"
M.editorSelected = nil
M.editorFocus    = nil

M.fonts = {}

return M
