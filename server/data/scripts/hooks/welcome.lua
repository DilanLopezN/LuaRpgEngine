-- Hooks live as `on(<event>, function(data) ... end)` registrations.
-- The first argument is a table built from the gameplay event; only
-- the safe API set (broadcast, spawn_entity, damage_entity, ...) is
-- reachable from here.

on("player_join", function(data)
  if data and data.name then
    broadcast(data.name .. " entered the world.")
  end
end)

on("enemy_killed", function(data)
  if data and data.kind then
    log("enemy died: " .. data.kind)
  end
end)
