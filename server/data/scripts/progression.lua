-- Tunable level / xp curve. xp_curve > 1 means each level costs more
-- than the previous (1.5 = +50% per level). hp_per_level / mp_per_level
-- compound on top of the per-Vit / per-Int gains in stats.go.
return {
  xp_base       = 100,
  xp_curve      = 1.5,
  hp_per_level  = 10,
  mp_per_level  = 4,
  str_per_level = 1,
  dex_per_level = 1,
  int_per_level = 1,
  vit_per_level = 1,
}
