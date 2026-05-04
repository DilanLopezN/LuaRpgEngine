# 🎮 Roadmap da Engine — Plano de Execução para Claude Code

> Documento estruturado em fases priorizadas. Cada fase tem: **objetivo**, **arquivos a tocar**, **referência VB6** (em `reference_engine/`), e **checklist** com critério de pronto.
>
> Regras gerais (vale para todas as fases):
> - Conteúdo SEMPRE data-driven (JSON em `data/scripts/*_user/` ou Lua em `data/scripts/*/`). Nada hardcoded em Go.
> - Toda mudança em servidor: `go test -race ./...` antes de commit.
> - Toda mudança em rede: documentar em `docs/PROTOCOL.md`.
> - Schema de arquivo novo: incluir `schema_version`.

---

## 🧩 Fase 1 — Pickers de Conteúdo (DESTRAVA TUDO)

**Por quê:** hoje os editores de NPC/Quest exigem digitar IDs de item/npc/quest na mão em campos `text`. O backend já suporta tudo — falta só UI. Sem isso, criar conteúdo é frágil (typo = quebra silenciosa).

**Objetivo:** componente reutilizável que abre overlay listando o catálogo (`State.itemDefs`, `State.questDefs`, `State.npcDefs`) e seleciona o ID via clique.

**Arquivos a criar/tocar:**
- ➕ `client/src/editor_pickers.lua` — módulo novo. API: `Pickers.openItem(currentId, onPick)`, `Pickers.openQuest(...)`, `Pickers.openNPC(filter, ...)`. Renderiza overlay modal com busca por nome e grid com sprite + label.
- ✏️ `client/src/state.lua` — adicionar `M.activePicker = nil` para estado do overlay.
- ✏️ `client/src/editor_npcs.lua` — substituir `loot_row` text input do `item` por `item_picker`. Substituir campo `quest` por `quest_picker`.
- ✏️ `client/src/editor_quests.lua` — em `buildRows`, quando `o.type == "collect"` → `item_picker`. Quando `o.type == "kill"` → `npc_picker` filtrando role={enemy,guardian}. Quando `o.type == "talk"` → `npc_picker` sem filtro. `reward_item` → `item_picker`. Campo `giver` → `npc_picker` filtrando role=quest_giver.
- ✏️ `client/src/editor.lua` — chamar `Pickers.draw()` após `tab.drawContent()` para overlay ficar por cima.

**Referência VB6:** `reference_engine/Client/src/frmEditor_NPC.frm` (lista de itens em combo box no editor de drop), `frmEditor_Quest.frm` (campos de target).

**Checklist:**
- [ ] Criar `editor_pickers.lua` com 3 APIs (item/quest/npc) + estado em `State.activePicker`
- [ ] Overlay com search bar (filtro por substring no nome)
- [ ] Grid responsivo: sprite + nome + ID em fonte menor; rolável
- [ ] Tecla Esc fecha o picker; clique fora também
- [ ] Substituir text input de `loot.item` no editor de NPCs
- [ ] Substituir text input de `quest` no editor de NPCs
- [ ] Substituir text input de `obj_target` (collect/kill/talk) no editor de Quests
- [ ] Substituir text input de `reward.items[].id` no editor de Quests
- [ ] Substituir text input de `giver` no editor de Quests
- [ ] Validação: ID escolhido sempre existe no catálogo no momento do save
- [ ] Tooltip mostra preview ao hover (ícone + nome + tipo/raridade)

---

## 🗺️ Fase 2 — Múltiplos Mapas + Warp Funcional

**Por quê:** hoje só existe o mapa `world`. O editor já permite criar entidade `trigger` e `kind=warp`, mas nada acontece quando o player pisa. Sem múltiplos mapas, RPG não escala.

**Objetivo:** trigger `warp` no mapa carrega o mapa de destino e teleporta o player para o tile alvo.

**Arquivos a criar/tocar:**
- ✏️ `server/world.go` (ou `map.go`) — `MapEntity` precisa carregar `target_map`, `target_x`, `target_y` quando `Type=="trigger"` e `Kind=="warp"`.
- ✏️ `server/movement.go` — após `runMovement` mover o player, checar se tile pisado tem trigger warp; se sim, agendar transição (não trocar mapa no meio do step).
- ➕ `server/world_warp.go` — função `transitionPlayer(p, mapName, x, y)`: salva estado, carrega mapa se ainda não em cache, atualiza `p.MapName` (campo novo no `Player`), envia frame `MAP_CHANGE`.
- ✏️ `server/snapshot.go` — AoI precisa ser por mapa. Players em mapas diferentes não se enxergam.
- ✏️ `server/game.go` — `g.world` vira `g.worlds map[string]*Map`. AoI/colisão/spawn passam a consultar mapa do player.
- ✏️ `client/src/protocol.lua` — handler para `MAP_CHANGE <name> <w> <h> <json_layers>`.
- ✏️ `client/src/editor_map.lua` — entidade warp precisa de campos extras (`target_map`, `target_x`, `target_y`) no formulário de entidade.
- ✏️ `client/src/editor_layout.lua` — seletor de mapa ativo na barra superior do editor (dropdown listando todos os mapas existentes + "+ Novo Mapa").

**Referência VB6:** `reference_engine/Client/src/frmMapProperties.frm` (warp nas bordas: WarpMap/WarpX/WarpY), `reference_engine/Server/src/modPlayer.bas` `PlayerWarp` (a função canônica de teleporte).

**Checklist:**
- [ ] `Player.MapName` adicionado, default = `"world"`
- [ ] `Game.worlds map[string]*Map` substitui `Game.world`
- [ ] `LoadMap(name)` é cacheado; `loadOrFetchMap(name)` thread-safe
- [ ] Schema do mapa estende `MapEntity` com `target_map/x/y` (mantém retrocompatível)
- [ ] Trigger warp dispara após settle do step (não no meio)
- [ ] AoI filtra por `p.MapName == other.MapName`
- [ ] Snapshot drop (`X`) emite para tudo do mapa antigo ao trocar
- [ ] Frame `MAP_CHANGE` no protocolo + entry em `docs/PROTOCOL.md`
- [ ] Cliente troca `Map.current` ao receber `MAP_CHANGE`
- [ ] Editor de mapa: dropdown de mapa ativo + botão "+ Novo Mapa"
- [ ] Editor de mapa: form de entidade trigger mostra campos warp
- [ ] Teste: `TestPlayerWarpsAcrossMaps` em `server/world_warp_test.go`
- [ ] Teste: `TestPlayersInDifferentMapsDontSeeEachOther`

---

## 🛒 Fase 3 — Shop / Mercador

**Por quê:** o role `merchant` existe no enum mas é decorativo. Sem comércio, não tem sink/source de gold, sem economia.

**Objetivo:** mercador tem inventário próprio com preços, player abre UI de compra/venda ao falar com ele.

**Arquivos a criar/tocar:**
- ➕ `server/shop.go` — `ShopDef` (id, items=[{item_id, qty, price, restock_sec}], buy_multiplier). `LoadUserShopJSON` / `SaveUserShopDef`.
- ✏️ `server/npc.go` — `NPCDef.Shop string` (id de uma ShopDef).
- ✏️ `server/npc_runtime.go` — quando `def.Role == NPCRoleMerchant`, ao falar dispara `SHOP_OPEN <shopID> <inventário JSON>` em vez de árvore de diálogo.
- ➕ `server/shop_runtime.go` — `handleShopBuy(p, shopID, slotIdx, qty)`, `handleShopSell(p, invSlotIdx, qty)` com validação de gold/estoque/peso.
- ✏️ `server/handlers.go` — registrar `SHOP_BUY` e `SHOP_SELL` no router.
- ➕ `client/src/shopui.lua` — modal de loja: 2 colunas (estoque do mercador / inventário do player), preço por item, botões Comprar/Vender, badge de gold do player no topo.
- ✏️ `client/src/protocol.lua` — handlers `SHOP_OPEN`, `SHOP_UPDATE`, `SHOP_CLOSE`.
- ➕ `client/src/editor_shops.lua` — nova aba "Lojas" no editor: catálogo de shops + form (id, nome, lista de itens com qty/price). Salvar via `SAVE_SHOP_DEF`.
- ✏️ `client/src/editor.lua` — adicionar tab `shops`.
- ✏️ `client/src/editor_npcs.lua` — quando `role=merchant`, mostrar campo `shop_picker` (mais um picker da Fase 1).

**Referência VB6:** `reference_engine/Client/src/frmEditor_Shop.frm` (form completo do editor de loja), `reference_engine/Server/src/modPlayer.bas` `BuyItem`/`SellItem` (lógica de compra/venda canônica), `reference_engine/Client/src/modGameLogic.bas` `BltShop` (UI da loja).

**Checklist:**
- [ ] `ShopDef` + persistência em `data/scripts/shops_user/<id>.json`
- [ ] `NPCDef.Shop` + carregamento + save
- [ ] Frames `SHOP_OPEN`, `SHOP_BUY`, `SHOP_SELL`, `SHOP_UPDATE`, `SHOP_CLOSE` no protocolo
- [ ] Validação server-side de: gold suficiente, slot do inventário válido, estoque > 0, item pertence à shop
- [ ] Restock por timer (campo `restock_sec` por item; 0 = infinito)
- [ ] Multiplicador de venda (`buy_multiplier` default 0.5 → vende por 50% do preço)
- [ ] Modal `shopui.lua` com Esc fechando
- [ ] Editor de shops com picker de itens (reutiliza Fase 1)
- [ ] NPC merchant abre shop em vez de diálogo
- [ ] Teste: `TestShopBuyDeductsGoldAndAddsItem`, `TestShopBuyRejectsInsufficientGold`
- [ ] Documentar em `docs/PROTOCOL.md`

---

## 🎬 Fase 4 — Animações (Attack / Walk / Death)

**Por quê:** sprites no `assets/Pixel Crawler` já têm sheets de attack/walk/death; só uso a idle. Combate fica visualmente plano sem animação.

**Objetivo:** trocar a animação ativa do sprite conforme estado da entidade (idle / walking / attacking / dying / dead).

**Arquivos a tocar:**
- ✏️ `client/src/sprites.lua` — registrar 4 animações por sprite: `<id>_idle`, `<id>_walk`, `<id>_attack`, `<id>_death`. Cada uma com `getQuad(time)` próprio. `M.spriteState(id, state, t)` retorna o quad do estado.
- ✏️ `client/src/render.lua` — usar `Stepping` (já existe) para escolher walk vs idle. Usar campo `atk` (já tem) para attack. HP=0 → death (uma vez, segura no último frame).
- ✏️ `server/snapshot.go` — `snapState` ganha `atk`/`dying` (alguns já existem). Garantir que estado transitório seja emitido.
- ✏️ `client/src/protocol.lua` — quando recebe `atk=1`, registrar `entity.atkAnimStart = now()` para tocar animação completa mesmo se `atk` voltar para 0 antes do fim.

**Referência VB6:** `reference_engine/Client/src/modDirectDraw7.bas` `BltPlayer` (escolha de spritesheet por direção+anim_step), `reference_engine/Client/src/modGameLogic.bas` `CheckAttack` (timing do sprite de ataque).

**Checklist:**
- [ ] `sprites.lua` carrega Idle-Sheet, Walk-Sheet, Attack-Sheet, Death-Sheet de cada sprite registrado
- [ ] Animação `walk` toca enquanto `Stepping=true`
- [ ] Animação `attack` toca por duração fixa (≥ duração do sheet) mesmo se `atk` flag desligar antes
- [ ] Animação `death` toca uma vez e segura no último frame quando HP=0
- [ ] Direção do sprite respeita `FaceX/FaceY` (4 direções: N/S/L/O)
- [ ] Player + NPCs hostis + enemies todos respeitam o sistema
- [ ] Sem regressão visual nos NPCs friendly (ainda só idle)

---

## 💾 Fase 5 — Persistência (Postgres + Save de Personagem)

**Por quê:** sem isso, fechar o servidor zera todo progresso. Não dá para playtest sério.

**Objetivo:** Postgres com migrations versionadas. Personagem (stats, inventário, equipamento, quests, skills, posição, mapa) persiste entre sessões.

**Arquivos a criar/tocar:**
- ➕ `server/migrations/0001_initial.sql` — tabelas: `accounts`, `characters`, `character_inventory`, `character_equipment`, `character_quests`, `character_skills`.
- ➕ `server/db_postgres.go` — substitui `server/db.go` em memória. Connection pool, prepared statements.
- ✏️ `server/main.go` (ou onde está `func main`) — boot: `goose up` ANTES de aceitar conexões. Falha de migration = `os.Exit(1)`.
- ➕ `server/persistence.go` — `LoadCharacter(accountID, name) (*Player, error)`, `SaveCharacter(p *Player) error`. Salvar a cada N segundos OU em events (level up, item raro, logout).
- ✏️ `server/handlers.go` — login/logout chamam load/save.
- ➕ `docker-compose.yml` (dev) — Postgres local.

**Referência VB6:** `reference_engine/Server/data/accounts/` (estrutura de save por arquivo .dat — instrutivo do que persistir).

**Checklist:**
- [ ] `goose` adicionado ao Go module
- [ ] Migrations 0001 com todas as tabelas
- [ ] `docker-compose.yml` com Postgres + porta exposta
- [ ] Boot do servidor falha (exit 1) se migrations falharem
- [ ] `LoadCharacter` retorna `*Player` populado
- [ ] `SaveCharacter` salva tudo: stats, inventário, equip, quests, skills, posição, mapa
- [ ] Autosave a cada 30s + on-logout
- [ ] Connection pool com timeout configurável
- [ ] Teste: `TestPersistenceRoundTrip` (cria char, modifica, salva, carrega, compara)
- [ ] Teste: `TestServerRefusesConnectionsBeforeMigrations`
- [ ] README local: como subir Postgres com `docker-compose up -d`

---

## 🔊 Fase 6 — Áudio (BGM + SFX)

**Por quê:** RPG sem áudio é inerte. Engine VB6 de referência tem áudio completo via BASS — vocês têm zero.

**Objetivo:** BGM por mapa + SFX para combate (hit, magic, death) + UI (click, level up, item drop).

**Arquivos a criar/tocar:**
- ➕ `client/src/audio.lua` — wrapper sobre `love.audio`. API: `Audio.playBGM(name)`, `Audio.playSFX(name, volume)`, `Audio.setMasterVolume(v)`. Cache de `Source` objects.
- ➕ `client/assets/audio/` — pastas `bgm/` e `sfx/`. Ogg/Wav.
- ✏️ `client/src/protocol.lua` — quando `MAP_CHANGE` chegar, trocar BGM. Em FX (já existe sistema de FCT) tocar SFX.
- ✏️ `server/world.go` — `Map.Music string` no schema (campo opcional).
- ✏️ `client/src/editor_map.lua` — campo de música por mapa no painel de propriedades.
- ✏️ `client/src/keybinds.lua` — bind para mute (M ou similar).
- ➕ `client/src/audio_settings.lua` — UI de volume (master/bgm/sfx) acessível pelo F2.

**Referência VB6:** `reference_engine/Client/src/Bass.bas` (wrapper canônico do BASS.dll), `reference_engine/Client/src/modSound.bas` (chamadas de play, escolha por mapa). LÖVE não usa BASS — usa `love.audio` (OpenAL) — mas a estrutura de "música por mapa, SFX por evento" é idêntica.

**Checklist:**
- [ ] `audio.lua` com cache de Source
- [ ] BGM streaming (`love.audio.newSource(path, "stream")`) — não carrega tudo em RAM
- [ ] SFX estático (`"static"`) para latência baixa
- [ ] `Map.Music` no schema + persistência
- [ ] Editor de mapa: campo dropdown de música
- [ ] BGM crossfade ao trocar de mapa (1 segundo)
- [ ] SFX para: hit, miss, spell cast, level up, loot, item pickup, NPC dialog open, death
- [ ] UI de volume com 3 sliders (master/bgm/sfx) em settings (F2 → aba "Audio")
- [ ] Volumes persistem em `client/save/audio.json`
- [ ] Bind de mute global

---

## 🪟 Fase 7 — Editor Externo (Janela Separada)

**Por quê:** LÖVE não suporta múltiplas janelas. O editor sempre vai estar dentro do canvas do jogo. Para usar em segundo monitor, precisa sair do LÖVE.

**Objetivo:** editor web em HTML+JS que conversa com o servidor Go via WebSocket. Reusa todos os `SAVE_*_DEF` que já existem.

**Arquivos a criar/tocar:**
- ➕ `editor-web/` — projeto separado (Vite + React ou Svelte; sem framework também serve).
- ➕ `editor-web/src/protocol.ts` — espelho do `protocol.lua` em TS.
- ➕ `editor-web/src/editors/` — telas para Map / NPCs / Quests / Items / Spells / Shops.
- ➕ `server/ws_handler.go` — endpoint `/ws/editor` que aceita auth de admin e fala o mesmo protocolo dos `SAVE_*_DEF`.
- ✏️ `server/main.go` — servir HTTP com WS embutido (porta separada da TCP do jogo).
- ➕ `docs/EDITOR_WEB.md` — como buildar e abrir.

**Alternativa mais barata (se Fase 7 web for muita coisa):**
- Continuar dentro do LÖVE mas instalar [`love-imgui`](https://github.com/slages/love-imgui) e portar os editores. ImGui tem viewports flutuantes que podem sair da janela principal. Custo intermediário.

**Referência VB6:** o `Client.exe` original tinha 30+ formulários `frmEditor_*` separados — cada um era literalmente uma janela Windows nativa. Mesma ergonomia da proposta web, com 30 anos a mais.

**Checklist:**
- [ ] Decisão arquitetural: web ou imgui (documentar em `docs/decision_log.md`)
- [ ] Se web:
  - [ ] Endpoint WS `/ws/editor` com auth
  - [ ] Cliente Vite + componentes Map/NPC/Quest/Item/Spell/Shop
  - [ ] CRUD completo via WS para os 5 catálogos
  - [ ] Renderer de mapa em canvas
  - [ ] Build estático servido pelo próprio Go
- [ ] Se imgui:
  - [ ] Bindings instalados
  - [ ] 5 editores portados
  - [ ] Viewports flutuantes habilitadas

---

## ⛏️ Fase 8 — Resources / Coletáveis + Crafting

**Por quê:** árvore que dá madeira, pedra que dá minério. Crafting transforma materiais em equipamento. Sem isso, não tem economia bottom-up.

**Objetivo:** entidade `resource` no mapa com HP/respawn. Player ataca → ganha material. Receita usa materiais para criar item.

**Arquivos a criar/tocar:**
- ➕ `server/resource.go` — `ResourceDef` (id, sprite, hp, tool_required, drops=[{item, qty, chance}], respawn_sec).
- ✏️ `server/world.go` — entidade `resource` no mapa, com instância tendo HP e timer de respawn.
- ➕ `server/recipe.go` — `RecipeDef` (id, ingredients=[{item,qty}], result={item,qty}, station_required).
- ✏️ `server/handlers.go` — `HARVEST <entityID>`, `CRAFT <recipeID>`.
- ➕ `client/src/editor_resources.lua` — aba nova "Recursos".
- ➕ `client/src/editor_recipes.lua` — aba nova "Receitas".
- ➕ `client/src/craftui.lua` — UI de crafting (lista receitas, mostra ingredientes vs inventário).

**Referência VB6:** `reference_engine/Client/src/frmEditor_Resource.frm` (editor de recurso completo), `reference_engine/Server/src/modResource.bas` (timer de respawn, drop, HP).

**Checklist:**
- [ ] `ResourceDef` + persistência
- [ ] Entidade tipo `resource` no editor de mapa (já tem framework de entity)
- [ ] HP por instância de recurso (não por def)
- [ ] Respawn por timer
- [ ] Tool required (machado para árvore, picareta para pedra) — checar inventário equipado
- [ ] `RecipeDef` + persistência
- [ ] UI de crafting acessível por keybind (C?) ou perto de NPC craftsman
- [ ] Editor de receitas com pickers (Fase 1 obrigatória antes)
- [ ] Teste: `TestResourceDropsItemOnDepletion`, `TestCraftConsumesIngredients`

---

## 🎯 Fase 9 — Sistemas Avançados

**Por quê:** features que esperam-se de RPG mas não são bloqueantes para um demo jogável.

**Sub-fases (todas opcionais e independentes):**

### 9a — Cast Time + Buffer de Spell
- [ ] `Spell.CastTime` no schema
- [ ] `Player.CastingSpell *SpellCastState` (spell, started, target, duração)
- [ ] Mover cancela cast (mesma regra do VB6)
- [ ] Frame `CASTING <spellID> <progress>` para o cliente desenhar barra
- [ ] **Referência:** `reference_engine/Server/src/modCombat.bas` `BufferSpell`

### 9b — Trade entre Players
- [ ] Frame `TRADE_REQUEST <playerID>`, `TRADE_OFFER <slot,qty>`, `TRADE_LOCK`, `TRADE_ACCEPT`
- [ ] Modal de trade (2 colunas)
- [ ] Atomicidade: ou ambos ganham/perdem ou ninguém
- [ ] **Referência:** `reference_engine/Client/src/modGameLogic.bas` `BltTrade`

### 9c — Party / Grupo
- [ ] Convite, sair, dissolver
- [ ] XP compartilhado (% para party-mates próximos)
- [ ] HP/MP de party-mates no HUD
- [ ] Cores diferentes no minimap

### 9d — Boss + Respawn Configurável
- [ ] `EnemyDef.IsBoss bool`
- [ ] `EnemyDef.RespawnSec int` (boss respawna em N segundos; 0 = não respawna automático)
- [ ] Anúncio global ao spawnar/morrer boss
- [ ] HP bar gigante no topo da tela quando engajado

### 9e — Chat por Canal
- [ ] Canais: `say` (local, AoI), `shout` (mapa todo), `global`, `party`, `whisper`
- [ ] Cores por canal
- [ ] `/comando` no chat

---

## 🚀 Fase 10 — Build e Distribuição

**Por quê:** sem distribuição, ninguém joga. Engine fica de gaveta.

**Objetivo:** um comando gera artefatos para Win/Linux/Mac.

**Arquivos a criar/tocar:**
- ➕ `scripts/build.sh` — gera `.love`, empacota servidor Go por OS, gera checksum.
- ➕ `Dockerfile` — para deploy do servidor.
- ➕ `.github/workflows/release.yml` — release automatizado em tag git.
- ➕ `docs/DEPLOY.md` — passo a passo VPS.

**Referência:** N/A (engine de referência VB6 era só `.exe` Windows).

**Checklist:**
- [ ] Script de build cliente (.love)
- [ ] Script de build servidor por OS (Linux x64, Win x64, Mac arm64+x64)
- [ ] Versionamento semântico via git tag
- [ ] Checksums (SHA256) gerados junto
- [ ] Dockerfile do servidor
- [ ] docker-compose com Postgres + servidor
- [ ] CI no GitHub Actions: build em PR, release em tag
- [ ] Documentação de deploy em VPS (firewall, systemd, backup)
- [ ] Release na itch.io via butler

---

## 📚 Mapa Rápido de Referência VB6

Quando o Claude Code precisar entender "como o original fazia X", consultar `reference_engine/`:

| Tópico                      | Arquivo VB6                                      |
| --------------------------- | ------------------------------------------------ |
| Editor de NPC               | `Client/src/frmEditor_NPC.frm`                   |
| Editor de Item              | `Client/src/frmEditor_Item.frm`                  |
| Editor de Spell             | `Client/src/frmEditor_Spell.frm`                 |
| Editor de Loja              | `Client/src/frmEditor_Shop.frm`                  |
| Editor de Recurso           | `Client/src/frmEditor_Resource.frm`              |
| Editor de Animação          | `Client/src/frmEditor_Animation.frm`             |
| Propriedades de Mapa (warp) | `Client/src/frmMapProperties.frm`                |
| Compra/venda em loja        | `Server/src/modPlayer.bas` (BuyItem/SellItem)    |
| Buffer de cast de spell     | `Server/src/modCombat.bas` (BufferSpell)         |
| Render de player/NPC        | `Client/src/modDirectDraw7.bas` (BltPlayer/BltNpc) |
| Áudio (música/sfx)          | `Client/src/Bass.bas` + `modSound.bas`           |
| Trade UI                    | `Client/src/modGameLogic.bas` (BltTrade)         |
| Floating combat text        | `Client/src/modGameLogic.bas` (CreateActionMsg)  |
| Roteamento de pacotes       | `Client/src/modEnumerations.bas`                 |
| Loop do servidor (buckets)  | `Server/src/modServerLoop.bas`                   |
| Save em disco (.dat)        | `Server/src/modDatabase.bas`                     |

---

## ✅ Definition of Done (qualquer fase)

- [ ] Objetivo atingido e verificável manualmente
- [ ] Sem hardcode em Go (conteúdo data-driven)
- [ ] Logs suficientes para diagnóstico
- [ ] Documentação mínima atualizada (README, PROTOCOL.md se aplicável)
- [ ] `go build ./...` ✓
- [ ] `go vet ./...` ✓
- [ ] `go test -race ./...` ✓
- [ ] `love client/` abre sem erros no console
- [ ] Schema com `schema_version` se for arquivo novo
- [ ] Sem regressão nas fases anteriores

---

## 🧭 Ordem Recomendada de Execução

1. **Fase 1** (Pickers) — desbloqueia 2, 3, 8
2. **Fase 2** (Múltiplos Mapas) — desbloqueia world building real
3. **Fase 4** (Animações) — visual gigante por código pequeno
4. **Fase 3** (Shop) — completa role merchant
5. **Fase 5** (Postgres) — desbloqueia playtest sério
6. **Fase 6** (Áudio) — feel completo
7. **Fase 8** (Resources/Crafting) — economia
8. **Fase 7** (Editor Web) — quality of life
9. **Fase 9** (Avançado) — escolher por interesse
10. **Fase 10** (Build) — só faz sentido com 1-6 prontas

> Cada fase é entregável independente. Não bloqueia a próxima a menos que indicado.