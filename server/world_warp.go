package main

func (g *Game) warpAt(mapName string, x, y int) *MapEntity {
	m := g.world
	if m == nil {
		return nil
	}
	for i := range m.Entities {
		e := &m.Entities[i]
		if e.Type == "trigger" && e.Kind == "warp" && e.X == x && e.Y == y {
			return e
		}
	}
	return nil
}

func (g *Game) transitionPlayer(p *Player, targetMap string, x, y int) {
	if p == nil || g.world == nil {
		return
	}
	if targetMap == "" {
		targetMap = g.world.Name
	}
	if !g.world.InBounds(x, y) {
		x, y = p.TileX, p.TileY
	}
	p.FromX, p.FromY = x, y
	p.TileX, p.TileY = x, y
	p.Stepping = false
	resetSeenForRespawn(p)
	if p.Out != nil {
		select {
		case p.Out <- "MAP_CHANGE " + targetMap + "\n":
		default:
		}
		if data, err := g.world.Marshal(); err == nil {
			select {
			case p.Out <- "MAP " + string(data) + "\n":
			default:
			}
		}
	}
}
