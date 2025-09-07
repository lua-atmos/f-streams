local M = {}

M.mt = {
    __call  = function (t) return t:f() end,
    __close = function (t) if t.close then t:close() end end,
    __index = M,
}

function M.is (s)
    return (getmetatable(s) == M.mt)
end

-------------------------------------------------------------------------------
-- SOURCES
-------------------------------------------------------------------------------

function M.from (v, ...)
    local multi = (select('#',...) > 0)
    if multi then
        assert(type(v)=='number' or M.is(v))
    end

    if v==nil or type(v)=='number' then
        return M.fr_range(v, ...)
    elseif type(v) == 'table' then
        return M.fr_table(v)
    elseif type(v) == 'function' then
        return M.fr_function(v)
    elseif type(v) == 'coroutine' then
        return M.fr_coroutine(v)
    else
        return M.fr_consts(v)
    end
end

-------------------------------------------------------------------------------

local function fr_consts (t)
    return t.v
end

function M.fr_consts (v)
    local t = {
        v = v,
        f = fr_consts,
    }
    return setmetatable(t, M.mt)
end

function M.fr_const (v)
    return M.fr_consts(v):take(1)
end

-------------------------------------------------------------------------------

local function fr_coroutine (t)
    return (function (_, ...)
        if select('#',...) >= 0 then
            return ...
        end
    end)(coroutine.resume(t.co))
end

function M.fr_coroutine (co)
    local t = {
        co = co,
        f  = fr_coroutine,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

function M.fr_counter (i)
    return M.fr_range(i)
end

-------------------------------------------------------------------------------

local function fr_range (t)
    if t.b and t.a>t.b then
        return nil
    end
    local v = t.a
    t.a = t.a + 1
    return v
end

function M.fr_range (a, b)
    local t = {
        a = a or 1,
        b = b,
        f = fr_range,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

local function fr_table (t)
    if t.i <= #t.t then
        local v = t.t[t.i]
        t.i = t.i + 1
        return v
    end
end

function M.fr_table (t)
    local t = {
        t = t,
        i = 1,
        f = fr_table,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------
-- COMBINATORS
-------------------------------------------------------------------------------

local function empty (t)
    return nil
end

function M.empty ()
    local t = {
        f = empty,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

local function acc (t)
    local v = t.s()
    if v ~= nil then
        t.cur = t.g(t.cur, v)
        return t.cur
    end
end

function M.acc (s, z, g)
    local t = {
        s   = s,
        g   = g,
        cur = z,
        f   = acc,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

function M.map (s, f)
    return M.acc(s, nil, function (_, x) return f(x) end)
end

function M.take (s, n)
    local i = 0
    return M.acc(s, nil, function (_, x)
        i = i + 1
        if i <= n then
            return x
        end
    end)
end

function M.tap (s, f)
    return M.acc(s, nil, function (_, x)
        f(x)
        return x
    end)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local function distinct (t)
    local v = t.s()
    while true do
        if v == nil then
            return nil
        elseif not t.seen[v] then
            t.seen[v] = true
            return v
        end
        v = t.s()
    end
end

function M.distinct (s)
    local t = {
        s = s,
        seen = {},
        f = distinct,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

local function filter (t)
    local v
    repeat
        v = t.s()
    until v==nil or t.p(v)
    return v
end

function M.filter(s, p)
    local t = {
        s = s,
        p = p,
        f = filter,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

local function loop (t)
    local v = t.s()
    if v == nil then
        t.s = t.fs()
        v = t.s()
    end
    return v
end

function M.loop (fs)
    local t = {
        fs = fs,
        s  = fs(),
        f  = loop,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

function M.skip (s, n)
    for _=1, n do
        s()
    end
    return s
end

-------------------------------------------------------------------------------

local function zip (t)
    local v1 = t.s1()
    local v2 = t.s2()
    if v1~=nil and v2~=nil then
        return {v1, v2}
    else
        return nil
    end
end

function M.zip (s1, s2)
    local t = {
        s1 = s1,
        s2 = s2,
        f  = zip,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------

local function xseq (t)
    local x = t.cur()
    while x == nil do
        t.cur = t.src()
        if t.cur == nil then
            return nil
        end
        x = t.cur()
    end
    return x
end

function M.xseq (ss)
    local t = {
        src = ss,
        cur = ss(),
        f = xseq,
    }
    return setmetatable(t, M.mt)
end

-------------------------------------------------------------------------------
-- SINKS
-------------------------------------------------------------------------------

function M.to (s)
    M.to_acc(s, nil, function() end)
end

function M.to_first (s)
    return s()
end

function M.to_acc (s, acc, f)
    local s <close> = s
    local v = s()
    while v ~= nil do
        acc = f(acc, v)
        v = s()
    end
    return acc
end

do  -- all derived from `to_acc`
    function M.to_each (s, f)
        return M.to_acc(s, nil, function(a,...) f(...) ; return true end)
    end

    function M.to_print (s)
        return s:to_each(function (...) print(...) end)
    end

    function M.to_max (s)
        return M.to_acc(s, -math.huge, function(a,x) return math.max(a,x) end)
    end

    function M.to_min (s)
        return M.to_acc(s, math.huge, function(a,x) return math.min(a,x) end)
    end

    function M.to_mul (s)
        return M.to_acc(s, 1, function(a,x) return a*x end)
    end

    function M.to_sum (s)
        return M.to_acc(s, 0, function(a,x) return a+x end)
    end

    function M.to_table (s)
        return M.to_acc(s, {}, function(a,x) a[#a+1]=x ; return a end)
    end

    function M.to_vector (s)
        return M.to_table(s)
    end
end

return M
