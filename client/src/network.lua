local socket = require("socket")

local M = {}
local sock
local pending = ""

function M.connect(host, port)
    sock = socket.tcp()
    sock:settimeout(2)
    local ok, err = sock:connect(host, port)
    if not ok then
        print("connect failed: " .. tostring(err))
        sock = nil
        return false, err
    end
    sock:settimeout(0)
    return true
end

function M.connected()
    return sock ~= nil
end

function M.send(line)
    if not sock then return end
    local _, err = sock:send(line .. "\n")
    if err == "closed" then
        sock = nil
    end
end

function M.poll(handler)
    if not sock then return end
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
                sock = nil
            end
            return
        end
    end
end

function M.close()
    if sock then sock:close(); sock = nil end
end

return M
