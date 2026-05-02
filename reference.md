# reference_engine — mapa rápido

Engine VB6 (≈55k LOC) que serve de inspiração para a nossa em Lua + Go.
Origem: cliente "Naruto Inner Power-vBeta" (Eclipse Origins-like). Stack
original: VB6 + DirectDraw7 + WinSock + arquivos `.dat`/`.ini`.

Use este arquivo como **índice por feature**: bate o nome do que precisa,
abre o arquivo certo direto. Não tente "ler tudo" — é grande e cheio de
gambiarra histórica.

## Layout do diretório

```
reference_engine/
├── Client/
│   ├── client.vbp                          (project file VB6)
│   ├── data files/
│   │   ├── config.ini
│   │   ├── graphics/                       (sprites, tilesets, GUI, anims)
│   │   ├── maps/                           (cache local de mapas .dat)
│   │   ├── music/  sound/  logs/
│   └── src/
│       ├── frmMain.frm                     (janela principal do cliente)
│       ├── frmMenu.frm  frmIndex.frm       (login / seleção de char)
│       ├── frmEditor_Map.frm               (editor in-game de mapa)
│       ├── frmEditor_Item.frm
│       ├── frmEditor_NPC.frm
│       ├── frmEditor_Spell.frm + _OLD      (editor + versão antiga)
│       ├── frmEditor_Resource.frm          (recursos coletáveis)
│       ├── frmEditor_Shop.frm
│       ├── frmEditor_Animation.frm         (sprite-sheet anim)
│       ├── frmDrop.frm  frmCT.frm  frmBAN.frm  frmVIP.frm
│       ├── frmChatPrivado.frm  frmAjuda.frm  frmMapProperties.frm
│       ├── modClientTCP.bas       (envio + recv + TCP raw)
│       ├── modHandleData.bas      (parser de pacotes do servidor)
│       ├── modGameLogic.bas       (loop do cliente, movimento, FX)
│       ├── modDirectDraw7.bas     (render / blits / sprites / paperdoll)
│       ├── modGameEditors.bas     (ligação form ↔ payload)
│       ├── modInput.bas           (teclado/mouse + hotkeys)
│       ├── modSound.bas  Bass.bas (BASS.dll wrapper p/ áudio)
│       ├── modText.bas            (renderização de texto outline/sombra)
│       ├── modConstants.bas       (UI offsets, paths, MAX_*)
│       ├── modEnumerations.bas    (ServerPackets, ClientPackets, Stats…)
│       ├── modTypes.bas           (Player, Map, Item, Tile… do cliente)
│       ├── modGlobals.bas         (estado mutável global)
│       ├── modDatabase.bas        (load/save dos arquivos locais)
│       ├── modGeneral.bas         (utils + init)
│       └── clsBuffer.cls          (buffer de bytes p/ pacotes)
├── Server/
│   ├── server.vbp  Server.exe  EO Account/Player Editor.exe
│   ├── data/
│   │   ├── accounts/  banks/  logs/  orgs/
│   │   ├── maps/        (300 mapas .dat)
│   │   ├── items/       (259 itens .dat)
│   │   ├── npcs/        (255 NPCs .dat)
│   │   ├── spells/      (379 spells .dat)
│   │   ├── quests/      (255 quests .dat)
│   │   ├── resources/   (100 resources)
│   │   ├── animations/  shops/
│   │   ├── classes.ini  options.ini
│   │   ├── banlist.txt  Banidos.txt  kages.txt  lendario.txt
│   └── src/
│       ├── frmServer.frm           (janela admin do servidor)
│       ├── frmEditor_Quest.frm     (editor de quest server-side)
│       ├── frmEditPlayer.frm       (editor de personagem)
│       ├── modServerLoop.bas       (loop principal: tmr25/500/1000/120000)
│       ├── modServerTCP.bas        (Winsock, accept, IO)
│       ├── modHandleData.bas       (recebe e roteia pacotes do cliente)
│       ├── modGameLogic.bas        (8.8k linhas — coração do gameplay)
│       ├── modPlayer.bas           (4.4k — getters/setters/inv/level)
│       ├── modCombat.bas           (3.3k — dano, vitals, DoT/HoT, stun)
│       ├── modScriptedSpell.bas    (case hardcoded por spell)
│       ├── modScriptedItem.bas     (case hardcoded por item)
│       ├── modScriptedNPC.bas      (NpcAttack / OnSigh / scripts)
│       ├── modScriptedQuest.bas    (StartQuest / EndQuest)
│       ├── modScriptedMap.bas      (ScriptedTile / ScriptedClick)
│       ├── modDatabase.bas         (LoadX/SaveX por arquivo binário)
│       ├── modConstants.bas        (MAX_PLAYERS=200, MAX_INV=35, etc.)
│       ├── modEnumerations.bas     (mesmos enums do cliente)
│       ├── modEditores.bas         (admin commands em runtime)
│       ├── modTypes.bas            (PlayerRec, MapRec, ItemRec, …)
│       ├── modGlobals.bas          (Server* state)
│       ├── modGeneral.bas          (init/shutdown/log)
│       ├── modSysTray.bas          (taskbar tray)
│       ├── VIPS.frm                (UI cash-shop)
│       └── clsBuffer.cls           (buffer espelho do cliente)
└── pasta char novo/                (sprite sheets soltos para chars novos)
```

## Onde achar cada coisa (por feature)

| Quero ver…                            | Server                                  | Client                                  |
|---------------------------------------|-----------------------------------------|-----------------------------------------|
| **Tick / loop principal**             | `modServerLoop.bas` `Sub ServerLoop`    | `modGameLogic.bas` `Sub GameLoop`       |
| **Wire format dos pacotes**           | `modEnumerations.bas` `Public Enum ServerPackets / ClientPackets` (mesmo arquivo nos dois lados) |
| **Roteador de pacotes**               | `modHandleData.bas` `InitMessages` + `HandleData` | `modHandleData.bas` `InitMessages` + `HandleData` |
| **Send helpers (cliente → servidor)** | —                                       | `modClientTCP.bas` (`SendPlayerMove`, `SendUseItem`, `CastSpell`, …) |
| **Send helpers (servidor → cliente)** | `modServerTCP.bas`                      | —                                       |
| **Map record / tilemap**              | `modTypes.bas` `Type MapRec` + `TileRec` | `modTypes.bas` `TileRec`                |
| **Camadas de mapa (ground/mask/fringe)** | `modEnumerations.bas` `Public Enum MapLayer` (Ground/Autotile/Mask/Mask2/Fringe/Fringe2) |
| **Editor de mapa (in-game)**          | (load/save apenas)                      | `frmEditor_Map.frm` + `modGameEditors.bas` |
| **Spawn de NPCs / items / resources** | `modGameLogic.bas` `SpawnNpc`, `SpawnMapItems`, `CacheResources` |
| **Movimento do player (autoritativo)**| `modPlayer.bas` `PlayerMove` / `ForcePlayerMove` | `modGameLogic.bas` `ProcessMovement`, `CheckMovement`, `IsTryingToMove` |
| **AI de NPC (chase / attack / range)** | `modGameLogic.bas` `NpcMove`, `CanNpcMove` + `modCombat.bas` `TryNpcAttackPlayer` |
| **Combate / dano**                    | `modCombat.bas` (toda a lógica)         | (visual / popup) `modGameLogic.bas` `CreateActionMsg` |
| **Skills/Spells (data + runtime)**    | `modCombat.bas` `BufferSpell`/`CastSpell`, `modScriptedSpell.bas` `ScriptedSpell Select Case` | `modGameLogic.bas` `CastSpell` |
| **Cooldowns**                         | `TempPlayer(i).SpellCD()` em `modTypes.bas` + checagem no `modCombat.bas` |
| **Cast time / cast bar**              | `TempPlayer(i).spellBuffer` em `modServerLoop.bas` (loop 25 ms) |
| **DoT / HoT (status)**                | `modCombat.bas` `AddDoT_Player`, `HandleDoT_Player`, `AddHoT_Player` (loop 25 ms) |
| **Stun**                              | `modCombat.bas` `StunPlayer`/`StunNPC`  | (visual flag) `SendStunned` |
| **Inventory + equipment**             | `modPlayer.bas` `GiveInvItem`, `TakeInvItem`, `PlayerSwitchInvSlots`, `PlayerUnequipItem` | `modGameLogic.bas` + `BltInventory`/`BltEquipment` |
| **Drop / pick up no chão**            | `modGameLogic.bas` `SpawnItem`/`SpawnItemSlot` + `PlayerMapGetItem`/`PlayerMapDropItem` |
| **Banco**                             | `modPlayer.bas` `FindOpenBankSlot` + handlers `Deposit/Withdraw/CloseBank` |
| **Trade entre jogadores**             | `modHandleData.bas` `HandleTradeRequest`, `HandleAcceptTrade`, … |
| **Shops**                             | `modGameLogic.bas` `OpenShop` (cliente) + handlers `BuyItem/SellItem` (servidor) |
| **Hotbar**                            | `modPlayer.bas` HotbarRec + handlers `HotbarChange`/`HotbarUse` | `modGameLogic.bas` `IsHotbarSlot` + `BltHotbar` |
| **Stats / level up / XP**             | `modPlayer.bas` `CheckPlayerLevelUp`, `GetPlayerExp`, `GivePlayerEXP` |
| **Classes**                           | `modDatabase.bas` `LoadClasses` + `data/classes.ini` |
| **Quests**                            | `modGameLogic.bas` `StartQuest`, `QuestCompleta`, `CheckQuest*` + `modScriptedQuest.bas` |
| **NPCs scripted (boss / quest giver)**| `modScriptedNPC.bas` `ScriptedNpc`/`NpcAttack`/`NpcOnSigh` |
| **Itens scripted (consumível, key)**  | `modScriptedItem.bas` `ScriptedItem` |
| **Tile scripted (warp, gatilho)**     | `modScriptedMap.bas` `ScriptedTile`/`ScriptedClick` |
| **Pet / summon**                      | `modCombat.bas` `PetFollowOwner`, `PetWander`, `PetDisband` |
| **Party**                             | `modGameLogic.bas` `Party_Invite`, `Party_PlayerLeave`, `Party_ShareExp`, `Party_CountMembers` |
| **Chat / mensagens**                  | `modHandleData.bas` `HandleSayMsg`/`HandlePlayerMsg`/`HandleBroadcastMsg` |
| **Save/load do char (formato .dat)**  | `modDatabase.bas` `SavePlayer`/`LoadPlayer` |
| **Save/load de items/spells/npcs**    | `modDatabase.bas` `Save{Item,Spell,Npc,Resource,Shop,Animation}` + `Load*` |
| **Render do mundo**                   | —                                       | `modDirectDraw7.bas` `BltMapTile`/`BltMapFringeTile`/`BltPlayer`/`BltNpc`/`BltAnimation` |
| **Render UI (HP/MP, inventário)**     | —                                       | `modDirectDraw7.bas` `BltHotbar`/`BltInventory`/`BltEquipment`/`BltTrade` |
| **Áudio (BGM + SFX)**                 | —                                       | `Bass.bas` (wrapper BASS.dll) + `modSound.bas` |
| **Animações de mapa**                 | `modGameLogic.bas` `SendAnimation`      | `modGameLogic.bas` `AddAnim`/`CheckMapAnim` + `BltAnimation` |
| **Floating combat text**              | —                                       | `modGameLogic.bas` `CreateActionMsg`/`ClearActionMsg` |
| **Ban / kick / acessos**              | `modDatabase.bas` `BanIndex`/`ServerBanIndex` + `modHandleData.bas` `HandleBanPlayer`/`HandleSetAccess` |
| **Ping**                              | `modHandleData.bas` `HandleCheckPing`   | `modGameLogic.bas` `DrawPing` |
| **Menu / login / criação de char**    | `modHandleData.bas` handlers `HandleNewAccount`, `HandleAddChar`, `HandleUseChar` (server) | `frmMenu.frm` / `frmIndex.frm` |
| **Constantes de gameplay (MAX_*)**    | `modConstants.bas` (MAX_PLAYERS=200, MAX_INV=35, MAX_HOTBAR=12, MAX_PLAYER_SPELLS=35, MAX_SPELLS=350, MAX_LEVELS=10000) |
| **Posições/offsets de UI**            | —                                       | `modConstants.bas` (HotbarTop/Left, InvTop/Left, EqTop/Left, …) |

## Pontos de inspiração concretos

Coisas que vale **trazer para nossa engine**:

- **Roteamento por enum de pacotes**. `ServerPackets`/`ClientPackets`
  com nomes simbólicos batendo dos dois lados elimina mismatch silencioso.
  Nosso `protocol.lua` + `handleLine` em Go já segue parecido, mas
  adotar uma enum espelhada (gerada de `docs/PROTOCOL.md`) fecharia o
  loop. Ver `modEnumerations.bas`.

- **Tick em buckets de tempo**. `modServerLoop.bas` faz 4 buckets
  (`tmr25`, `tmr500`, `tmr1000`, `tmr120000`) em vez de UM tick
  uniforme. Nosso 30 Hz cobre tudo, mas separar checagens caras
  (regen/save) em buckets de 1 s/5 min reduz custo médio.

- **DoT/HoT por slot indexado**. `TempPlayer(i).DoT(1 To MAX_DOTS)`
  com `Used As Boolean` evita realloc do slice e é extremamente
  cache-friendly. Cabe na nossa `Status` se quisermos limitar a N
  efeitos simultâneos por entidade.

- **Spell buffer + cast time**. O `spellBuffer` (Spell, Timer,
  Target, tType) representa "estou conjurando, cancela se mover".
  Nosso `SkillCDs` só rastreia cooldown — falta cast time. Modelo
  pronto em `modCombat.bas` `BufferSpell` + `modServerLoop.bas`
  loop 25 ms.

- **Editor in-game multi-tipo**. Já temos editor de mapa e spells;
  os formulários `frmEditor_Item/NPC/Resource/Shop/Animation/Quest`
  mostram o mesmo padrão (carregar arquivo, render preview, "Save"
  manda o blob completo de volta). Ótimo template para Phase 7+.

- **Layers de mapa nomeadas**: Ground / Autotile / Mask / Mask2 /
  Fringe / Fringe2. Nosso `MapLayers` tem 4 (ground/collision/
  decoration/logic). Adicionar Mask2/Fringe2 dá camadas para
  efeitos por cima do player sem grunwork.

- **Tipos de item via `Type` byte + `Data1/2/3`**. `ItemRec.Type` +
  `Data1`/`Data2`/`Data3` cobre todos os casos (consumable, weapon,
  armor, key, currency) sem subclasse. Funciona para a nossa
  `ItemDef` se quisermos remover slot+stack+bound em favor desse
  modelo achatado.

- **Resources coletáveis**: `ResourceRec` (árvore que vira toco,
  veio de minério, etc.) com `RespawnTime` é a peça mais simples
  para gameplay de farm. Não temos isso ainda — bom alvo de Phase 7.

- **Pets/summons** (`PetRec` no `modTypes.bas` + `modCombat.bas`
  `PetFollowOwner`/`PetWander`/`PetDisband`): summon que segue o
  dono e ataca alvos. Boa referência se a Phase 6+ tiver companions.

## Pontos a **NÃO** copiar

- **VB6 globals + `Public Foo As Bar` em escopo de módulo**: o
  servidor mantém `Player(1 To 200)` como array global. Nosso ECS
  + maps por ID já é melhor; não regredir.

- **Concorrência inexistente**: o server é single-threaded com
  `Sleep` e timers; toda escrita em arrays globais é serializada
  pelo loop. Nosso modelo (Game.mu, ScriptEngine.mu, vmMu) já
  resolve isso. Não tente copiar o "tudo num lock só".

- **`Select Case` gigante para spell scripts** (`modScriptedSpell.bas`
  com 1k+ linhas de Case). Nossa via Lua já é melhor — só precisa
  garantir que dá pra fazer o mesmo sem sair do data-driven.

- **DirectDraw7**: deprecated há ~20 anos. LÖVE2D já cobre o
  espaço. Use o módulo só como referência de **o que** é renderizado
  (paperdoll, animações, blood, beast mode), não como **como** renderizar.

- **Persistência em `.dat` binário**: leitura ad-hoc com `Get #` /
  `Put #` nos arrays — sem versão de schema, sem migration. Nosso
  Postgres + JSON com `schema_version` é o caminho certo.

- **Anti-cheat por flags `TempPlayer.GanhouEXP/SetExp/SetPoints`**:
  validações rasas que dependem da boa fé do servidor saber a
  ordem dos eventos. Use como **lista de superfícies a proteger**,
  não como exemplo de código.

- **String com tamanho fixo** (`Name As String * NAME_LENGTH`):
  artifício do VB6 para arrays binários. Em Go/Lua é só `string`
  + bound check no parser.

## Codificação dos arquivos

`.bas`/`.frm` são **ISO-8859-1 com CRLF** (Windows VB6). Comentários
usam acentos PT-BR (`çãéí`). Se ler com `cat`/`grep` direto, vai sair
caractere quebrado — não é corrupção, é só mojibake. Para visualização
limpa: `iconv -f cp1252 -t utf-8 < arquivo.bas`.

## Atalhos úteis quando precisar de referência

```bash
# Onde está implementado o pacote/handler X (servidor)?
grep -an "Handle$X" reference_engine/Server/src/modHandleData.bas

# Como o cliente envia X?
grep -an "Sub Send" reference_engine/Client/src/modClientTCP.bas | grep -i X

# Encontrar todas as funções de um módulo (server):
grep -aE "^(Public Sub|Public Function|Sub |Function )" \
  reference_engine/Server/src/modPlayer.bas

# Listar todos os pacotes do enum:
grep -aA 200 "^Public Enum ServerPackets" \
  reference_engine/Server/src/modEnumerations.bas
```

## Resumo da arquitetura (uma frase)

> Cliente VB6 com loop próprio renderiza tilemap em DirectDraw7 e
> manda inputs por TCP raw (Winsock, byte buffer). Servidor VB6
> single-thread roda um loop 25 ms (com sub-buckets em 500/1000 ms),
> tudo persistido em `.dat` binários e `.ini`. Conteúdo
> (items/spells/npcs/quests/maps) é editado in-game pelo admin via
> formulários dedicados, salvos no servidor, e cacheados no cliente.
