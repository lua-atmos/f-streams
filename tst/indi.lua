local S = require("streams")

print "--- SOURCES ---"

do
    print("Testing...", "consts 1")
    local s = S.fr_consts(42)
    assert(s() == 42)
    assert(s() == 42)
    assert(s() == 42)

    print("Testing...", "const 1")
    local s = S.fr_const(42)
    assert(s() == 42)
    assert(s() == nil)
    assert(s() == nil)
end

do
    print("Testing...", "range 1")
    local s = S.fr_range(1, 5)
    local values = S.table(s):to()
    assert(#values == 5 and values[1] == 1 and values[5] == 5)
end

do
    print("Testing...", "table 1")
    s = S.fr_table({1, 2, 3, 4, 5})
    values = S.table(s):to()
    assert(#values == 5 and values[1] == 1 and values[5] == 5)
end

do
    print("Testing...", "__call 1")
    local value = {}
    setmetatable(value, {
        __call = function()
            return 5
        end
    })
    local s = value
    local result = s()
    assert(result == 5)
    local result = s()
    assert(result == 5)
end

do
    print("Testing...", "coro 1")
    local co = coroutine.create(function ()
        coroutine.yield(1)
        coroutine.yield(2)
        coroutine.yield(3)
    end)
    s = S.fr_coroutine(co)
    vs = S.table(s):to()
    assert(#vs==3 and vs[1]==1 and vs[2]==2 and vs[3]==3)
end

do
    print("Testing...", "function 1")
    local n = 0
    s = S.fr_function (
        function ()
            n = n+1
            if n<=3 then
                return n
            end
        end
    )
    local vs = s:table():to()
    assert(#vs==3 and vs[1]==1 and vs[2]==2 and vs[3]==3)
end

do
    print("Testing...", "streams 1")
    local s1 = S.fr_range(1, 3)
    local s2 = S.fr_range(4, 6)
    local s3 = S.fr_range(7, 9)
    local streams = S.from{s1, s2, s3}
    local vs = {}
    streams:tap(function (s)
        s:tap(function (v) vs[#vs+1]=v end):to()
    end):to()
    assert(#vs==9 and vs[1]==1 and vs[5]==5 and vs[9]==9)
end

print "--- COMBINATORS ---"

do
    print("Testing...", "empty 1")
    local s = S.empty()
    assert(s() == nil)
    assert(s() == nil)
end

print "- ACC -"
do
    print("Testing...", "acc 1: +")
    local s = S.from {1, 2, 3}
    s = s:acc0(0, function(a, b) return a + b end)
    local vs = s:table():to()
    assert(#vs==4 and vs[1]==0 and vs[2]==1 and vs[3]==3 and vs[4]==6)

    print("Testing...", "acc 2: *")
    local s = S.from {1, 2, 3}
    s = s:acc0(1, function(a, b) return a * b end)
    local vs = s:table():to()
    assert(#vs==4 and vs[1]==1 and vs[2]==1 and vs[3]==2 and vs[4]==6)

    print("Testing...", "acc 3: {}")
    local s = S.from {}
    s = s:acc0(1, function(a, b) return a + b end)
    local vs = s:table():to()
    assert(#vs==1 and vs[1]==1)
    --assert(vs==1)

    print("Testing...", "acc 4: {1}")
    local s = S.from {5}
    s = s:acc0(0, function(a, b) return a + b end)
    local vs = s:table():to()
    assert(#vs==2 and vs[2]==5)

    print("Testing...", "acc 5: id")
    local s = S.from {1,2,3}
    s = s:acc0(0, function(a, b) return a end)
    local vs = s:table():to()
    assert(#vs==4 and vs[1]==0 and vs[2]==0 and vs[3]==0 and vs[4]==0)

    s = S.fr_range(1, 5)
    local reduced = S.acc0(s, 0, function(a, b) return a + b end):to()
    assert(reduced == 15)
end

print "- TUPLE -"
do
    local s = S.from(function () return 1,2,3 end)
    local t = s:tuple('x'):to_first()
    assert(t.tag=='x' and #t==3 and t[2]==2)
end

print "- TEE -"
do
    print("Testing...", "tee 1")
    local s = S.from({1, 2, 3, 4, 5})
    local s1, s2 = S.tee(s)
    local resultado1 = S.table(s1):to()
    local resultado2 = S.table(s2):to()
    assert(#resultado1==5 and #resultado2==5)
    for i = 1, 5 do
        assert(resultado1[i]==i and resultado2[i]==i)
    end
end

do
    print("Testing...", "map 1")
    s = S.fr_range(1, 5)
    s = S.map(s, function(x) return x * 2 end)
    values = S.table(s):to()
    assert(#values == 5 and values[1] == 2 and values[5] == 10)
    assert(s() == nil)

    print("Testing...", "mapi 1")
    local s = S.from({1, 2, 3})
    local vs = s:mapi(function(x, i)
        return x * i
    end):table():to()
    assert(#vs==3 and vs[1]==1 and vs[2]==4 and vs[3]==9)
end

print("Testing...", "filter 1")
s = S.fr_range(1, 5)
s = S.filter(s, function(x) return x % 2 == 0 end)
values = S.table(s):to()
assert(#values == 2 and values[1] == 2 and values[2] == 4)

print("Testing...", "take 1")
s = S.fr_range(1, 10)
s = S.take(s, 5)
values = S.table(s):to()
assert(#values == 5 and values[1] == 1 and values[5] == 5)

print "--- SORT ---"
do
    -- Teste 1: Ordenação crescente
    local s = S.from({3, 1, 2, 4})
    local t = s:table():sort(function(a, b) return a < b end):to()
    assert(t[1] == 1)
    assert(t[2] == 2)
    assert(t[3] == 3)
    assert(t[4] == 4)

    -- Teste 2: Ordenação decrescente
    local s = S.from({3, 1, 2, 4})
    local t = s:table():sort(function(a, b) return a > b end):to()
    assert(t[1] == 4)
    assert(t[2] == 3)
    assert(t[3] == 2)
    assert(t[4] == 1)

    -- Teste 3: Ordenação com valores repetidos
    local s = S.from({3, 1, 2, 2, 4})
    local t = s:table():sort(function(a, b) return a < b end):to()
    assert(t[1] == 1)
    assert(t[2] == 2)
    assert(t[3] == 2)
    assert(t[4] == 3)
    assert(t[5] == 4)

    -- Teste 4: Ordenação com stream vazio
    local s = S.empty()
    local t = s:table():sort(s, function(a, b) return a < b end)
    assert(t == nil or #t == 0)
end

print "--- XSEQ ---"
do
    print("Testing...", "xseq 0")
    local s = S.empty():xseq()
    assert(s() == nil)

    print("Testing...", "xseq 1")
    local s1 = S.from({1, 2, 3})
    local s2 = S.from({4, 5, 6})
    local s_xseq = S.from{s1,s2}:xseq()
    local t = S.table(s_xseq):to()
print(#t)
    assert(#t == 6)
    for i=1, 6 do
        assert(t[i] == i)
    end

    print("Testing...", "xseq 2")
    local s1 = S.from({})
    local s2 = S.from({1, 2, 3})
    local s_xseq = S.from{s1, s2}:xseq()
    local t = S.table(s_xseq):to()
    assert(#t == 3)
    for i = 1, 3 do
        assert(t[i] == i)
    end
end

print("Testing...", "skip 1")
s = S.fr_range(1, 10)
s = S.skip(s, 5)
values = S.table(s):to()
assert(#values == 5 and values[1] == 6 and values[5] == 10)
assert(s() == nil)

print("Testing...", "coro 1")
local co1 = coroutine.create(function ()
    coroutine.yield(1)
    coroutine.yield(2)
    coroutine.yield(3)
end)
local coA = coroutine.create(function ()
    coroutine.yield('A')
    coroutine.yield('B')
    coroutine.yield('C')
end)
local s1 = S.from(co1)
local sA = S.from(coA)

--[[
local s = S.xseq(s1,sA)
vs = S.table(s):to()
assert(#vs==3 and vs[1]==1 and vs[2]==2 and vs[3]==3)
]]

print "--- TAP ---"
do
    local s = S.fr_range(1, 5)
    local tapped = {}
    s:tap(function(x) table.insert(tapped, x) end):to()
    assert(#tapped == 5)
    assert(tapped[1] == 1)
    assert(tapped[2] == 2)
    assert(tapped[3] == 3)
    assert(tapped[4] == 4)
    assert(tapped[5] == 5)

    local s = S.fr_range(1, 5)
    local tapped = s:tap(function(x) end)
    local result = {}
    tapped:tap(function(x) table.insert(result, x) end):to()
    assert(#result == 5)
    assert(result[1] == 1)
    assert(result[2] == 2)
    assert(result[3] == 3)
    assert(result[4] == 4)
    assert(result[5] == 5)

    s = S.fr_range(1, 5)
    S.tap(s, function(x) assert(x >= 1 and x <= 5) end):to()
    assert(s() == nil)
end

-- SINKS

print "- SUM / MUL / MIN / MAX -"
do
    s = S.fr_range(1, 5)
    local sum = S.sum(s):to()
    assert(sum == 15)
    assert(s() == nil)

    s = S.fr_range(1, 5)
    local mul = S.mul(s):to()
    assert(mul == 120)

    s = S.fr_range(1, 5)
    local min = S.min(s):to()
    assert(min == 1)
    assert(s() == nil)

    s = S.fr_range(1, 5)
    local max = S.max(s):to()
    assert(max == 5)
end

print "-  ANY / ALL / NONE / SOME -"
do
    -- Testes para to_any
    assert(S.from({1, 2, 3}):to_any(function(x) return x > 2 end) == true)
    assert(S.from({1, 2, 3}):to_any(function(x) return x > 3 end) == false)

    -- Testes para to_all
    assert(S.from({1, 2, 3}):to_all(function(x) return x > 0 end) == true)
    assert(S.from({1, 2, 3}):to_all(function(x) return x > 1 end) == false)

    -- Testes para to_none
    assert(S.from({1, 2, 3}):to_none(function(x) return x > 3 end) == true)
    assert(S.from({1, 2, 3}):to_none(function(x) return x > 2 end) == false)

    -- Testes para to_some
    assert(S.from({1, 2, 3, 4}):to_some(function(x) return x > 2 end) == true)
    assert(S.from({1, 2, 3}):to_some(function(x) return x > 3 end) == false)
    assert(S.from({1, 2, 3}):to_some(function(x) return x == 2 end) == false)
end

print '--- TO ---'
do
    local s = S.fr_range(1, 5)
    s:to()
    assert(s() == nil)

    local s = S.fr_range(1, 5)
    local result = s:to()
    assert(result == 5)

    s = S.from(10)
    assert(S.to_first(s) == 10)

    s = S.empty()
    assert(S.to_first(s) == nil)
    assert(S.to_last(s) == nil)
end

-- TODO

--[===[
s = S.fr_table { 1, 3, 1, 1, 2, 3 }
s = S.distinct(s)
values = S.table(s):to()
assert(#values==3 and values[1]==1 and values[2]==3 and values[3]==2)

print "--- LOOP ---"
do
    local function my_stream()
        local i = 0
        return function()
            i = i + 1
            if i <= 3 then
                return i
            end
        end
    end

    local loop_stream = S.loop(my_stream)
    local values = {}
    for i = 1, 10 do
        table.insert(values, loop_stream())
    end
    assert(values[1] == 1)
    assert(values[2] == 2)
    assert(values[3] == 3)
    assert(values[4] == 1)
    assert(values[5] == 2)
    assert(values[6] == 3)
    assert(values[7] == 1)
    assert(values[8] == 2)
    assert(values[9] == 3)
    assert(values[10] == 1)
end

print "--- ZIP ---"
do
    local s1 = S.from(1, 5)
    local s2 = S.from(6, 10)
    local zipped = S.zip(s1, s2)
    local t = {}
    zipped:tap(function(xy) table.insert(t, xy[1]+xy[2]) end):to()
    assert(#t==5 and t[1]==7 and t[5]==15)
end
]===]
