-- Phase 4 — character panel.
--
-- Single overlay opened with F2, with three tabs: stats / inventory /
-- quests. Equipment slots live alongside stats so the player can see
-- attributes and gear in one glance. Inventory entries are clickable:
-- left-click equips (when applicable) and right-click drops one stack.

local State    = require("src.state")
local Network  = require("src.network")
local Keybinds = require("src.keybinds")

local M = {}

local PANEL_W = 460
local PANEL_H = 400
local TABS    = { "stats", "inventory", "quests", "keybinds" }
local ROW_H   = 22

local function panelRect()
    local sw, sh = love.graphics.getDimensions()
    local x = math.floor((sw - PANEL_W) / 2)
    local y = math.floor((sh - PANEL_H) / 2)
    return x, y, PANEL_W, PANEL_H
end

local function rectContains(rx, ry, rw, rh, mx, my)
    return mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh
end

local function drawTabs(x, y, w)
    local font = State.fonts.ui
    love.graphics.setFont(font)
    local tabW = math.floor(w / #TABS)
    for i, name in ipairs(TABS) do
        local tx = x + (i - 1) * tabW
        local active = (State.charPanelTab == name)
        love.graphics.setColor(active and 0.20 or 0.10, active and 0.20 or 0.10, active and 0.28 or 0.16)
        love.graphics.rectangle("fill", tx, y, tabW, 28, 4, 4)
        love.graphics.setColor(1, 1, 1, active and 1.0 or 0.7)
        love.graphics.printf(name:upper(), tx, y + 6, tabW, "center")
    end
end

local function drawStats(x, y, w)
    local c = State.character
    love.graphics.setFont(State.fonts.ui)
    love.graphics.setColor(1, 1, 1)
    local lines = {
        string.format("Name: %s", State.myName or ""),
        string.format("Level: %d  XP: %d / %d", c.level, c.xp, c.nextX),
        string.format("Gold: %d  Skill points: %d", c.gold, c.skillPoints),
        "",
        "Attributes",
        string.format("  Str: %d  Dex: %d", c.str, c.dex),
        string.format("  Int: %d  Vit: %d", c.intel, c.vit),
        "",
        "Equipment",
    }
    local me = State.players[State.myId]
    if me then
        lines[#lines + 1] = string.format("  HP: %d / %d", me.hp or 0, me.maxHp or 0)
        lines[#lines + 1] = string.format("  MP: %d / %d", me.mp or 0, me.maxMp or 0)
    end
    for _, slot in ipairs({ "weapon", "armor", "helmet", "trinket" }) do
        local id = State.equipped[slot]
        local def = id and State.itemDefs[id] or nil
        local label = def and def.name or (id or "-")
        lines[#lines + 1] = string.format("  %-7s : %s", slot, label)
    end
    for i, line in ipairs(lines) do
        love.graphics.print(line, x + 12, y + (i - 1) * 18)
    end
end

local function drawInventory(x, y, w, h)
    love.graphics.setFont(State.fonts.ui)
    if #State.inventory == 0 then
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.print("(empty)", x + 12, y + 12)
        return
    end
    for i, item in ipairs(State.inventory) do
        local row = y + (i - 1) * 22
        if row > y + h - 24 then break end
        local def = State.itemDefs[item.id] or {}
        local label = def.name or item.id
        local rarity = def.rarity or "common"
        local rcol = ({
            common    = { 0.85, 0.85, 0.85 },
            uncommon  = { 0.55, 0.95, 0.55 },
            rare      = { 0.55, 0.65, 1.0 },
            epic      = { 0.85, 0.55, 1.0 },
            legendary = { 1.0,  0.65, 0.30 },
        })[rarity] or { 1, 1, 1 }
        love.graphics.setColor(0.08, 0.08, 0.10, 0.6)
        love.graphics.rectangle("fill", x + 8, row, w - 16, 20, 3, 3)
        love.graphics.setColor(rcol[1], rcol[2], rcol[3])
        love.graphics.print(string.format("%-22s ×%d", label, item.qty), x + 14, row + 2)
        love.graphics.setColor(1, 1, 1, 0.55)
        local hint = (def.slot and def.slot ~= "" and def.slot ~= "none")
            and "L: equip   R: drop"
            or  "R: drop"
        love.graphics.printf(hint, x + 8, row + 2, w - 24, "right")
    end
end

-- Phase 6 — UI de keybinds. Lista cada ação + tecla atual, com botão
-- "Bind" para iniciar captura. Durante captura mostramos contagem
-- regressiva do timeout para o jogador ver que NÃO está travado.
local function drawKeybinds(x, y, w, h)
    love.graphics.setFont(State.fonts.ui)
    local actions = Keybinds.actions()
    local cap = State.keybindCapture
    for i, action in ipairs(actions) do
        local row = y + (i - 1) * ROW_H
        if row > y + h - ROW_H then break end
        love.graphics.setColor(0.08, 0.08, 0.10, 0.6)
        love.graphics.rectangle("fill", x + 8, row, w - 16, ROW_H - 2, 3, 3)

        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.print(action, x + 14, row + 3)

        local keys = Keybinds.keysFor(action)
        local keyStr = #keys > 0 and table.concat(keys, ", ") or "-"
        love.graphics.setColor(0.85, 0.85, 0.95)
        love.graphics.printf(keyStr, x + 140, row + 3, w - 280, "left")

        local bx = x + w - 90
        local by = row
        local bw = 78
        local bh = ROW_H - 4
        local capturing = cap and cap.action == action
        if capturing then
            local remain = math.max(0, cap.timeout - (love.timer.getTime() - cap.startedAt))
            love.graphics.setColor(0.85, 0.55, 0.20)
            love.graphics.rectangle("fill", bx, by, bw, bh, 3, 3)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(string.format("Press... %.0fs", remain),
                bx, by + 2, bw, "center")
        else
            love.graphics.setColor(0.20, 0.35, 0.55)
            love.graphics.rectangle("fill", bx, by, bw, bh, 3, 3)
            love.graphics.setColor(1, 1, 1, 0.95)
            love.graphics.printf("Bind", bx, by + 2, bw, "center")
        end
    end

    if cap then
        love.graphics.setColor(1, 0.85, 0.55, 0.95)
        love.graphics.printf("Pressione a nova tecla (Esc cancela)",
            x, y + h - 22, w - 8, "right")
    else
        love.graphics.setColor(1, 1, 1, 0.55)
        love.graphics.printf("Click \"Bind\" e pressione a nova tecla. Esc cancela.",
            x, y + h - 22, w - 8, "right")
    end
end

local function drawQuests(x, y, w, h)
    love.graphics.setFont(State.fonts.ui)
    local i = 0
    for id, qs in pairs(State.quests) do
        i = i + 1
        local row = y + (i - 1) * 44
        if row > y + h - 48 then break end
        local def = State.questDefs[id] or {}
        love.graphics.setColor(0.08, 0.08, 0.10, 0.6)
        love.graphics.rectangle("fill", x + 8, row, w - 16, 40, 3, 3)
        local title = string.format("%s [%s]", def.name or id, qs.stage)
        love.graphics.setColor(qs.done and 0.55 or 1.0,
                               qs.done and 1.0  or 0.95,
                               qs.done and 0.55 or 0.55)
        love.graphics.print(title, x + 14, row + 4)
        local progress = ""
        if def.killTarget then
            progress = string.format("Kill %s: %d / %d",
                def.killTarget, qs.killCount, def.killCount)
        elseif def.itemTarget then
            progress = string.format("Collect %s × %d", def.itemTarget, def.itemCount)
        end
        love.graphics.setColor(1, 1, 1, 0.85)
        love.graphics.print(progress, x + 14, row + 22)
    end
    if i == 0 then
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.print("(no active quests)", x + 12, y + 12)
    end
end

function M.draw()
    if not State.charPanelOpen then return end
    local x, y, w, h = panelRect()

    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())

    love.graphics.setColor(0.05, 0.06, 0.10, 0.97)
    love.graphics.rectangle("fill", x, y, w, h, 6, 6)
    love.graphics.setColor(1, 1, 1, 0.18)
    love.graphics.rectangle("line", x, y, w, h, 6, 6)

    love.graphics.setFont(State.fonts.title)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Character", x, y + 6, w, "center")

    drawTabs(x + 16, y + 48, w - 32)
    local bodyY = y + 84
    if State.charPanelTab == "stats" then
        drawStats(x + 8, bodyY, w - 16)
    elseif State.charPanelTab == "inventory" then
        drawInventory(x + 8, bodyY, w - 16, h - (bodyY - y) - 16)
    elseif State.charPanelTab == "keybinds" then
        drawKeybinds(x + 8, bodyY, w - 16, h - (bodyY - y) - 16)
    else
        drawQuests(x + 8, bodyY, w - 16, h - (bodyY - y) - 16)
    end

    love.graphics.setFont(State.fonts.name)
    love.graphics.setColor(1, 1, 1, 0.55)
    love.graphics.printf("F2 to close", x, y + h - 22, w, "center")
end

function M.toggle()
    State.charPanelOpen = not State.charPanelOpen
end

function M.isOpen() return State.charPanelOpen end

-- Returns true if the click was consumed by the panel.
function M.mousepressed(mx, my, button)
    if not State.charPanelOpen then return false end
    local x, y, w, h = panelRect()
    if not rectContains(x, y, w, h, mx, my) then
        -- Click outside closes the panel for parity with the dialog UI.
        State.charPanelOpen = false
        return true
    end

    -- Tab strip.
    local tabsY = y + 48
    if my >= tabsY and my <= tabsY + 28 then
        local tabW = math.floor((w - 32) / #TABS)
        for i, name in ipairs(TABS) do
            local tx = x + 16 + (i - 1) * tabW
            if rectContains(tx, tabsY, tabW, 28, mx, my) then
                State.charPanelTab = name
                return true
            end
        end
    end

    -- Inventory rows.
    if State.charPanelTab == "inventory" and #State.inventory > 0 then
        local bodyY = y + 84
        for i, item in ipairs(State.inventory) do
            local row = bodyY + (i - 1) * 22
            if rectContains(x + 8, row, w - 16, 20, mx, my) then
                local def = State.itemDefs[item.id]
                if button == 1 and def and def.slot and def.slot ~= "" and def.slot ~= "none" then
                    Network.send("EQUIP " .. item.id)
                elseif button == 2 then
                    Network.send("DROP " .. item.id .. " 1")
                end
                return true
            end
        end
    end

    -- Keybind rows: clique no botão "Bind" inicia captura.
    if State.charPanelTab == "keybinds" and button == 1 then
        local bodyY = y + 84
        local actions = Keybinds.actions()
        for i, action in ipairs(actions) do
            local row = bodyY + (i - 1) * ROW_H
            local bx = x + w - 16 - 90
            if rectContains(bx, row, 78, ROW_H - 4, mx, my) then
                Keybinds.startCapture(action)
                return true
            end
        end
    end

    return true
end

return M
