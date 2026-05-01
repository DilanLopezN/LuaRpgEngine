-- Minimal JSON encoder/decoder used to ship maps between the Go server and
-- the Love2D client. Handles strings, numbers, booleans, null, arrays and
-- objects — that's all the map format needs. Not a general-purpose lib;
-- doesn't try to round-trip arbitrary Lua tables (anything with non-integer
-- numeric keys is treated as an object).

local M = {}

local function encode_string(s)
    return '"' .. s:gsub('\\', '\\\\')
                   :gsub('"', '\\"')
                   :gsub('\n', '\\n')
                   :gsub('\r', '\\r')
                   :gsub('\t', '\\t') .. '"'
end

local encode_value

local function is_array(t)
    local n = 0
    for k in pairs(t) do
        if type(k) ~= "number" then return false end
        n = n + 1
    end
    for i = 1, n do
        if t[i] == nil then return false end
    end
    return true, n
end

encode_value = function(v)
    local tv = type(v)
    if v == nil then return "null"
    elseif tv == "boolean" then return v and "true" or "false"
    elseif tv == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return "null" end
        if v == math.floor(v) and math.abs(v) < 1e15 then
            return string.format("%d", v)
        end
        return tostring(v)
    elseif tv == "string" then return encode_string(v)
    elseif tv == "table" then
        local arr, n = is_array(v)
        if arr then
            local parts = {}
            for i = 1, n do parts[i] = encode_value(v[i]) end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = encode_string(tostring(k)) .. ":" .. encode_value(val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
end

function M.encode(v) return encode_value(v) end

local pos
local src

local function skip_ws()
    while pos <= #src do
        local c = src:byte(pos)
        if c == 32 or c == 9 or c == 10 or c == 13 then
            pos = pos + 1
        else
            return
        end
    end
end

local parse_value

local function parse_string()
    local out = {}
    pos = pos + 1
    while pos <= #src do
        local c = src:sub(pos, pos)
        if c == '"' then pos = pos + 1; return table.concat(out)
        elseif c == "\\" then
            local n = src:sub(pos + 1, pos + 1)
            if     n == '"' then out[#out + 1] = '"'
            elseif n == "\\" then out[#out + 1] = "\\"
            elseif n == "/" then out[#out + 1] = "/"
            elseif n == "n" then out[#out + 1] = "\n"
            elseif n == "r" then out[#out + 1] = "\r"
            elseif n == "t" then out[#out + 1] = "\t"
            elseif n == "b" then out[#out + 1] = "\b"
            elseif n == "f" then out[#out + 1] = "\f"
            elseif n == "u" then
                local hex = src:sub(pos + 2, pos + 5)
                local code = tonumber(hex, 16) or 0
                if code < 128 then
                    out[#out + 1] = string.char(code)
                else
                    out[#out + 1] = "?"
                end
                pos = pos + 4
            else out[#out + 1] = n end
            pos = pos + 2
        else
            out[#out + 1] = c
            pos = pos + 1
        end
    end
    error("unterminated string")
end

local function parse_number()
    local s = pos
    while pos <= #src do
        local c = src:sub(pos, pos)
        if c:match("[%-%+%d%.eE]") then
            pos = pos + 1
        else
            break
        end
    end
    return tonumber(src:sub(s, pos - 1))
end

local function parse_array()
    pos = pos + 1
    local out = {}
    skip_ws()
    if src:sub(pos, pos) == "]" then pos = pos + 1; return out end
    while true do
        skip_ws()
        out[#out + 1] = parse_value()
        skip_ws()
        local c = src:sub(pos, pos)
        if c == "," then pos = pos + 1
        elseif c == "]" then pos = pos + 1; return out
        else error("expected , or ] in array") end
    end
end

local function parse_object()
    pos = pos + 1
    local out = {}
    skip_ws()
    if src:sub(pos, pos) == "}" then pos = pos + 1; return out end
    while true do
        skip_ws()
        if src:sub(pos, pos) ~= '"' then error("expected string key") end
        local k = parse_string()
        skip_ws()
        if src:sub(pos, pos) ~= ":" then error("expected : after key") end
        pos = pos + 1
        skip_ws()
        out[k] = parse_value()
        skip_ws()
        local c = src:sub(pos, pos)
        if c == "," then pos = pos + 1
        elseif c == "}" then pos = pos + 1; return out
        else error("expected , or } in object") end
    end
end

parse_value = function()
    skip_ws()
    local c = src:sub(pos, pos)
    if     c == '"' then return parse_string()
    elseif c == "{" then return parse_object()
    elseif c == "[" then return parse_array()
    elseif c == "t" then pos = pos + 4; return true
    elseif c == "f" then pos = pos + 5; return false
    elseif c == "n" then pos = pos + 4; return nil
    else                return parse_number() end
end

function M.decode(s)
    src = s
    pos = 1
    local ok, v = pcall(parse_value)
    if not ok then return nil, v end
    return v
end

return M
