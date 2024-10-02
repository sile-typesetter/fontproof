std = "min+sile"
include_files = {
   "**/*.lua",
   "*.rockspec",
   ".luacheckrc",
}
exclude_files = {
   "lua_modules",
   ".lua",
   ".luarocks",
   ".install",
}
globals = {
   "_fpFamily",
   "_fpFeatures",
   "_fpFilename",
   "_fpLanguage",
   "_fpScript",
   "_fpSize",
   "_fpStyle",
   "_fpWeight",
}
max_line_length = false
-- vim: ft=lua
