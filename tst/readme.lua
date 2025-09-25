local S = require "streams"

-------------------------------------------------------------------------------

-- without `:` notation
cnt = S.fr_counter()        -- 1, 2, 3, 4, 5, ...
vs3 = S.take(cnt, 3)        -- 1, 2, 3
tab = S.table(vs3)          -- {1}, {1,2}, {1, 2, 3}
ret = S.to(tab)             -- {1, 2, 3}
for i,v in ipairs(ret) do
    print(i,v)              -- 1,1 / 2,2 / 3,3
end

-------------------------------------------------------------------------------

js = S.from { "Joao", "Jose", "Maria" }
        :filter(function(n) return n:find("^J") end)
for n in js do
    print(n)    -- Joao / Jose
end

-------------------------------------------------------------------------------

S.from(1, 10):tap(print):to()
