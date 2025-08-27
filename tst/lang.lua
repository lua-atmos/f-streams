local S = require("streams")
S.methods(true)

print("Testing...", "test 01: range, map, table")
vs = S.fr_range(1, 5)
        :map(function(x) return x * 2 end)
        :to_table()
assert(#vs == 5 and vs[1] == 2 and vs[5] == 10)

print("Testing...", "test 02")
vs = {}
S.from(1)                                       -- 1, 2, 3, ...
    :filter(function(x) return x%2 == 1 end)    -- 1, 3, 5, ...
    :map(function(x) return x * 2 end)          -- 2, 6, 10, ...
    :take(3)                                    -- 2, 6, 10
    :to_each(function (v)
        vs[#vs+1] = v                           -- 2 / 6 / 10
    end)
assert(#vs==3 and vs[1]==2 and vs[3]==10)

print("Testing...", "test 03: filter map")
local s = S.from(1, 10):filter(function(x) return x % 2 == 0 end)
s = s:map(function(x) return x * 2 end)
local values = s:to_table()
assert(#values == 5 and values[1] == 4 and values[5] == 20)

print("Testing...", "test 04: map concat")
local s1 = S.from({1, 2, 3})
local s2 = S.from({4, 5, 6})
local s1_mapped = S.from{1,2,3}:map(function(x) return x * 2 end)
local s2_mapped = s2:map(function(x) return x*2 + 1 end)
local s_concat = s1_mapped:concat(s2_mapped)
local t = S.to_table(s_concat)
assert(#t == 6)
for i = 1, 3 do
    assert(t[i] == i*2)
end
for i = 4, 6 do
    assert(t[i] == i*2 + 1)
end


