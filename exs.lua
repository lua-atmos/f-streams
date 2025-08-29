local S = require "streams"

local s = S.from(1,3)
print(s())  -- 1
print(s())  -- 2
print(s())  -- 3
print(s())  -- nil

print()
print "------"
print()

local S = require "streams"
S.from(1)                                       -- 1, 2, 3, ...
    :filter(function (x) return x%2 == 1 end)   -- 1, 3, 5, ...
    :map(function (x) return x * 2 end)         -- 2, 6, 10, ...
    :take(3)                                    -- 2, 6, 10
    :to_each(function (v)
        print(v)                                -- 2 / 6 / 10
    end)

print()
print "------"
print()

local cnt = S.fr_counter()      -- 1, 2, 3, 4, 5, ...
local vs3 = S.take(cnt, 3)      -- 1, 2, 3
local vec = S.to_table(vs3)     -- {1, 2, 3}
for i,v in ipairs(vec) do
    print(i,v)                  -- 1,1 / 2,2 / 3,3
end

local ns = S.fr_table { "Joao", "Jose", "Maria" }
local js = S.filter(ns, function(n) return n:find("^J") end)
for n in js do
    print(n)        -- Joao / Jose
end

local vs = S.fr_range(1, 10)
S.to_each(vs, print)
