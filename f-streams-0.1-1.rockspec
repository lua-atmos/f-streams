package = "f-streams"
version = "0.1-1"
source = {
   url = "git+https://github.com/lua-atmos/f-streams",
   branch = "v0.1",
}
description = {
   summary = [[
    Yet another streams library for Lua.
   ]],
   detailed = [[
    `f-streams` is yet another streams library for Lua.

    A stream is simply a function or any other value with a `__call` metamethod.

    A stream produces a new value each time is called.
    When a stream returns `nil`, it indicates its termination.
    Then, all subsequent calls to the stream must also return `nil`.

    Streams can be combined with other streams or values to create new streams.

    `TODO: finalization`

    Streams are compatible with the generic `for` loop of Lua, including
    proper finalization when the loop ends.
   ]],
   homepage = "https://github.com/lua-atmos/f-streams",
   license = "MIT",
}
dependencies = {
   "lua ~> 5.4",
}
build = {
   type = "builtin",
   modules = {
      ["streams"] = "streams/init.lua",
   },
}
