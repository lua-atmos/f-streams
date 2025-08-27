local S = require("streams")

local s = S.fr_const(42)
local mapped = S.map(function(x) return x * 2 end, s)
assert(mapped() == 84)
assert(mapped() == 84)
assert(mapped() == 84)

local s = S.from(1, 10)
s = S.filter(function(x) return x % 2 == 0 end, s)
s = S.map(function(x) return x * 2 end, s)
local values = S.to_table(s)
assert(#values == 5 and values[1] == 4 and values[5] == 20)

s = S.fr_range(1, 10)
s = S.take(5, s)
s = S.map(function(x) return x * 2 end, s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 2 and values[5] == 10)

s = S.fr_range(1, 10)
s = S.skip(5, s)
s = S.filter(function(x) return x % 2 == 0 end, s)
values = S.to_table(s)
assert(#values == 3 and values[1] == 6 and values[3] == 10)

s = S.fr_range(1, 10)
s = S.map(function(x) return x * 2 end, s)
s = S.take(5, s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 2 and values[5] == 10)

s = S.fr_range(1, 10)
s = S.distinct(s)
s = S.map(function(x) return x * 2 end, s)
values = S.to_table(s)
assert(#values == 10 and values[1] == 2 and values[10] == 20)

s = S.fr_range(1, 10)
s = S.map(function(x) return x * 2 end, s)
s = S.filter(function(x) return x % 4 == 0 end, s)
values = S.to_table(s)
assert(#values == 5 and values[1] == 4 and values[5] == 20)

local s = S.fr_range(1, 3)
s = S.map(function(x) return S.fr_range(x, x + 1) end, s)
s = S.flatten(s)
local values = S.to_table(s)
assert(#values == 6 and values[1] == 1 and values[2] == 2 and values[3] == 2 and values[4] == 3 and values[5] == 3 and values[6] == 4)

local s = setmetatable({}, {
    __call = function()
        return 5
    end
})
s = S.take(2, S.map(function(x) return x * 2 end, s))
assert(s() == 10)
assert(s() == 10)
assert(s() == nil)
assert(s() == nil)
