-- Loot table: kicks in whenever an enemy dies. Designers can extend
-- this without touching Go — drop_item / give_item / give_gold are the
-- safe primitives, all server-validated.
on("enemy_killed", function(data)
  if not data or not data.killer then return end
  if data.kind == "orc" then
    drop_item(data.killer, "orc_tooth", 1, 700)        -- 70% chance
    drop_item(data.killer, "health_potion", 1, 250)    -- 25% chance
    give_gold(data.killer, 5)
  elseif data.kind == "troll" then
    drop_item(data.killer, "leather_armor", 1, 200)    -- 20% chance
    drop_item(data.killer, "health_potion", 2, 500)
    give_gold(data.killer, 20)
  end
end)
