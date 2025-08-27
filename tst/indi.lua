local S = require("streams")

print "--- SOURCES ---"

print("Testing...", "const 1")
local s = S.fr_const(42)
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

s = S.fr_range(1, 5)
s = S.map(function(x) return x * 2 end, s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 2 and values[5] == 10)
assert(s() == nil)

s = S.fr_range(1, 5)
s = S.filter(function(x) return x % 2 == 0 end, s)
values = S.to_table(s)
assert(#values == 2 and values[1] == 2 and values[2] == 4)

s = S.fr_range(1, 10)
s = S.take(5, s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

s = S.fr_range(1, 10)
s = S.skip(5, s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 6 and values[5] == 10)
assert(s() == nil)

s = S.fr_range(1, 5)
s = S.distinct(s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

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
local reduced = S.to_acc(function(a, b) return a + b end, 0, s)
assert(reduced == 15)

s = S.fr_range(1, 5)
S.to_each(function(x) assert(x >= 1 and x <= 5) end, s)
assert(s() == nil)
