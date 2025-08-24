local S = require("streams")

local s = S.fr_const(42)
local mapped = S.map(s, function(x) return x * 2 end)
assert(mapped() == 84)
assert(mapped() == 84)
assert(mapped() == 84)

local s = S.fr_range(1, 10)
s = S.filter(s, function(x) return x % 2 == 0 end)
s = S.map(s, function(x) return x * 2 end)
local values = S.to_table(s)
assert(#values == 5 and values[1] == 4 and values[5] == 20)

s = S.fr_range(1, 10)
s = S.take(s, 5)
s = S.map(s, function(x) return x * 2 end)
values = S.to_table(s)
assert(#values == 5 and values[1] == 2 and values[5] == 10)

s = S.fr_range(1, 10)
s = S.skip(s, 5)
s = S.filter(s, function(x) return x % 2 == 0 end)
values = S.to_table(s)
assert(#values == 3 and values[1] == 6 and values[3] == 10)

s = S.fr_range(1, 10)
s = S.map(s, function(x) return x * 2 end)
s = S.take(s, 5)
values = S.to_table(s)
assert(#values == 5 and values[1] == 2 and values[5] == 10)

s = S.fr_range(1, 10)
s = S.distinct(s)
s = S.map(s, function(x) return x * 2 end)
values = S.to_table(s)
assert(#values == 10 and values[1] == 2 and values[10] == 20)

s = S.fr_range(1, 10)
s = S.map(s, function(x) return x * 2 end)
s = S.filter(s, function(x) return x % 4 == 0 end)
values = S.to_table(s)
assert(#values == 5 and values[1] == 4 and values[5] == 20)

local s = S.fr_range(1, 3)
s = S.map(s, function(x) return S.fr_range(x, x + 1) end)
s = S.flatten(s)
local values = S.to_table(s)
assert(#values == 6 and values[1] == 1 and values[2] == 2 and values[3] == 2 and values[4] == 3 and values[5] == 3 and values[6] == 4)

local s = setmetatable({}, {
    __call = function()
        return 5
    end
})
s = S.take(S.map(s, function(x) return x * 2 end), 2)
assert(s() == 10)
assert(s() == 10)
assert(s() == nil)
assert(s() == nil)
