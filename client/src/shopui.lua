local State = require('src.state')
local Network = require('src.network')

local M = {}

local function pointIn(px,py,x,y,w,h) return px>=x and py>=y and px<x+w and py<y+h end

function M.draw()
  local sh = State.shop
  if not sh or not sh.open or not sh.def then return end
  local sw,shh = love.graphics.getDimensions()
  local w,h = math.min(920, sw-80), math.min(560, shh-80)
  local x,y = (sw-w)/2,(shh-h)/2
  love.graphics.setColor(0,0,0,0.55); love.graphics.rectangle('fill',0,0,sw,shh)
  love.graphics.setColor(0.08,0.1,0.15,0.98); love.graphics.rectangle('fill',x,y,w,h,8,8)
  love.graphics.setColor(0.4,0.6,0.9); love.graphics.rectangle('line',x,y,w,h,8,8)
  love.graphics.setColor(1,1,1); love.graphics.setFont(State.fonts.title)
  love.graphics.print('Loja: '..(sh.def.name or sh.id), x+16, y+12)
  love.graphics.setFont(State.fonts.ui)
  love.graphics.print('Gold: '..tostring(State.character.gold or 0), x+w-160, y+16)
  local ly = y+56
  for i,it in ipairs(sh.def.items or {}) do
    local ry = ly + (i-1)*28
    love.graphics.setColor(0.16,0.2,0.28); love.graphics.rectangle('fill', x+16, ry, w-32, 24, 4,4)
    love.graphics.setColor(1,1,1)
    love.graphics.print(string.format('%02d  %s  x%d  %dg', i, it.item_id or '?', it.qty or 0, it.price or 0), x+24, ry+4)
  end
end

function M.mousepressed(x,y,b)
  local sh = State.shop
  if not sh or not sh.open or not sh.def then return false end
  local sw,shh = love.graphics.getDimensions(); local w,h = math.min(920, sw-80), math.min(560, shh-80)
  local px,py = (sw-w)/2,(shh-h)/2
  if not pointIn(x,y,px,py,w,h) then sh.open=false return true end
  if b==1 then
    local ly = py+56
    for i,it in ipairs(sh.def.items or {}) do
      local ry = ly + (i-1)*28
      if pointIn(x,y,px+16,ry,w-32,24) then
        Network.send(string.format('SHOP_BUY %s %d 1', sh.id, i-1))
        return true
      end
    end
  elseif b==2 then
    Network.send('SHOP_CLOSE')
    sh.open=false
    return true
  end
  return true
end

function M.keypressed(key)
  if State.shop and State.shop.open and key=='escape' then
    State.shop.open=false
    Network.send('SHOP_CLOSE')
    return true
  end
  return false
end

return M
