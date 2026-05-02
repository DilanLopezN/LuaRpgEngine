-- Cliente TCP do engine. Regras (não regredir — quebra os outros checklists do
-- roadmap §🌐 e ressuscita os bugs antigos de input "preso"):
--   1. socket:send é não-bloqueante; sempre tratar (nil, "timeout", last_index).
--   2. outQueue serve de back-pressure de envio — nunca confiar que um único
--      send escoa todos os bytes.
--   3. closeSock zera pending e outQueue sempre que reconectamos para não
--      injetar lixo da sessão anterior.
--   4. tcp-nodelay ativo dos dois lados (servidor já faz o mesmo). Sem isto
--      o input fica visivelmente trêmulo em internet real.
--   5. Heartbeat: respondemos PONG aos PINGs do servidor e disparamos PING
--      próprio se ficamos lastRecvAt-heartbeatTimeout sem ouvir nada.
--   6. Network.poll é chamado em todo love.update ANTES da lógica pesada
--      (ver client/main.lua) — nunca chame este módulo de dentro do render.
--
-- Mexer aqui sem reler essas linhas reabre tickets que já fechamos.
local socket = require("socket")
local M = {}
local sock
local pending  = ""    -- bytes recebidos sem terminador \n ainda
local outQueue = ""    -- bytes pendentes de envio (back-pressure)
local outQueueMax = 0  -- pico de back-pressure observado nesta sessão

local HEARTBEAT_INTERVAL = 10  -- segundos entre PINGs proativos
local HEARTBEAT_TIMEOUT  = 30  -- sem nenhum byte do peer derruba a conn

local lastRecvAt = 0
local lastPingAt = 0

local function closeSock(why)
    if sock then
        print("network: closed (" .. tostring(why) .. ")")
        sock:close()
    end
    sock = nil
    pending = ""
    outQueue = ""
    outQueueMax = 0
    lastRecvAt = 0
    lastPingAt = 0
end

function M.connect(host, port)
    -- Sempre fecha qualquer socket anterior antes de abrir novo,
    -- senão lixo de uma conexão anterior contamina a nova.
    closeSock("reconnect")
    sock = socket.tcp()
    sock:settimeout(2)
    local ok, err = sock:connect(host, port)
    if not ok then
        print("connect failed: " .. tostring(err))
        sock = nil
        return false, err
    end
    sock:settimeout(0)
    sock:setoption("tcp-nodelay", true)  -- evita Nagle empilhar inputs
    lastRecvAt = love.timer.getTime()
    lastPingAt = lastRecvAt
    return true
end

function M.connected()
    return sock ~= nil
end

-- flushOut tenta esvaziar a fila de saída. Em modo não-bloqueante
-- send pode retornar nil + "timeout" + last_index quando o buffer
-- do kernel está cheio; nesse caso guardamos o restante para o
-- próximo poll.
local function flushOut()
    if not sock or #outQueue == 0 then return end
    local sent, err, last = sock:send(outQueue)
    if sent then
        outQueue = outQueue:sub(sent + 1)
        return
    end
    if err == "timeout" and last then
        outQueue = outQueue:sub(last + 1)
        return
    end
    if err == "closed" then
        closeSock("send/closed")
    end
end

function M.send(line)
    if not sock then return end
    outQueue = outQueue .. line .. "\n"
    if #outQueue > outQueueMax then outQueueMax = #outQueue end
    flushOut()
end

-- maxOutQueue expõe o pico de back-pressure desde a última conexão.
-- A HUD usa para mostrar um aviso discreto quando o cliente fica
-- represando bytes (sintoma comum de Wi-Fi ruim ou servidor lento).
function M.maxOutQueue() return outQueueMax end

-- handleHeartbeat absorve PING/PONG sem deixar vazar para o handler do
-- protocolo (não queremos os logs cheios de "unknown verb PING"). Retorna
-- true quando consumiu a linha.
local function handleHeartbeat(line)
    if line == "PING" then
        outQueue = outQueue .. "PONG\n"
        if #outQueue > outQueueMax then outQueueMax = #outQueue end
        flushOut()
        return true
    end
    if line == "PONG" then
        return true
    end
    return false
end

function M.poll(handler)
    if not sock then return end
    -- Tenta drenar o que estiver pendente de saída a cada poll;
    -- assim mensagens grandes não ficam represadas.
    flushOut()

    while true do
        local line, err, partial = sock:receive("*l")
        if line then
            lastRecvAt = love.timer.getTime()
            local full
            if #pending > 0 then
                full = pending .. line
                pending = ""
            else
                full = line
            end
            if not handleHeartbeat(full) then
                handler(full)
            end
        else
            if partial and #partial > 0 then
                pending = pending .. partial
            end
            if err == "closed" then
                closeSock("recv/closed")
                return
            end
            break
        end
    end

    -- Heartbeat saliente. Mandamos PING se ficamos quietos por
    -- HEARTBEAT_INTERVAL segundos; se nada chega de volta em
    -- HEARTBEAT_TIMEOUT, derrubamos a conexão para a UI mostrar erro
    -- — TCP RST pode levar minutos em redes reais e não dá pra esperar.
    local now = love.timer.getTime()
    if lastRecvAt > 0 and (now - lastRecvAt) > HEARTBEAT_TIMEOUT then
        closeSock("heartbeat-timeout")
        return
    end
    if (now - lastPingAt) > HEARTBEAT_INTERVAL then
        outQueue = outQueue .. "PING\n"
        if #outQueue > outQueueMax then outQueueMax = #outQueue end
        flushOut()
        lastPingAt = now
    end
end

function M.close()
    closeSock("explicit")
end

return M