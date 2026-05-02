-- Shared geometry for the F1 engine editor. Gives every tab module the same
-- panel, header, tab-bar, and content rectangles so dragging the panel via
-- editor.lua moves all of them in lockstep.

local State = require("src.state")

local M = {}

M.HEADER_H  = 48
M.TAB_H     = 36
M.MIN_W     = 720
M.MIN_H     = 480
M.DEFAULT_W = 1120
M.DEFAULT_H = 720
-- The editor used to ship at 820x540. We bumped both axes ~36% so the new
-- NPC tab (sprite picker + form + placement list) and the redesigned
-- header have room to breathe; smaller monitors still get clamped to
-- screen size minus a 40 px gutter via recenter().

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function M.recenter()
    local sw, sh = love.graphics.getDimensions()
    local p = State.editorPanel
    p.w = clamp(M.DEFAULT_W, M.MIN_W, sw - 40)
    p.h = clamp(M.DEFAULT_H, M.MIN_H, sh - 40)
    p.x = math.floor((sw - p.w) / 2)
    p.y = math.floor((sh - p.h) / 2)
    p.initialized = true
end

function M.ensureInit()
    if not State.editorPanel.initialized then M.recenter() end
end

-- Pull the panel back inside the screen if its title bar is no longer
-- reachable. Called when the editor opens so the user never gets stuck.
function M.ensureReachable()
    M.ensureInit()
    local sw, sh = love.graphics.getDimensions()
    local p = State.editorPanel
    local visibleX = math.min(p.x + p.w, sw) - math.max(p.x, 0)
    if visibleX < 80 then M.recenter(); return end
    local headerBottom = p.y + M.HEADER_H
    if headerBottom < 8 or p.y > sh - 8 then M.recenter() end
end

function M.panelRect()
    M.ensureInit()
    local p = State.editorPanel
    return p.x, p.y, p.w, p.h
end

function M.headerRect()
    local x, y, w = M.panelRect()
    return x, y, w, M.HEADER_H
end

function M.tabBarRect()
    local x, y, w = M.panelRect()
    return x, y + M.HEADER_H, w, M.TAB_H
end

function M.contentRect()
    local x, y, w, h = M.panelRect()
    local off = M.HEADER_H + M.TAB_H
    return x, y + off, w, h - off
end

return M
