local State=require('src.state')
local Layout=require('src.editor_layout')
local JSON=require('src.json')
local Network=require('src.network')

local M={}

local function ensure()
  State.shopEditor=State.shopEditor or {draft={id='',name='Loja',buy_multiplier=0.5,items={}},status=''}
end

function M.drawContent()
  ensure()
  local d=State.shopEditor.draft
  local x,y,w,h=Layout.contentRect()
  love.graphics.setColor(0.07,0.09,0.12); love.graphics.rectangle('fill',x+12,y+12,w-24,h-24,6,6)
  love.graphics.setColor(1,1,1); love.graphics.setFont(State.fonts.ui)
  love.graphics.print('Editor de Lojas (base)',x+24,y+24)
  love.graphics.print('ID: '..(d.id or ''),x+24,y+52)
  love.graphics.print('Nome: '..(d.name or ''),x+24,y+74)
  love.graphics.print('Itens: '..tostring(#(d.items or {})),x+24,y+96)
  love.graphics.print('Use S para salvar draft rápido',x+24,y+126)
  if State.shopEditor.status~='' then love.graphics.print(State.shopEditor.status,x+24,y+152) end
end

function M.keypressed(key)
  ensure()
  if key=='s' and (love.keyboard.isDown('lctrl','rctrl') or true) then
    local d=State.shopEditor.draft
    if d.id=='' then d.id='shop_'..os.time() end
    Network.send('SAVE_SHOP_DEF '..JSON.encode(d))
    State.shopEditor.status='Enviado SAVE_SHOP_DEF '..d.id
    return true
  end
  return false
end

function M.mousepressedContent() return true end
return M
