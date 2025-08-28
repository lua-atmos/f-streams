local S = require("streams")

print "--- SOURCES ---"

print("Testing...", "consts 1")
local s = S.fr_consts(42)
assert(s() == 42)
assert(s() == 42)
assert(s() == 42)

print("Testing...", "range 1")
local s = S.fr_range(1, 5)
local values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

print("Testing...", "table 1")
s = S.fr_table({1, 2, 3, 4, 5})
values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

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

print("Testing...", "coro 1")
local co = coroutine.create(function ()
    coroutine.yield(1)
    coroutine.yield(2)
    coroutine.yield(3)
end)
s = S.fr_coroutine(co)
vs = S.to_table(s)
assert(#vs==3 and vs[1]==1 and vs[2]==2 and vs[3]==3)

print "--- COMBINATORS ---"

print("Testing...", "map 1")
s = S.fr_range(1, 5)
s = S.map(s, function(x) return x * 2 end)
values = S.to_table(s)
assert(#values == 5 and values[1] == 2 and values[5] == 10)
assert(s() == nil)

print("Testing...", "filter 1")
s = S.fr_range(1, 5)
s = S.filter(s, function(x) return x % 2 == 0 end)
values = S.to_table(s)
assert(#values == 2 and values[1] == 2 and values[2] == 4)

print("Testing...", "take 1")
s = S.fr_range(1, 10)
s = S.take(s, 5)
values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

s = S.fr_range(1, 10)
s = S.skip(s, 5)
values = S.to_table(s)
assert(#values == 5 and values[1] == 6 and values[5] == 10)
assert(s() == nil)

s = S.fr_range(1, 5)
s = S.distinct(s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

print "--- CONCAT ---"
do
    print("Testing...", "concat 1")
    local s1 = S.from({1, 2, 3})
    local s2 = S.from({4, 5, 6})
    local s_concat = S.concat(s1, s2)
    local t = S.to_table(s_concat)
    assert(#t == 6)
    for i=1, 6 do
        assert(t[i] == i)
    end

    print("Testing...", "concat 2")
    local s1 = S.from({})
    local s2 = S.from({1, 2, 3})
    local s_concat = S.concat(s1, s2)
    local t = S.to_table(s_concat)
    assert(#t == 3)
    for i = 1, 3 do
        assert(t[i] == i)
    end
end

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
local s = S.concat(s1,sA)
vs = S.to_table(s)
assert(#vs==3 and vs[1]==1 and vs[2]==2 and vs[3]==3)
]]

-- SINKS

s = S.fr_range(1, 5)
local sum = S.to_sum(s)
assert(sum == 15)
assert(s() == nil)

s = S.fr_range(1, 5)
local mul = S.to_mul(s)
assert(mul == 120)

s = S.fr_range(1, 5)
local min = S.to_min(s)
assert(min == 1)
assert(s() == nil)

s = S.fr_range(1, 5)
local max = S.to_max(s)
assert(max == 5)

s = S.fr_range(1, 5)
local reduced = S.to_acc(s, 0, function(a, b) return a + b end)
assert(reduced == 15)

s = S.fr_range(1, 5)
S.to_each(s, function(x) assert(x >= 1 and x <= 5) end)
assert(s() == nil)

s = S.from(10)
assert(S.to_first(s) == 10)
