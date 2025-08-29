local M = {}

local MT = {
    __call  = function (t) return t.f() end,
    __close = function () end,
    __index = M,
}

-- SOURCES

function M.from (v, ...)
    if type(v) == 'function' then
        return v
    elseif ... ~= nil then
        return M.fr_range(v, ...)
    elseif v==nil or type(v)=='number' then
        return M.fr_counter(v)
    elseif type(v) == 'table' then
        return M.fr_table(v)
    elseif type(v) == 'coroutine' then
        return M.fr_coroutine(v)
    else
        return M.fr_consts(v)
    end
end

function M.fr_consts (v)
    local f = function ()
        return v
    end
    return setmetatable({f=f}, MT)
end

function M.fr_counter (i)
    return M.fr_range(i)
end

function M.fr_range (a, b)
    a = a or 1
    local f = function ()
        if b and a>b then
            return nil
        end
        local v = a
        a = a + 1
        return v
    end
    return setmetatable({f=f}, MT)
end

function M.fr_table (t)
    local i = 1
    local f = function ()
        if i <= #t then
            local v = t[i]
            i = i + 1
            return v
        end
    end
    return setmetatable({f=f}, MT)
end

function M.fr_coroutine (co)
    local f = function ()
        return (function (_, ...)
            if select('#',...) >= 0 then
                return ...
            end
        end)(coroutine.resume(co))
    end
    return setmetatable({f=f}, MT)
end

-- COMBINATORS

function M.concat(s1, s2)
    local cur = s1
    local f = function ()
        local v = cur()
        if v == nil then
            cur = s2
            v = cur()
        end
        return v
    end
    return setmetatable({f=f}, MT)
end

function M.loop (fs)
    local s = fs()
    local f = function ()
        local v = s()
        if v == nil then
            s = fs()
            v = s()
        end
        return v
    end
    return setmetatable({f=f}, MT)
end

function M.map (s, f)
    local f = function()
        local v = s()
        if v ~= nil then
            return f(v)
        end
    end
    return setmetatable({f=f}, MT)
end

function M.filter (s, f)
    local f =  function()
        local v
        repeat
            v = s()
        until v == nil or f(v)
        return v
    end
    return setmetatable({f=f}, MT)
end

function M.take (s, n)
    local i = 0
    local f =  function()
        if i < n then
            i = i + 1
            return s()
        end
    end
    return setmetatable({f=f}, MT)
end

function M.skip (s, n)
    for _ = 1, n do
        s()
    end
    return s
end

function M.distinct (s)
    local seen = {}
    local f = function ()
        local v
        repeat
            v = s()
        until v == nil or not seen[v]
        if v ~= nil then
            seen[v] = true
        end
        return v
    end
    return setmetatable({f=f}, MT)
end

function M.flatten (ss)
    local current_stream = ss()
    local f = function ()
        while current_stream do
            local v = current_stream()
            if v ~= nil then
                return v
            else
                current_stream = ss()
            end
        end
    end
    return setmetatable({f=f}, MT)
end

-- SINKS

function M.to_first (s)
    return s()
end

function M.to_table (s)
    local t = {}
    local v
    repeat
        v = s()
        if v ~= nil then
            table.insert(t, v)
        end
    until v == nil
    return t
end

function M.to_vector (s)
    return M.to_table(s)
end

function M.to_acc (s, acc, f)
    local v
    repeat
        v = s()
        if v ~= nil then
            if acc == nil then
                acc = v
            else
                acc = f(acc, v)
            end
        end
    until v == nil
    return acc
end

do  -- all based on `to_acc`
    function M.to_sum(s)
        return M.to_acc(s, 0, function(a, b) return a + b end)
    end
    function M.to_mul(s)
        return M.to_acc(s, 1, function(a, b) return a * b end)
    end
    function M.to_min(s)
        return M.to_acc(s, math.huge, function(a, b) return math.min(a, b) end)
    end
    function M.to_max(s)
        return M.to_acc(s, -math.huge, function(a, b) return math.max(a, b) end)
    end
end

function M.to_each (s, f)
    local s <close> = s
    local v
    repeat
        v = s()
        if v ~= nil then
            f(v)
        end
    until v == nil
end

return M
