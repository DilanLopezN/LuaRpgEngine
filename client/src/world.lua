-- MOBA-style camera projection: axis-aligned tiles squashed vertically
-- to simulate a fixed downward-tilted camera. World tiles are rendered as
-- rectangles (not isometric diamonds), so movement is on a true 2D grid
-- like Tibia, but the squash gives the angled-camera feel of a MOBA.

local M = {}

M.TILE_W = 64
M.TILE_H = 40   -- squashed: ~0.625 ratio, like a 50-60 deg camera tilt

function M.toScreen(x, y)
    return x * M.TILE_W, y * M.TILE_H
end

function M.tileCenter(tx, ty)
    return (tx + 0.5) * M.TILE_W, (ty + 0.5) * M.TILE_H
end

function M.fillTile(tx, ty)
    love.graphics.rectangle("fill",
        tx * M.TILE_W, ty * M.TILE_H, M.TILE_W, M.TILE_H)
end

function M.outlineTile(tx, ty)
    love.graphics.rectangle("line",
        tx * M.TILE_W, ty * M.TILE_H, M.TILE_W, M.TILE_H)
end

return M
