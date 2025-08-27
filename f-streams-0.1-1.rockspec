package = "f-streams"
version = "0.1-1"
source = {
   url = "git+https://github.com/lua-atmos/f-streams",
   branch = "v0.1",
}
description = {
   summary = [[
    `f-streams` is a pull-based streams library for Lua.
   ]],
   detailed = [[
   ]],
   homepage = "https://github.com/lua-atmos/f-streams",
   license = "MIT",
}
dependencies = {
   "lua ~> 5.3",
}
build = {
   type = "builtin",
   modules = {
      ["streams"] = "streams/init.lua",
   },
}
