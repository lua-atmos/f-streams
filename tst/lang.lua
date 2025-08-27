local S = require("streams")
S.language()

print("Testing...", "test 01: range, map, table")
vs = S.fr_range(1, 5)
    | S.map ^ (function(x) return x * 2 end)
    | S.to_table
assert(#vs == 5 and vs[1] == 2 and vs[5] == 10)

print("Testing...", "test 02")
vs = {}
_ = S.from(1)                                      -- 1, 2, 3, ...
    | S.filter ^ (function(x) return x%2 == 1 end) -- 1, 3, 5, ...
    | S.map ^ (function(x) return x * 2 end)       -- 2, 6, 10, ...
    | S.take ^ 3                                   -- 2, 6, 10
    | S.to_each ^ (function (v)
        vs[#vs+1] = v                              -- 2 / 6 / 10
    end)
assert(#vs==3 and vs[1]==2 and vs[3]==10)

print("Testing...", "test 03: filter map")
local s = S.from(1, 10)
s = S.filter(function(x) return x % 2 == 0 end, s)
s = s * (function(x) return x * 2 end)
local values = S.to_table(s)
assert(#values == 5 and values[1] == 4 and values[5] == 20)

print("Testing...", "test 04: map concat")
local s1 = S.from({1, 2, 3})
local s2 = S.from({4, 5, 6})
local s1_mapped = {1,2,3} * (function(x) return x * 2 end)
local s2_mapped = s2 * (function(x) return x*2 + 1 end)
local s_concat = s1_mapped .. s2_mapped
local t = S.to_table(s_concat)
assert(#t == 6)
for i = 1, 3 do
    assert(t[i] == i*2)
end
for i = 4, 6 do
    assert(t[i] == i*2 + 1)
end


