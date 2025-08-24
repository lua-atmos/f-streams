local S = require("streams")

-- SOURCES

local s = S.fr_const(42)
assert(s() == 42)
assert(s() == 42)
assert(s() == 42)

local s = S.fr_range(1, 5)
local values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

s = S.fr_table({1, 2, 3, 4, 5})
values = S.to_table(s)
assert(#values == 5 and values[1] == 1 and values[5] == 5)

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

-- COMBINATORS

s = S.fr_range(1, 5)
s = S.map(s, function(x) return x * 2 end)
values = S.to_table(s)
assert(#values == 5 and values[1] == 2 and values[5] == 10)
assert(s() == nil)

s = S.fr_range(1, 5)
s = S.filter(s, function(x) return x % 2 == 0 end)
values = S.to_table(s)
assert(#values == 2 and values[1] == 2 and values[2] == 4)

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
local reduced = S.to_acc(s, function(a, b) return a + b end)
assert(reduced == 15)

s = S.fr_range(1, 5)
S.to_each(s, function(x) assert(x >= 1 and x <= 5) end)
assert(s() == nil)
