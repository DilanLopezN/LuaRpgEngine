# LuaRpgEngine — Roadmap Técnico (Data-Driven + In-Game Tools)

Engine pessoal de RPG online com cliente em **Love2D (Lua)** e servidor em **Go**, focada em produtividade solo, iteração rápida e arquitetura data-driven.

---

## 🎯 Objetivo

Construir uma engine capaz de:

- [ ] Gerar jogos distribuíveis (Windows/Linux/macOS)
- [ ] Rodar com servidor próprio (VPS)
- [ ] Permitir criação de conteúdo **sem recompilar Go**
- [ ] Editar mapas e conteúdo **dentro do jogo (in-game editor)**
- [ ] Suportar pipeline solo de produção (conteúdo → teste → deploy)

---

## 🧠 Princípios de Arquitetura

- [ ] **Data-driven first:** conteúdo nunca hardcoded
- [ ] **Ferramentas > arquivos:** editar no jogo > editar JSON manual
- [ ] **Iteração rápida:** hot-reload sempre que possível
- [ ] **Baixo acoplamento:** Go executa, Lua define comportamento
- [ ] **Escalável desde cedo:** evitar refactors destrutivos
- [ ] **Observabilidade obrigatória:** todo sistema crítico com logs e métricas
- [ ] **Autoridade do servidor:** cliente nunca decide estado final
- [ ] **Concorrência sem reentrância:** mutexes Go não são reentrantes;
      ordem de aquisição é regra, não sugestão (ver seção 🔒).

---

## 🧱 Stack Base

- [ ] **Servidor:** Go (tick-based 30Hz)
- [ ] **Cliente:** Love2D + Lua
- [ ] **Banco:** Postgres
- [ ] **Cache:** Redis
- [ ] **Infra:** Docker + docker-compose para ambiente local

---

## 🔒 Regras de Concorrência (obrigatórias)

Toda nova funcionalidade que toca gameplay + scripts + DB deve passar
por essa checklist antes do merge.

- [ ] Nunca segurar `Game.mu` durante `L.PCall` (execução de Lua).
- [ ] `ScriptEngine.mu` protege apenas os mapas (skills/items/...).
      `vmMu` é o lock que serializa a VM Lua. NUNCA o mesmo mutex.
- [ ] Toda função do host exposta ao Lua adquire seu próprio lock
      internamente; callbacks não devem assumir lock pré-segurado.
- [ ] Hooks Lua que podem reentrar no host (`damage_entity`,
      `give_item`, `broadcast`) disparam em goroutine separada
      quando chamados de dentro de um tick.
- [ ] `RWMutex` do ECS não é reentrante. Se um sistema precisa do
      estado de outro, passar componentes por argumento — nunca
      chamar `Each` dentro de outro `Each`.
- [ ] Persistência (Postgres/Redis) NUNCA ocorre com `Game.mu`
      segurado. Copiar o snapshot necessário, soltar o lock, depois
      escrever.
- [ ] Ordem de aquisição documentada e respeitada:
      `Game.mu` → `ScriptEngine.mu` → `vmMu` → DB.
      Nunca o inverso. Quem precisa do inverso, copia e libera.
- [ ] Toda mudança suspeita roda com `go test -race ./...` antes do
      commit.

---

## 🌐 Regras de Rede no Cliente

- [ ] `socket:send` é não-bloqueante; sempre tratar retorno parcial
      `(nil, "timeout", last_index)`.
- [ ] `outQueue` para back-pressure de envio; nunca confiar que um
      `send` único vai escoar todos os bytes.
- [ ] `closeSock` limpa `pending` e `outQueue` ao reconectar.
      Reconexão sem reset propaga lixo da sessão anterior.
- [ ] `tcp-nodelay` ativo em ambos os lados — Nagle adiciona
      latência visível em jogos de input curto/frequente.
- [ ] `Network.poll` chama `flushOut` no início para drenar
      mensagens represadas mesmo sem novo `send`.
- [ ] Heartbeat (PING/PONG) a cada N segundos — detecta peer morto
      antes do TCP RST chegar (que pode demorar minutos).
- [ ] Tela de "connecting" tem timeout; se WELCOME não chegar em
      X segundos, volta para a cena de login com erro visível.

---

## 🗺️ Fase 1 — Sistema de Mapa (Data + Editor In-Game)

### Objetivo

Transformar mapa em dado + permitir edição dentro do jogo.

### Entregas

- [x] Definir formato versionado de mapa (`schema_version`)
- [x] Suportar múltiplas layers (`ground`, `collision`, `decoration`, `logic`)
- [x] Inserção de entidades no mapa (spawn/NPC/trigger)
- [x] Loader de mapa no servidor e no cliente
- [x] Colisão baseada em layer de dados
- [ ] **Hardening:** validar `schema_version` recusando versões
      futuras desconhecidas com mensagem clara (não só tamanho).
- [ ] **Hardening:** teste automatizado que carrega o mapa default,
      salva, recarrega e compara — pega regressão de serialização.

### Editor in-game (cliente)

- [x] Pintura de tiles com mouse
- [x] Seleção de tileset
- [x] Alternância de layers
- [x] Inserção de entidades (spawn/NPC)
- [x] Undo/redo simples
- [x] Ferramenta de preenchimento (fill)
- [x] Ferramenta de seleção e cópia de região
- [x] Overlay de grid + coordenadas
- [ ] **Hardening:** garantir que `editorOpen=false` ao perder foco
      da janela; janela arrastada para fora da tela volta com Home
      (já tem) — adicionar auto-recenter no `love.resize`.
- [ ] **Hardening:** `editorFocus` deve sempre limpar com Esc;
      auditar todos os caminhos que setam focus para garantir reset.

### Persistência

- [x] Cliente envia comando `SAVE_MAP <json>`
- [x] Servidor valida payload (tamanho, ids, bounds)
- [x] Servidor salva em `server/data/maps/`
- [x] Backup automático da versão anterior ao sobrescrever
- [ ] **Hardening:** rate-limit de SAVE_MAP (1 por segundo) para
      evitar spam de backups; SAVE_MAP gigante já está coberto pelo
      `saveMapMaxPayload`.

### Backend

- [x] `world.go` com `Map` e `IsWalkable(x, y)`
- [x] Suporte a múltiplas layers no runtime
- [ ] Preparação para chunking (futuro)
- [ ] **Hardening:** broadcast do MAP atualizado para todos os
      jogadores conectados após SAVE_MAP (já existe — confirmar
      que não trava se algum `Out` channel estiver cheio).

### Critério de pronto

- [x] Editar mapa dentro do jogo
- [x] Salvar sem reiniciar servidor
- [x] Colisão funcionando corretamente
- [x] Reabrir mapa salvo e manter consistência dos dados

---

## 🧩 Fase 2 — Scripting (Lua Server-Side)

### Objetivo

Mover comportamento para Lua com segurança.

### Estrutura

```txt
server/data/scripts/
  enemies/
  skills/
  items/
  hooks/
```

### API exposta ao Lua

- [x] `spawn_entity`
- [x] `damage_entity`
- [x] `get_player`
- [x] `find_entities_in_range`
- [x] `broadcast`
- [x] `apply_status`
- [x] `schedule_event`
- [ ] **Hardening:** auditar TODA função exposta para garantir
      que adquire seus próprios locks; nenhuma assume contexto.
- [ ] **Hardening:** funções que mutam estado de gameplay nunca
      são chamadas com `ScriptEngine.mu` segurado.

### Segurança

- [x] Sandbox sem `os`, `io`, `debug`
- [x] Limite de tempo por execução de script
- [x] Limite de memória/objetos por contexto
- [x] Lista explícita de funções permitidas (allowlist)
- [ ] **Hardening:** teste que tenta carregar script com `os.execute`
      e confirma que falha; mesmo para `io.open`, `require`,
      `loadstring`, `dofile`.

### Hot reload

- [x] Comando admin `/reload`
- [x] Reload granular por domínio (`/reload skills`, `/reload enemies`)
- [ ] **Hardening:** reload de hooks fecha a VM antiga e cria nova;
      garantir que goroutines de hooks pendentes não sejam afetadas
      (devem usar referência capturada da VM no momento do disparo).

### Execução de hooks

- [x] `FireHook` separa mapa-lock (`mu`) de VM-lock (`vmMu`).
- [ ] **Hardening:** documentar no comentário de `FireHook` que
      callbacks Lua chamam funções do host que pegam locks próprios
      — referenciar a regra 🔒 acima.
- [ ] **Hardening:** hook que demora mais que `scriptHookTimeout`
      é cancelado via `context`; verificar que o timeout realmente
      interrompe a VM (gopher-lua respeita ctx.Done? testar).

### Critério de pronto

- [x] Criar inimigo novo sem recompilar
- [x] Alterar comportamento em runtime
- [x] Falha em script não derruba o servidor

---

## ⚔️ Fase 2.5 — Sistema de Skills (Data + Tipos + Árvore)

### Objetivo

Evitar caos estrutural e permitir expansão organizada.

### Entregas

- [x] Definição data-driven de skills
- [x] Handlers por tipo base
- [x] DSL de efeitos interpretada no servidor
- [x] Árvore de progressão e validação de unlock
- [ ] **Hardening:** teste unitário para cada handler (melee,
      projectile, area, heal, buff, debuff) cobrindo dano, custo
      de mana, cooldown e alvos válidos.

### Tipos base (handlers)

- [x] melee
- [x] projectile
- [x] area
- [x] heal
- [x] buff
- [x] debuff

### Skill tree

- [x] Regras de pré-requisito
- [x] Custo por ponto de talento
- [x] Reset de árvore (admin/dev)
- [ ] **Hardening:** validar pré-requisitos cíclicos no load
      (`A requires B`, `B requires A` deve falhar com erro claro).

### Critério de pronto

- [x] Criar skill nova sem Go
- [x] Progressão funcional por árvore
- [x] Cooldown e custo de mana validados no servidor

---

## 🧍 Fase 3 — Sistema de Entidades (ECS Simplificado)

### Objetivo

Unificar player, NPC e inimigos.

### Entregas

- [x] Estrutura única de entidade (`server/entity.go`: `Entity`, `ECSWorld`)
- [x] Componentes: Position, Health, Combat, AI, Inventory
- [x] Sistemas independentes por responsabilidade (`server/ecs_systems.go`:
      `MovementSystem`, `HealthSystem`, `AISystem`, `SystemPipeline`)
- [x] Serialização de estado para rede (`Snapshot` / `EntitySnapshot` em
      JSON, com componentes ausentes omitidos)
- [x] AI viva: `server/ai_runtime.go` liga callbacks (Targets/Step/Attack)
      ao `AISystem` para inimigos perseguirem e atacarem players via
      pipeline ECS, sem laços ad-hoc em `Game.tick`.
- [x] Snapshot por componente: `buildSnapshotLocked` lê posição/HP/MP
      dos componentes (`Entity.Position`/`Entity.Health`/`Entity.Combat`)
      ao invés de campos do `Player`/`Enemy`. NPCs já aparecem no
      frame `N` automaticamente via ECS.
- [ ] **Hardening:** auditar callbacks de `AISystem` (Targets/Step/
      Attack) para garantir que nunca chamam `g.scripts.*` que
      pegue `ScriptEngine.mu` enquanto `Game.mu` está segurado
      pelo tick — bug que já travou tudo uma vez.
- [ ] **Hardening:** teste com `-race` cobrindo um tick com 50+
      entidades, validando que `ECSWorld.Each` não é chamado
      reentrante.
- [ ] **Hardening:** quando um sistema precisa de dados de outra
      entidade durante `Each`, copiar para um slice antes —
      evitar segurar `RLock` enquanto chama callback do host.

### Benefícios esperados

- [x] Eliminar duplicação (combate, AI e snapshot convergem em
      primitivas compartilhadas: `combatOutcome`, `pipeline.Tick`,
      `creditKills`).
- [x] Facilitar expansão de mecânicas (novos sistemas plugam no
      `SystemPipeline`; novos kinds aparecem no snapshot sem alterar
      a wire format dos legados).
- [x] Reduzir acoplamento entre gameplay e rede (a serialização lê
      apenas componentes do ECS; gameplay continua em `Player`/`Enemy`
      mas a rede já não depende do layout deles).

---

## 🎒 Fase 4 — Sistemas de Jogo

### Inventário

- [x] Itens definidos em Lua/JSON (`data/scripts/items/*.lua`,
      parser em `server/items.go`).
- [x] Drops via script (Lua API `drop_item(killer, id, qty, chance)`
      consumida pelo hook `enemy_killed` em
      `data/scripts/hooks/loot.lua`).
- [x] Regras de stack, raridade e bound (`ItemDef.Stack`,
      `ItemDef.Rarity`, `ItemDef.Bound`; aplicadas em `addItem`,
      `handleDropItem` recusa dropar bound items).
- [ ] **Hardening:** persistência de inventário (`SaveInventory`)
      ocorre fora de `Game.mu`. Auditar todos os call-sites para
      garantir que copiamos o snapshot e soltamos o lock antes do
      DB call.
- [ ] **Hardening:** `addItem`/`removeItem` sob `Game.mu` apenas;
      nunca disparar hook Lua daí dentro (mover hook para depois
      do unlock, ou para uma goroutine).

### Stats

- [x] Level, XP e atributos (`server/stats.go`: `CStats`, `awardXP`,
      `derivedAttack`/`derivedDefense`).
- [x] Scaling usado nas skills (`applyStatScaling` lido por
      `applyEffects` no cast de skill; `scaling = { int = 1.2 }` agora
      consulta o atributo do caster).
- [x] Regras de progressão configuráveis (`data/scripts/progression.lua`,
      curva XP + ganhos por level).
- [ ] **Hardening:** `awardXP` que dispara level-up encadeado nunca
      reentra em hooks Lua sem soltar `Game.mu` primeiro.

### Chat

- [x] SAY (raio) — `chatSayRadius` em `server/chat.go`.
- [x] WHISPER — entrega 1:1 com fallback `_offline` para alvo ausente.
- [x] SHOUT — global ao mapa com cooldown anti-spam.
- [x] Canal de sistema/admin — `SYS` continua sendo a saída do
      `BroadcastSystem` exposto a scripts.
- [ ] **Hardening:** `BroadcastSystem` chamado de hook Lua nunca
      pode segurar `Game.mu` durante a iteração de outs. Já corrigido
      — adicionar teste que dispara hook que chama broadcast e
      valida com `-race`.

### NPC

- [x] Diálogo via Lua (`data/scripts/npcs/<id>.lua`, runtime em
      `server/npc_runtime.go`, `TALK`/`DIALOG_PICK`/`DIALOG_END`).
- [x] Quests básicas orientadas a dados (`data/scripts/quests/<id>.lua`,
      objetivos kill/item, recompensa em XP/gold/item, persistência
      em `character_quests`).
- [ ] **Hardening:** `DIALOG_PICK` que dispara hook (`quest_start`,
      `quest_complete`) executa o hook fora de `Game.mu` —
      auditar `applyNPCHook`.
- [ ] **Hardening:** `SaveQuest` ocorre fora de `Game.mu`.
      Confirmar todos os call-sites.

### Critério de pronto

- [x] Loop completo: matar → loot → equipar → evoluir → interagir
      (orc dropa `orc_tooth` + `health_potion` via hook; jogador
      equipa `rusty_sword`; XP avança nível por `awardXP`; NPC `elder`
      entrega `orc_hunt` e fecha o ciclo).

---

## ⚙️ Fase 5 — Performance e Rede

- [x] Snapshot diff (`server/snapshot.go`: por jogador, mantém
      `LastSeen` e emite apenas o que mudou; resync completo a cada
      `fullSnapshotEvery`).
- [x] Área de interesse (AoI) — Chebyshev `aoiRadius` em
      `server/snapshot.go`; entidades fora da janela viram linha `X`
      para o cliente derrubar do estado.
- [x] Anti-cheat server-side — `inputThrottle` (token bucket por
      conexão) em `server/input.go`; `MOVE`/`ATTACK`/`global` cada um
      com seu balde; ataque ainda gated por `NextAttack`.
- [x] Logs estruturados (`slog`) — `server/metrics.go` configura o
      handler; `main.go`/`network.go` passam para `mlog.*`.
- [x] Métricas Prometheus — endpoint `/metrics` em `:9091` (default,
      `METRICS_ADDR` para mudar) no formato text exposition; expõe
      conexões, ticks, frames por jogador, lines drop, alocação.
- [x] Teste de carga com bots simulados — `server/cmd/loadtest`,
      executa N conexões com NAME/MOVE/ATTACK randomizados.
- [ ] Perfil de CPU/memória em ambiente de teste (usar
      `go test -cpuprofile` ou `go tool pprof http://localhost:9091/debug/pprof`
      com o loadtest acima — falta gerar baseline gravado).
- [ ] **Hardening rede cliente:** `network.lua` com `outQueue`,
      `closeSock` no reconnect, `tcp-nodelay`, e retorno parcial
      do `socket:send` tratado. Já corrigido — confirmar no commit
      e proibir regressão via comentário no arquivo.
- [ ] **Hardening rede servidor:** `tcp-nodelay` no
      `net.TCPConn` aceito por `HandleConn`.
- [ ] **Hardening:** heartbeat PING/PONG a cada 10s para detectar
      peers mortos; se 30s sem PONG, fecha a conexão.
- [ ] **Hardening:** métrica de `outQueue` máximo por jogador
      no Prometheus para detectar back-pressure no campo.

---

## 🎨 Fase 6 — Cliente (UX + Arte)

- [ ] Sprites animados
- [ ] UI completa (HP/Mana, Skills, Inventário, Chat)
- [ ] Som e partículas
- [ ] Minimapa
- [ ] Feedback visual de hit/heal/status
- [ ] Configuração de keybinds no cliente
- [ ] **Concorrência rede:** `Network.poll` deve rodar em todo
      `love.update`, antes da lógica pesada — render ou áudio
      lento não pode atrasar a recepção de pacotes.
- [ ] **Estado de input:** auditar que `inputBlocked()` reflete
      apenas overlays REALMENTE abertos; fechar overlay sempre
      limpa o flag (testar Esc, clique fora, perder foco).
- [ ] **UI keybinds:** ao capturar próximo input para rebind,
      garantir timeout (5s) e Esc para cancelar — não deixar a
      UI travada esperando uma tecla pra sempre.

---

## 🗄️ Fase 7 — Banco e Migrations

- [ ] Uso de **goose**
- [ ] Migrations append-only
- [ ] Schema versionado
- [ ] Seeds para ambiente dev
- [ ] Rotina de rollback testada
- [ ] **Boot order:** servidor não aceita conexões antes de
      `goose up` rodar com sucesso. Falha de migration = exit 1.
- [ ] **Hardening:** test que cria DB do zero, roda todas as
      migrations, e confirma que `LoadOrCreate` funciona.

---

## 🚀 Fase 8 — Build

- [ ] Geração de `.love` + executáveis
- [ ] Script automatizado de build por plataforma
- [ ] Versionamento semântico nas builds
- [ ] Artefatos assinados/checksum

---

## 🌍 Fase 9 — Deploy

- [ ] VPS (Docker)
- [ ] Postgres + Redis gerenciados
- [ ] Backup automático
- [ ] Firewall configurado
- [ ] Observabilidade mínima (logs + uptime + alertas)
- [ ] **Rede produção:** validar que `tcp-nodelay` está ativo
      em ambos os lados; latência sem ele em internet real
      (>20ms RTT) é visivelmente pior.

---

## 📦 Fase 10 — Distribuição

- [ ] itch.io (butler)
- [ ] GitHub Releases (opcional)
- [ ] Changelog automatizado por release
- [ ] Canal de feedback de jogadores

---

## 🧰 Ferramentas Internas (Crítico)

Modo editor unificado:

- [ ] `F1` → mapa
- [ ] `F2` → entidades
- [ ] `F3` → skills/debug
- [ ] `F4` → spawn tools
- [ ] Painel de inspeção de entidades em tempo real
- [ ] Console de comandos admin/dev embutido
- [ ] **Concorrência:** painel de inspeção lê snapshot do ECS
      via cópia, não segurando `Game.mu` durante a serialização.
- [ ] **Concorrência:** comandos admin que disparam Lua seguem
      regra 🔒 — nunca dentro de `Game.mu`.

---

## ⚠️ Regras de Desenvolvimento

- [ ] Nunca hardcodar conteúdo no Go
- [ ] Tudo configurável via dados ou Lua
- [ ] Scripts sempre sandboxed
- [ ] Protocolo documentado em `docs/PROTOCOL.md`
- [ ] Todo formato de arquivo com `schema_version`
- [ ] Todo sistema novo precisa de telemetria mínima
- [ ] Toda feature crítica precisa de critério de rollback
- [ ] Falhas de script devem degradar com segurança
- [ ] Compatibilidade retroativa de dados quando possível
- [ ] Toda mudança que toca locks roda `go test -race ./...`
- [ ] Toda mudança que toca rede tem teste de reconnect

### Comandos mínimos de validação

- [ ] `go build ./...`
- [ ] `go vet ./...`
- [ ] `go test -race ./...`
- [ ] `love client/`

---

## 🧭 Ordem Recomendada

- [ ] 1. Mapas + editor
- [ ] 2. Migrations
- [ ] 3. Scripting Lua
- [ ] 4. Skills estruturadas
- [ ] 5. ECS
- [ ] 6. Gameplay
- [ ] 7. UI/arte
- [ ] 8. Performance
- [ ] 9. Deploy
- [ ] 10. Distribuição

---

## ✅ Definition of Done (Por Feature)

- [ ] Possui objetivo e escopo claros
- [ ] Possui critério de pronto verificável
- [ ] Possui logs suficientes para diagnóstico
- [ ] Não exige recompilar Go para ajustes de conteúdo
- [ ] Está documentada minimamente
- [ ] Passa em `go test -race ./...` se toca servidor
- [ ] Não viola seção 🔒 (Regras de Concorrência)
- [ ] Não viola seção 🌐 (Regras de Rede no Cliente) se toca rede

---

## 🧠 Filosofia Final

Essa engine não é sobre "rodar um jogo".

É sobre:

- [ ] Reduzir fricção ao criar conteúdo
- [ ] Iterar rápido
- [ ] Evitar reescrever sistemas
- [ ] Não repetir bugs já corrigidos — daí as seções 🔒 e 🌐.

> Se algo exige recompilar Go para ajustar conteúdo, provavelmente está errado.
> Se algo trava o tick do servidor, certamente está errado — e a causa
> quase sempre é violação da seção 🔒.