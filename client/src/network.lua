local socket = require("socket")
local M = {}
local sock
local pending  = ""    -- bytes recebidos sem terminador \n ainda
local outQueue = ""    -- bytes pendentes de envio (back-pressure)

local function closeSock(why)
    if sock then
        print("network: closed (" .. tostring(why) .. ")")
        sock:close()
    end
    sock = nil
    pending = ""
    outQueue = ""
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
    flushOut()
end

function M.poll(handler)
    if not sock then return end
    -- Tenta drenar o que estiver pendente de saída a cada poll;
    -- assim mensagens grandes não ficam represadas.
    flushOut()

    while true do
        local line, err, partial = sock:receive("*l")
        if line then
            if #pending > 0 then
                handler(pending .. line)
                pending = ""
            else
                handler(line)
            end
        else
            if partial and #partial > 0 then
                pending = pending .. partial
            end
            if err == "closed" then
                closeSock("recv/closed")
            end
            return
        end
    end
end

function M.close()
    closeSock("explicit")
end

return M