local M = {}

function M.language ()
    debug.setmetatable(function()end, {
        __pow = function (f, v)
            return function (...)
                return f(v, ...)
            end
        end,
        __shr = function (s, f)
            return f(s)
        end,
    })
end

-- SOURCES

function M.from (v, ...)
    if ... ~= nil then
        return M.fr_range(v, ...)
    elseif v==nil or type(v)=='number' then
        return M.fr_counter(v)
    elseif type(v) == 'table' then
        return M.fr_table(v)
    elseif type(v) == 'coroutine' then
        return M.fr_coroutine(v)
    else
        return M.fr_const(v)
    end
end

function M.fr_const (v)
    return function ()
        return v
    end
end

function M.fr_counter (i)
    return M.fr_range(i)
end

function M.fr_range (a, b)
    a = a or 1
    return function()
        if b and a>b then
            return nil
        end
        local v = a
        a = a + 1
        return v
    end
end

function M.fr_table (t)
    local i = 1
    return function()
        if i <= #t then
            local v = t[i]
            i = i + 1
            return v
        end
    end
end

function M.fr_coroutine (co)
    return function()
        return (function (_, ...)
            if select('#',...) >= 0 then
                return ...
            end
        end)(coroutine.resume(co))
    end
end

-- COMBINATORS

function M.map (f, s)
    return function()
        local v = s()
        if v ~= nil then
            return f(v)
        end
    end
end

function M.filter (f, s)
    return function()
        local v
        repeat
            v = s()
        until v == nil or f(v)
        return v
    end
end

function M.take (n, s)
    local i = 0
    return function()
        if i < n then
            i = i + 1
            return s()
        end
    end
end

function M.skip (n, s)
    for _ = 1, n do
        s()
    end
    return s
end

function M.distinct (s)
    local seen = {}
    return function()
        local v
        repeat
            v = s()
        until v == nil or not seen[v]
        if v ~= nil then
            seen[v] = true
        end
        return v
    end
end

function M.flatten (ss)
    local current_stream = ss()
    return function()
        while current_stream do
            local v = current_stream()
            if v ~= nil then
                return v
            else
                current_stream = ss()
            end
        end
    end
end

-- SINKS

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

function M.to_acc (f, acc, s)
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
        return M.to_acc(function(a, b) return a + b end, 0, s)
    end
    function M.to_mul(s)
        return M.to_acc(function(a, b) return a * b end, 1, s)
    end
    function M.to_min(s)
        return M.to_acc(function(a, b) return math.min(a, b) end, math.huge, s)
    end
    function M.to_max(s)
        return M.to_acc(function(a, b) return math.max(a, b) end, -math.huge, s)
    end
end

function M.to_each (f, s)
    local v
    repeat
        v = s()
        if v ~= nil then
            f(v)
        end
    until v == nil
end

return M
