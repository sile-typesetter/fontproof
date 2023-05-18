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
  "_fpFamily",
  "_fpFeatures",
  "_fpFilename",
  "_fpLanguage",
  "_fpScript",
  "_fpSize",
  "_fpStyle",
  "_fpWeight"
}
max_line_length = false
-- vim: ft=lua
