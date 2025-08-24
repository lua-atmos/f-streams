local S = require "streams"

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
