std = "max"
include_files = {
  "**/*.lua",
  "*.rockspec",
  ".luacheckrc"
}
exclude_files = {
  "lua_modules",
  ".lua",
  ".luarocks",
  ".install"
}
globals = {
  "SILE",
  "SU",
  "luautf8",
  "pl",
  "fluent",
  "_fpFilename",
  "_fpFamily",
  "_fpSize"
}
max_line_length = false
-- vim: ft=lua
