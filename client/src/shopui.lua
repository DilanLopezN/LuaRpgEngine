-- Phase 3 — Shop / Mercador UI.
-- 2-column modal: shop stock (left) and player inventory (right). Click
-- a row on the left to BUY one unit; click on the right to SELL one
-- unit. Right-click anywhere closes the shop. The gold badge updates
-- on every SHOP_UPDATE / STATS frame the server pushes back.

local State   = require('src.state')
local Network = require('src.network')

local M = {}

local function pointIn(px, py, x, y, w, h)
  return px >= x and py >= y and px < x + w and py < y + h
end

local ROW_H = 28

local function frame()
  local sw, shh = love.graphics.getDimensions()
  local w = math.min(960, sw - 80)
  local h = math.min(580, shh - 80)
  local x = (sw - w) / 2
  local y = (shh - h) / 2
  return x, y, w, h
end

local function colWidth(w)
  return math.floor((w - 48) / 2)
end

local function itemLabel(id)
  local def = State.itemDefs[id]
  if def and def.name then return def.name end
  return id or '?'
end

function M.draw()
  local sh = State.shop
  if not sh or not sh.open or not sh.def then return end
  local x, y, w, h = frame()
  local cw = colWidth(w)

  love.graphics.setColor(0, 0, 0, 0.55)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

  love.graphics.setColor(0.08, 0.10, 0.15, 0.98)
  love.graphics.rectangle('fill', x, y, w, h, 8, 8)
  love.graphics.setColor(0.4, 0.6, 0.9)
  love.graphics.rectangle('line', x, y, w, h, 8, 8)

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(State.fonts.title)
  love.graphics.print('Loja: ' .. (sh.def.name or sh.id), x + 16, y + 12)
  love.graphics.setFont(State.fonts.ui)
  love.graphics.print('Gold: ' .. tostring(State.character.gold or 0),
                      x + w - 180, y + 18)
  love.graphics.print('Esc / clique fora fecha   |   esquerdo compra   |   direito vende',
                      x + 16, y + h - 22)

  -- Header bars
  local hy = y + 56
  love.graphics.setColor(0.12, 0.16, 0.22)
  love.graphics.rectangle('fill', x + 16, hy, cw, 22, 4, 4)
  love.graphics.rectangle('fill', x + 32 + cw, hy, cw, 22, 4, 4)
  love.graphics.setColor(0.85, 0.85, 0.85)
  love.graphics.print('Mercador', x + 24, hy + 4)
  love.graphics.print('Inventário', x + 40 + cw, hy + 4)

  -- Shop column (left) — buy
  local ly = hy + 30
  for i, it in ipairs(sh.def.items or {}) do
    local ry = ly + (i - 1) * ROW_H
    if ry + ROW_H > y + h - 30 then break end
    love.graphics.setColor(0.16, 0.20, 0.28)
    love.graphics.rectangle('fill', x + 16, ry, cw, ROW_H - 4, 4, 4)
    love.graphics.setColor(1, 1, 1)
    local stock = (it.max and it.max > 0) and string.format('%d/%d', it.qty or 0, it.max) or '∞'
    love.graphics.print(string.format('%02d  %s   x%s   %dg',
                                      i, itemLabel(it.item_id), stock, it.price or 0),
                        x + 24, ry + 6)
  end

  -- Inventory column (right) — sell
  for i, slot in ipairs(State.inventory or {}) do
    local ry = ly + (i - 1) * ROW_H
    if ry + ROW_H > y + h - 30 then break end
    love.graphics.setColor(0.16, 0.20, 0.28)
    love.graphics.rectangle('fill', x + 32 + cw, ry, cw, ROW_H - 4, 4, 4)
    love.graphics.setColor(1, 1, 1)
    local def = State.itemDefs[slot.id] or {}
    local price = def.value or 0
    local mult = sh.def.buy_multiplier or 0.5
    local pay = math.floor(price * mult)
    if pay <= 0 then pay = 1 end
    love.graphics.print(string.format('%02d  %s   x%d   +%dg',
                                      i, itemLabel(slot.id), slot.qty or 0, pay),
                        x + 40 + cw, ry + 6)
  end
end

local function rowAt(x, y, side, sh)
  local fx, fy, w, h = frame()
  local cw = colWidth(w)
  local ly = fy + 86
  local list = side == 'shop' and (sh.def.items or {}) or (State.inventory or {})
  local rx = side == 'shop' and (fx + 16) or (fx + 32 + cw)
  for i = 1, #list do
    local ry = ly + (i - 1) * ROW_H
    if ry + ROW_H > fy + h - 30 then break end
    if pointIn(x, y, rx, ry, cw, ROW_H - 4) then return i end
  end
  return nil
end

function M.mousepressed(x, y, b)
  local sh = State.shop
  if not sh or not sh.open or not sh.def then return false end
  local fx, fy, w, h = frame()
  if not pointIn(x, y, fx, fy, w, h) then
    sh.open = false
    Network.send('SHOP_CLOSE')
    return true
  end
  if b == 2 then
    sh.open = false
    Network.send('SHOP_CLOSE')
    return true
  end
  if b == 1 then
    local idx = rowAt(x, y, 'shop', sh)
    if idx then
      Network.send(string.format('SHOP_BUY %s %d 1', sh.id, idx - 1))
      return true
    end
    idx = rowAt(x, y, 'inventory', sh)
    if idx then
      Network.send(string.format('SHOP_SELL %d 1', idx - 1))
      return true
    end
  end
  return true
end

function M.keypressed(key)
  if State.shop and State.shop.open and key == 'escape' then
    State.shop.open = false
    Network.send('SHOP_CLOSE')
    return true
  end
  return false
end

return M
