package = "f-streams"
version = "0.1-2"
source = {
   url = "git+https://github.com/lua-atmos/f-streams",
   branch = "v0.1",
}
description = {
   summary = [[
    `f-streams` is a pull-based streams library for Lua.
   ]],
   detailed = [[
    `f-streams` is a pull-based streams library for Lua:

    - A stream is a function or any other value with a `__call` metamethod.
    - A stream produces a new value each time is called.
    - A stream terminates when it returns `nil`.
    - A stream can be combined with other streams or values to create new streams.
    - A stream can be iterated over using Lua's generic [for][lua-for] loop.
    - A stream can represent infinite lazy lists.

    The example that follows prints the first three odd numbers multiplied by `2`:

    ```
    local S = require "streams"
    S.methods(true)                                 -- enables `:` notation
    S.from(1)                                       -- 1, 2, 3, ...
        :filter(function(x) return x%2 == 1 end)    -- 1, 3, 5, ...
        :map(function(x) return x * 2 end)          -- 2, 6, 10, ...
        :take(3)                                    -- 2, 6, 10
        :to_each(function (v)
            print(v)                                -- 2 / 6 / 10
        end)
    ```
   ]],
   homepage = "https://github.com/lua-atmos/f-streams",
   license = "MIT",
}
build = {
   type = "builtin",
   modules = {
      ["streams"] = "streams/init.lua",
   },
}
