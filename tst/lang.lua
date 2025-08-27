local S = require("streams")
S.language()

vs = S.fr_range(1, 5)
    >> S.map ^ (function(x) return x * 2 end)
    >> S.to_table
assert(#vs == 5 and vs[1] == 2 and vs[5] == 10)

_ = S.from(1)                                       -- 1, 2, 3, ...
    >> S.filter ^ (function(x) return x%2 == 1 end) -- 1, 3, 5, ...
    >> S.map ^ (function(x) return x * 2 end)       -- 2, 6, 10, ...
    >> S.take ^ 3                                   -- 2, 6, 10
    >> S.to_each ^ (function (v)
        print(v)                                    -- 2 / 6 / 10
    end)
