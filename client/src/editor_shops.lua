-- Phase 3 — Editor de Lojas.
-- CRUD básico de ShopDef (id, nome, multiplier, lista de itens com qty/
-- price/restock_sec). O picker de item da Phase 1 escolhe o item_id de
-- cada slot — sem digitação à mão. SAVE_SHOP_DEF salva o draft no
-- servidor, que persiste em data/scripts/shops_user/<id>.json.

local State   = require('src.state')
local Layout  = require('src.editor_layout')
local JSON    = require('src.json')
local Network = require('src.network')
local Pickers = require('src.editor_pickers')

local M = {}

local function pointIn(px, py, x, y, w, h)
  return px >= x and py >= y and px < x + w and py < y + h
end

local function ensure()
  State.shopEditor = State.shopEditor or {
    draft  = { id = '', name = 'Loja', buy_multiplier = 0.5, items = {} },
    status = '',
  }
  local d = State.shopEditor.draft
  d.items = d.items or {}
  d.buy_multiplier = d.buy_multiplier or 0.5
end

local function newSlot()
  return { item_id = '', qty = 1, price = 1, restock_sec = 0 }
end

local ROW_H = 30

local function fieldRect(x, y, w, h)
  return { x = x, y = y, w = w, h = h }
end

-- Hit-target list rebuilt every draw. Editor field clicks consult this
-- to know what was hit without re-deriving rectangles in mousepressed.
local hits = {}

local function pushHit(kind, rect, payload)
  hits[#hits + 1] = { kind = kind, rect = rect, payload = payload }
end

function M.drawContent()
  ensure()
  hits = {}
  local d = State.shopEditor.draft
  local x, y, w, h = Layout.contentRect()

  love.graphics.setColor(0.07, 0.09, 0.12)
  love.graphics.rectangle('fill', x + 12, y + 12, w - 24, h - 24, 6, 6)
  love.graphics.setFont(State.fonts.ui)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Editor de Lojas', x + 24, y + 22)

  local label = function(text, lx, ly)
    love.graphics.setColor(0.7, 0.78, 0.9)
    love.graphics.print(text, lx, ly)
    love.graphics.setColor(1, 1, 1)
  end

  -- Header fields: id, name, buy_multiplier
  label('ID', x + 24, y + 56)
  local idR = fieldRect(x + 70, y + 50, 220, 26)
  love.graphics.setColor(0.13, 0.17, 0.23)
  love.graphics.rectangle('fill', idR.x, idR.y, idR.w, idR.h, 4, 4)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(d.id ~= '' and d.id or '(clique para id)', idR.x + 6, idR.y + 5)
  pushHit('field_id', idR)

  label('Nome', x + 310, y + 56)
  local nameR = fieldRect(x + 360, y + 50, 240, 26)
  love.graphics.setColor(0.13, 0.17, 0.23)
  love.graphics.rectangle('fill', nameR.x, nameR.y, nameR.w, nameR.h, 4, 4)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(d.name or '', nameR.x + 6, nameR.y + 5)
  pushHit('field_name', nameR)

  label('Sell mult', x + 620, y + 56)
  local mR = fieldRect(x + 690, y + 50, 80, 26)
  love.graphics.setColor(0.13, 0.17, 0.23)
  love.graphics.rectangle('fill', mR.x, mR.y, mR.w, mR.h, 4, 4)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(string.format('%.2f', d.buy_multiplier or 0.5), mR.x + 6, mR.y + 5)
  pushHit('field_mult', mR)

  -- Items header row.
  local lx = x + 24
  local ly = y + 96
  love.graphics.setColor(0.7, 0.78, 0.9)
  love.graphics.print('Item', lx + 36, ly)
  love.graphics.print('Qty', lx + 290, ly)
  love.graphics.print('Preço', lx + 360, ly)
  love.graphics.print('Restock(s)', lx + 440, ly)

  ly = ly + 22
  for i, slot in ipairs(d.items) do
    -- Index column.
    love.graphics.setColor(0.16, 0.20, 0.28)
    love.graphics.rectangle('fill', lx, ly, w - 56, ROW_H - 4, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format('%02d', i), lx + 6, ly + 6)

    -- Item picker button.
    local itemR = fieldRect(lx + 32, ly, 250, ROW_H - 4)
    love.graphics.setColor(0.10, 0.14, 0.20)
    love.graphics.rectangle('fill', itemR.x, itemR.y, itemR.w, itemR.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    local def = State.itemDefs[slot.item_id]
    local label2 = (def and def.name) or slot.item_id
    if not label2 or label2 == '' then label2 = '(escolher item)' end
    love.graphics.print(label2, itemR.x + 6, itemR.y + 6)
    pushHit('row_item', itemR, i)

    -- Qty / price / restock cells.
    local qR = fieldRect(lx + 286, ly, 60, ROW_H - 4)
    love.graphics.setColor(0.10, 0.14, 0.20)
    love.graphics.rectangle('fill', qR.x, qR.y, qR.w, qR.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(slot.qty or 0), qR.x + 6, qR.y + 6)
    pushHit('row_qty', qR, i)

    local pR = fieldRect(lx + 354, ly, 70, ROW_H - 4)
    love.graphics.setColor(0.10, 0.14, 0.20)
    love.graphics.rectangle('fill', pR.x, pR.y, pR.w, pR.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(slot.price or 0), pR.x + 6, pR.y + 6)
    pushHit('row_price', pR, i)

    local rR = fieldRect(lx + 432, ly, 80, ROW_H - 4)
    love.graphics.setColor(0.10, 0.14, 0.20)
    love.graphics.rectangle('fill', rR.x, rR.y, rR.w, rR.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(slot.restock_sec or 0), rR.x + 6, rR.y + 6)
    pushHit('row_restock', rR, i)

    -- Remove row button.
    local xR = fieldRect(lx + 524, ly, 28, ROW_H - 4)
    love.graphics.setColor(0.45, 0.18, 0.18)
    love.graphics.rectangle('fill', xR.x, xR.y, xR.w, xR.h, 4, 4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('×', xR.x + 10, xR.y + 6)
    pushHit('row_remove', xR, i)

    ly = ly + ROW_H
  end

  -- Add row + Save buttons.
  ly = ly + 8
  local addR = fieldRect(lx, ly, 110, 26)
  love.graphics.setColor(0.18, 0.30, 0.22)
  love.graphics.rectangle('fill', addR.x, addR.y, addR.w, addR.h, 4, 4)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('+ Adicionar item', addR.x + 6, addR.y + 5)
  pushHit('add_row', addR)

  local saveR = fieldRect(lx + 130, ly, 90, 26)
  love.graphics.setColor(0.20, 0.32, 0.50)
  love.graphics.rectangle('fill', saveR.x, saveR.y, saveR.w, saveR.h, 4, 4)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('Salvar (S)', saveR.x + 12, saveR.y + 5)
  pushHit('save', saveR)

  if (State.shopEditor.status or '') ~= '' then
    love.graphics.setColor(0.7, 0.85, 1.0)
    love.graphics.print(State.shopEditor.status, lx, ly + 36)
  end

  M.drawOverlay()
end

local function promptText(prompt, current, onCommit)
  -- Lightweight blocking-free prompt: stash the binding in shopEditor.input
  -- and let M.textinput / M.keypressed feed characters until Enter.
  State.shopEditor.input = {
    prompt = prompt, value = current or '', commit = onCommit,
  }
end

local function commitField(kind, idx, raw)
  local d = State.shopEditor.draft
  if kind == 'field_id' then
    d.id = raw:gsub('[^%w_%-]', '')
  elseif kind == 'field_name' then
    d.name = raw
  elseif kind == 'field_mult' then
    local v = tonumber(raw)
    if v and v > 0 then d.buy_multiplier = v end
  elseif kind == 'row_qty' then
    d.items[idx].qty = math.max(0, math.floor(tonumber(raw) or 0))
  elseif kind == 'row_price' then
    d.items[idx].price = math.max(0, math.floor(tonumber(raw) or 0))
  elseif kind == 'row_restock' then
    d.items[idx].restock_sec = math.max(0, math.floor(tonumber(raw) or 0))
  end
end

local function saveDraft()
  local d = State.shopEditor.draft
  if not d.id or d.id == '' then
    d.id = 'shop_' .. tostring(os.time())
  end
  Network.send('SAVE_SHOP_DEF ' .. JSON.encode(d))
  State.shopEditor.status = 'Enviado SAVE_SHOP_DEF ' .. d.id
end

function M.mousepressedContent(x, y, button)
  ensure()
  if button ~= 1 then return false end
  for _, h in ipairs(hits) do
    local r = h.rect
    if pointIn(x, y, r.x, r.y, r.w, r.h) then
      local d = State.shopEditor.draft
      if h.kind == 'field_id' then
        promptText('Shop ID', d.id, function(s) commitField('field_id', nil, s) end)
      elseif h.kind == 'field_name' then
        promptText('Nome', d.name, function(s) commitField('field_name', nil, s) end)
      elseif h.kind == 'field_mult' then
        promptText('Sell multiplier (0..1)', tostring(d.buy_multiplier or 0.5),
                   function(s) commitField('field_mult', nil, s) end)
      elseif h.kind == 'row_item' then
        local idx = h.payload
        Pickers.openItem(d.items[idx].item_id, function(id)
          if id then d.items[idx].item_id = id end
        end)
      elseif h.kind == 'row_qty' then
        local idx = h.payload
        promptText('Qty (0=∞)', tostring(d.items[idx].qty or 0),
                   function(s) commitField('row_qty', idx, s) end)
      elseif h.kind == 'row_price' then
        local idx = h.payload
        promptText('Preço', tostring(d.items[idx].price or 0),
                   function(s) commitField('row_price', idx, s) end)
      elseif h.kind == 'row_restock' then
        local idx = h.payload
        promptText('Restock seg', tostring(d.items[idx].restock_sec or 0),
                   function(s) commitField('row_restock', idx, s) end)
      elseif h.kind == 'row_remove' then
        table.remove(d.items, h.payload)
      elseif h.kind == 'add_row' then
        d.items[#d.items + 1] = newSlot()
      elseif h.kind == 'save' then
        saveDraft()
      end
      return true
    end
  end
  return true
end

function M.keypressed(key)
  ensure()
  local inp = State.shopEditor.input
  if inp then
    if key == 'escape' then
      State.shopEditor.input = nil
      return true
    elseif key == 'return' or key == 'kpenter' then
      inp.commit(inp.value)
      State.shopEditor.input = nil
      return true
    elseif key == 'backspace' then
      inp.value = inp.value:sub(1, -2)
      return true
    end
    return true
  end
  if key == 's' then
    saveDraft()
    return true
  end
  return false
end

function M.textinput(t)
  local inp = State.shopEditor.input
  if not inp then return false end
  inp.value = inp.value .. t
  return true
end

function M.drawOverlay()
  -- Render the input prompt overlay if any.
  local inp = State.shopEditor and State.shopEditor.input
  if not inp then return end
  local sw, shh = love.graphics.getDimensions()
  local w, h = 520, 110
  local x, y = (sw - w) / 2, (shh - h) / 2
  love.graphics.setColor(0, 0, 0, 0.6)
  love.graphics.rectangle('fill', 0, 0, sw, shh)
  love.graphics.setColor(0.10, 0.14, 0.22)
  love.graphics.rectangle('fill', x, y, w, h, 6, 6)
  love.graphics.setColor(0.4, 0.6, 0.9)
  love.graphics.rectangle('line', x, y, w, h, 6, 6)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(State.fonts.ui)
  love.graphics.print(inp.prompt, x + 16, y + 14)
  love.graphics.setColor(0.16, 0.20, 0.28)
  love.graphics.rectangle('fill', x + 16, y + 42, w - 32, 32, 4, 4)
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(inp.value .. '_', x + 22, y + 50)
  love.graphics.setColor(0.7, 0.78, 0.9)
  love.graphics.print('Enter confirma · Esc cancela', x + 16, y + h - 22)
end

return M
