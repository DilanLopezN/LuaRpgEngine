-- Item icon registry. The Pixel Crawler pack ships an "Icons" folder
-- but only with .aseprite sources, so we paint synthetic 32×32 icons:
-- a colored background tile + a glyph + a small accent. Each icon id
-- lives in `M.icons` and is callable via M.draw(id, x, y, size).
--
-- The design is loud on purpose — every item type has a distinct
-- silhouette so the player can read inventory from across the room.
-- Designers can pick any registered id from the editor's sprite picker.

local State = require("src.state")

local M = {}

-- Icon definitions. Background is a duotone (top, bottom); glyph is the
-- big mark drawn in the center; accent is a tiny corner pip used to
-- distinguish two-handed / consumable / quest variants.
local ICONS = {
    -- Weapons.
    icon_sword_iron   = { bg = { 0.35, 0.42, 0.55 }, fg = { 0.85, 0.88, 0.95 }, glyph = "/", label = "Espada" },
    icon_sword_steel  = { bg = { 0.55, 0.62, 0.75 }, fg = { 0.95, 0.98, 1.00 }, glyph = "/", label = "Espada Aço" },
    icon_axe          = { bg = { 0.45, 0.32, 0.20 }, fg = { 0.85, 0.50, 0.30 }, glyph = "P", label = "Machado" },
    icon_dagger       = { bg = { 0.30, 0.30, 0.42 }, fg = { 0.95, 0.95, 1.00 }, glyph = "i", label = "Adaga" },
    icon_bow          = { bow = true, bg = { 0.40, 0.30, 0.20 }, fg = { 0.95, 0.85, 0.55 }, glyph = ")", label = "Arco" },
    icon_staff_wood   = { bg = { 0.42, 0.28, 0.18 }, fg = { 0.85, 0.65, 0.30 }, glyph = "I", label = "Cajado" },
    icon_staff_arcane = { bg = { 0.30, 0.22, 0.45 }, fg = { 0.65, 0.55, 1.00 }, glyph = "I", label = "Cajado Arcano" },

    -- Armor / helmet / boots.
    icon_armor_leather = { bg = { 0.45, 0.30, 0.20 }, fg = { 0.85, 0.65, 0.40 }, glyph = "A", label = "Armadura Leve" },
    icon_armor_chain   = { bg = { 0.40, 0.42, 0.48 }, fg = { 0.80, 0.82, 0.88 }, glyph = "A", label = "Cota de Malha" },
    icon_armor_plate   = { bg = { 0.55, 0.58, 0.65 }, fg = { 0.95, 0.95, 1.00 }, glyph = "A", label = "Armadura Pesada" },
    icon_helmet_iron   = { bg = { 0.40, 0.44, 0.52 }, fg = { 0.85, 0.88, 0.95 }, glyph = "H", label = "Elmo" },
    icon_helmet_horned = { bg = { 0.30, 0.20, 0.20 }, fg = { 0.95, 0.85, 0.45 }, glyph = "M", label = "Elmo Cornudo" },
    icon_boots_leather = { bg = { 0.45, 0.30, 0.20 }, fg = { 0.85, 0.65, 0.40 }, glyph = "B", label = "Botas" },

    -- Shields.
    icon_shield_wood   = { bg = { 0.42, 0.28, 0.18 }, fg = { 0.85, 0.65, 0.30 }, glyph = "U", label = "Escudo Madeira" },
    icon_shield_iron   = { bg = { 0.40, 0.44, 0.52 }, fg = { 0.85, 0.88, 0.95 }, glyph = "U", label = "Escudo Ferro" },
    icon_shield_kite   = { bg = { 0.55, 0.30, 0.30 }, fg = { 0.95, 0.85, 0.45 }, glyph = "U", label = "Escudo Pavês" },

    -- Accessories.
    icon_ring_red    = { bg = { 0.55, 0.20, 0.30 }, fg = { 1.00, 0.85, 0.45 }, glyph = "o", label = "Anel Rubi" },
    icon_ring_blue   = { bg = { 0.20, 0.30, 0.60 }, fg = { 0.65, 0.85, 1.00 }, glyph = "o", label = "Anel Safira" },
    icon_amulet_gold = { bg = { 0.55, 0.45, 0.20 }, fg = { 1.00, 0.90, 0.45 }, glyph = "v", label = "Amuleto" },

    -- Consumables.
    icon_potion_red    = { bg = { 0.50, 0.10, 0.15 }, fg = { 1.00, 0.40, 0.40 }, glyph = "!", label = "Poção Vermelha" },
    icon_potion_blue   = { bg = { 0.10, 0.20, 0.55 }, fg = { 0.50, 0.75, 1.00 }, glyph = "!", label = "Poção Azul" },
    icon_potion_green  = { bg = { 0.15, 0.40, 0.20 }, fg = { 0.55, 0.95, 0.55 }, glyph = "!", label = "Poção Verde" },
    icon_food_bread    = { bg = { 0.55, 0.40, 0.20 }, fg = { 0.95, 0.80, 0.45 }, glyph = "n", label = "Pão" },
    icon_scroll        = { bg = { 0.45, 0.45, 0.30 }, fg = { 0.95, 0.95, 0.75 }, glyph = "S", label = "Pergaminho" },

    -- Quest / materials / keys.
    icon_tooth         = { bg = { 0.30, 0.45, 0.30 }, fg = { 0.95, 0.95, 0.85 }, glyph = "T", label = "Dente" },
    icon_gem           = { bg = { 0.20, 0.35, 0.55 }, fg = { 0.55, 0.85, 1.00 }, glyph = "*", label = "Gema" },
    icon_key           = { bg = { 0.45, 0.40, 0.20 }, fg = { 0.95, 0.85, 0.30 }, glyph = "K", label = "Chave" },
    icon_coin          = { bg = { 0.55, 0.45, 0.10 }, fg = { 1.00, 0.90, 0.40 }, glyph = "$", label = "Moeda" },
    icon_log           = { bg = { 0.40, 0.28, 0.18 }, fg = { 0.75, 0.55, 0.35 }, glyph = "=", label = "Tora" },
    icon_ore           = { bg = { 0.35, 0.35, 0.42 }, fg = { 0.75, 0.75, 0.85 }, glyph = "#", label = "Minério" },
    icon_skull         = { bg = { 0.20, 0.20, 0.25 }, fg = { 0.90, 0.90, 0.85 }, glyph = "X", label = "Crânio" },
}

-- Categories drive the picker layout: equipment / consumable / misc.
local CATEGORIES = {
    weapons = {
        "icon_sword_iron", "icon_sword_steel", "icon_axe", "icon_dagger",
        "icon_bow", "icon_staff_wood", "icon_staff_arcane",
    },
    armor   = {
        "icon_armor_leather", "icon_armor_chain", "icon_armor_plate",
        "icon_helmet_iron", "icon_helmet_horned", "icon_boots_leather",
        "icon_shield_wood", "icon_shield_iron", "icon_shield_kite",
    },
    accessory = {
        "icon_ring_red", "icon_ring_blue", "icon_amulet_gold",
    },
    consumable = {
        "icon_potion_red", "icon_potion_blue", "icon_potion_green",
        "icon_food_bread", "icon_scroll",
    },
    misc = {
        "icon_tooth", "icon_gem", "icon_key", "icon_coin",
        "icon_log", "icon_ore", "icon_skull",
    },
}

M.icons = ICONS
M.categories = CATEGORIES

-- Return an ordered list of every registered id, used by the editor
-- picker. The order follows CATEGORIES so weapons stay grouped.
function M.allIds()
    local out = {}
    for _, cat in ipairs({ "weapons", "armor", "accessory", "consumable", "misc" }) do
        for _, id in ipairs(CATEGORIES[cat]) do
            out[#out + 1] = id
        end
    end
    return out
end

function M.has(id) return ICONS[id] ~= nil end

-- Default sprite for a given item type — used when a designer hasn't
-- picked a sprite explicitly so every item still renders something
-- reasonable.
local DEFAULT_FOR_TYPE = {
    weapon     = "icon_sword_iron",
    staff      = "icon_staff_wood",
    shield     = "icon_shield_wood",
    armor      = "icon_armor_leather",
    helmet     = "icon_helmet_iron",
    boots      = "icon_boots_leather",
    ring       = "icon_ring_red",
    amulet     = "icon_amulet_gold",
    consumable = "icon_potion_red",
    quest      = "icon_tooth",
    key        = "icon_key",
    material   = "icon_log",
    currency   = "icon_coin",
}
function M.defaultFor(type) return DEFAULT_FOR_TYPE[type or ""] or "icon_gem" end

-- draw renders a single icon at (x, y) with the given size. The icon
-- is fully self-contained — no atlas, no asset dependency.
function M.draw(id, x, y, size, opts)
    opts = opts or {}
    local icon = ICONS[id]
    if not icon then
        love.graphics.setColor(0.20, 0.20, 0.25)
        love.graphics.rectangle("fill", x, y, size, size, 4, 4)
        love.graphics.setColor(0.95, 0.50, 0.50)
        love.graphics.rectangle("line", x, y, size, size, 4, 4)
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(1, 1, 1, 0.85)
        love.graphics.printf("?", x, y + size / 2 - 8, size, "center")
        return
    end
    -- Background gradient (top → bottom).
    local steps = 8
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        love.graphics.setColor(
            icon.bg[1] * (1 - 0.35 * t),
            icon.bg[2] * (1 - 0.35 * t),
            icon.bg[3] * (1 - 0.35 * t))
        local ys = y + math.floor(size * i / steps)
        local ye = y + math.floor(size * (i + 1) / steps)
        love.graphics.rectangle("fill", x, ys, size, ye - ys, 4, 4)
    end
    -- Glyph.
    love.graphics.setColor(icon.fg[1], icon.fg[2], icon.fg[3])
    local font = State.fonts.title or State.fonts.ui
    love.graphics.setFont(font)
    local glyph = icon.glyph or "?"
    local fw = font:getWidth(glyph)
    local fh = font:getHeight()
    local scale = math.max(0.5, math.min(2.0, size / 28))
    love.graphics.print(glyph,
        x + size / 2 - (fw * scale) / 2,
        y + size / 2 - (fh * scale) / 2,
        0, scale, scale)
    -- Border (rarity tint when supplied).
    local rcol = opts.rarity and ({
        common    = { 0.85, 0.85, 0.85, 0.55 },
        uncommon  = { 0.55, 0.95, 0.55, 0.85 },
        rare      = { 0.55, 0.65, 1.0,  0.95 },
        epic      = { 0.85, 0.55, 1.0,  0.95 },
        legendary = { 1.0,  0.65, 0.30, 1.00 },
    })[opts.rarity] or { 1, 1, 1, 0.35 }
    love.graphics.setLineWidth(opts.rarity and opts.rarity ~= "common" and 2 or 1)
    love.graphics.setColor(rcol[1], rcol[2], rcol[3], rcol[4])
    love.graphics.rectangle("line", x, y, size, size, 4, 4)
    love.graphics.setLineWidth(1)
    -- Stack qty corner.
    if opts.qty and opts.qty > 1 then
        love.graphics.setFont(State.fonts.name)
        love.graphics.setColor(0, 0, 0, 0.7)
        local txt = "×" .. opts.qty
        local w = State.fonts.name:getWidth(txt) + 4
        love.graphics.rectangle("fill", x + size - w - 2, y + size - 14, w, 12, 3, 3)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(txt, x + size - w, y + size - 14)
    end
end

-- iconForItem resolves the icon id to use for a given State.itemDefs
-- entry. Falls back to type-default then to a question mark if neither
-- is registered.
function M.iconForItem(def)
    if not def then return nil end
    if def.sprite and ICONS[def.sprite] then return def.sprite end
    return M.defaultFor(def.type)
end

return M
