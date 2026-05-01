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

---

## 🧱 Stack Base

- [ ] **Servidor:** Go (tick-based 30Hz)
- [ ] **Cliente:** Love2D + Lua
- [ ] **Banco:** Postgres
- [ ] **Cache:** Redis
- [ ] **Infra:** Docker + docker-compose para ambiente local

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

### Exemplo de estrutura

```json
{
  "schema_version": 1,
  "width": 100,
  "height": 100,
  "layers": {
    "ground": [[1,1,1]],
    "collision": [[0,1,0]],
    "decoration": [[5,0,2]],
    "logic": [[0,0,0]]
  },
  "entities": [
    { "type": "spawn", "kind": "orc", "x": 10, "y": 5 }
  ]
}
```

### Editor in-game (cliente)

Ativado via tecla (ex: `F1`):

- [x] Pintura de tiles com mouse
- [x] Seleção de tileset
- [x] Alternância de layers
- [x] Inserção de entidades (spawn/NPC)
- [x] Undo/redo simples
- [x] Ferramenta de preenchimento (fill)
- [x] Ferramenta de seleção e cópia de região
- [x] Overlay de grid + coordenadas

### Persistência

- [x] Cliente envia comando `SAVE_MAP <json>`
- [x] Servidor valida payload (tamanho, ids, bounds)
- [x] Servidor salva em `server/data/maps/`
- [x] Backup automático da versão anterior ao sobrescrever

### Backend

- [x] `world.go` com `Map` e `IsWalkable(x, y)`
- [x] Suporte a múltiplas layers no runtime
- [ ] Preparação para chunking (futuro)

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

- [ ] `spawn_entity`
- [ ] `damage_entity`
- [ ] `get_player`
- [ ] `find_entities_in_range`
- [ ] `broadcast`
- [ ] `apply_status`
- [ ] `schedule_event`

### Segurança

- [ ] Sandbox sem `os`, `io`, `debug`
- [ ] Limite de tempo por execução de script
- [ ] Limite de memória/objetos por contexto
- [ ] Lista explícita de funções permitidas (allowlist)

### Hot reload

- [ ] Comando admin `/reload`
- [ ] Reload granular por domínio (`/reload skills`, `/reload enemies`)

### Critério de pronto

- [ ] Criar inimigo novo sem recompilar
- [ ] Alterar comportamento em runtime
- [ ] Falha em script não derruba o servidor

---

## ⚔️ Fase 2.5 — Sistema de Skills (Data + Tipos + Árvore)

### Objetivo

Evitar caos estrutural e permitir expansão organizada.

### Entregas

- [ ] Definição data-driven de skills
- [ ] Handlers por tipo base
- [ ] DSL de efeitos interpretada no servidor
- [ ] Árvore de progressão e validação de unlock

### Exemplo de skill

```lua
return {
  id = "fireball",
  type = "projectile",
  damage = 50,
  mana_cost = 20,
  cooldown = 2.0,
  range = 6,
  scaling = { int = 1.2 },
  effects = {
    { type = "damage", value = 50 },
    { type = "apply_status", status = "burn", duration = 3 }
  }
}
```

### Tipos base (handlers)

- [ ] melee
- [ ] projectile
- [ ] area
- [ ] heal
- [ ] buff
- [ ] debuff

### Skill tree

- [ ] Regras de pré-requisito
- [ ] Custo por ponto de talento
- [ ] Reset de árvore (admin/dev)

### Critério de pronto

- [ ] Criar skill nova sem Go
- [ ] Progressão funcional por árvore
- [ ] Cooldown e custo de mana validados no servidor

---

## 🧍 Fase 3 — Sistema de Entidades (ECS Simplificado)

### Objetivo

Unificar player, NPC e inimigos.

### Entregas

- [ ] Estrutura única de entidade
- [ ] Componentes: Position, Health, Combat, AI, Inventory
- [ ] Sistemas independentes por responsabilidade
- [ ] Serialização de estado para rede

### Benefícios esperados

- [ ] Eliminar duplicação
- [ ] Facilitar expansão de mecânicas
- [ ] Reduzir acoplamento entre gameplay e rede

---

## 🎒 Fase 4 — Sistemas de Jogo

### Inventário

- [ ] Itens definidos em Lua/JSON
- [ ] Drops via script
- [ ] Regras de stack, raridade e bound

### Stats

- [ ] Level, XP e atributos
- [ ] Scaling usado nas skills
- [ ] Regras de progressão configuráveis

### Chat

- [ ] SAY (raio)
- [ ] WHISPER
- [ ] SHOUT
- [ ] Canal de sistema/admin

### NPC

- [ ] Diálogo via Lua
- [ ] Quests básicas orientadas a dados

### Critério de pronto

- [ ] Loop completo: matar → loot → equipar → evoluir → interagir

---

## ⚙️ Fase 5 — Performance e Rede

- [ ] Snapshot diff
- [ ] Área de interesse (AoI)
- [ ] Anti-cheat server-side
- [ ] Logs estruturados (`slog`)
- [ ] Métricas Prometheus
- [ ] Perfil de CPU/memória em ambiente de teste
- [ ] Teste de carga com bots simulados

---

## 🎨 Fase 6 — Cliente (UX + Arte)

- [ ] Sprites animados
- [ ] UI completa (HP/Mana, Skills, Inventário, Chat)
- [ ] Som e partículas
- [ ] Minimapa
- [ ] Feedback visual de hit/heal/status
- [ ] Configuração de keybinds no cliente

---

## 🗄️ Fase 7 — Banco e Migrations

- [ ] Uso de **goose**
- [ ] Migrations append-only
- [ ] Schema versionado
- [ ] Seeds para ambiente dev
- [ ] Rotina de rollback testada

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

### Comandos mínimos de validação

- [ ] `go build ./...`
- [ ] `go vet ./...`
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

---

## 🧠 Filosofia Final

Essa engine não é sobre “rodar um jogo”.

É sobre:

- [ ] Reduzir fricção ao criar conteúdo
- [ ] Iterar rápido
- [ ] Evitar reescrever sistemas

> Se algo exige recompilar Go para ajustar conteúdo, provavelmente está errado.
