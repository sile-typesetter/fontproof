-- Copyright (C) 2016-2023 SIL International
-- SPDX-License-Identifier: MIT

local cliargs = require("cliargs")

local print_version = function()
   os.execute("sile --version")
   local _, loader = pcall(require, "luarocks.loader")
   print("FontProof installed from rockspec " .. loader.context.fontproof)
   os.exit(0)
end

cliargs:set_name("fontproof")
cliargs:set_description([[
    FontProof enables you to produce PDF font test documents without fiddling with InDesign or other manual page layout
    or word processing programs. You can apply one of the predesigned test documents or use FontProof to build your own
    custom font test document.
   ]])
cliargs:option("-f, --filename=VALUE", "Specify the font to be tested as a path to a font file")
cliargs:option("-F, --family=VALUE", "Specify the font to be tested as a family name")
cliargs:option("-o, --output=FILE", "output file name")
cliargs:option("-s, --size=VALUE", "Specify the default test font size")
cliargs:option("-t, --template=VALUE", "Use the bundled template by name (full, gutenberg, test, unichar);")
cliargs:flag("-h, --help", "display this help, then exit")
cliargs:flag("-v, --version", "display version information, then exit", print_version)
cliargs:splat("SILEARGS", "All remaining args are passed directly to SILE")

local opts, parse_err = cliargs:parse(_G.arg)
if not opts and parse_err then
   print(parse_err)
   os.exit(1)
end

local filename = opts.filename and ("-e '_fpFilename=\"%s\"'"):format(opts.filename) or ""
local size = opts.size and ("-e '_fpSize=\"%s\"'"):format(opts.size) or ""
local template = opts.template and ("templates/%s.sil"):format(opts.template) or ""
local family = opts.family and ("-e '_fpFamily=\"%s\"'"):format(opts.family) or ""
local output = ("-o %s"):format(opts.output or "fontproof.pdf")
local args = opts.SILEARGS and opts.SILEARGS or ""

local _, status, signal =
   os.execute(table.concat({"sile", filename, family, size, template, output, args}, " "))

if status == "exit" then
   os.exit(signal)
else
   error(("Interupted with signal %s"):format(signal))
   os.exit(1)
end
