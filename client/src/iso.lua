local M = {}

function M.toScreen(x, y, tw, th)
    return (x - y) * tw / 2, (x + y) * th / 2
end

function M.fillTile(cx, cy, tw, th)
    love.graphics.polygon("fill",
        cx,          cy - th / 2,
        cx + tw / 2, cy,
        cx,          cy + th / 2,
        cx - tw / 2, cy)
end

function M.outlineTile(cx, cy, tw, th)
    love.graphics.polygon("line",
        cx,          cy - th / 2,
        cx + tw / 2, cy,
        cx,          cy + th / 2,
        cx - tw / 2, cy)
end

return M
