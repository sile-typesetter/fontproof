-- Copyright (C) 2016-2023 SIL International
-- SPDX-License-Identifier: MIT

local cliargs = require("cliargs")

local print_version = function ()
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
cliargs:option("-F, --family=VALUE", "Specify the font to be tested as a family name (ignored if --filename used)")
cliargs:option("-f, --filename=VALUE", "Specify the font to be tested as a path to a font file")
cliargs:option("-o, --output=FILE", "output file name")
cliargs:option("-p, --features=VALUE", "Specify the test font features")
cliargs:option("-s, --size=VALUE", "Specify the test font size")
cliargs:option("-S, --style=VALUE", "Specify the test font style (ignored if --filename used)")
cliargs:option("-t, --template=VALUE", "Use the bundled template by name (full, gutenberg, test, unichar);")
cliargs:option("-w, --weight=VALUE", "Specify the test font weight (ignored if --filename used)")
cliargs:flag("-h, --help", "display this help, then exit")
cliargs:flag("-v, --version", "display version information, then exit", print_version)
cliargs:splat("SILEARGS", "All remaining args are passed directly to SILE", nil, 999)

local opts, parse_err = cliargs:parse(_G.arg)

if not opts and parse_err then
   print(parse_err)
   local code = parse_err:match("^Usage:") and 0 or 1
   os.exit(code)
end

local family = opts.family and ("-e '_fpFamily=\"%s\"'"):format(opts.family) or ""
local features = opts.features and ("-e '_fpFeatures=\"%s\"'"):format(opts.features) or ""
local filename = opts.filename and ("-e '_fpFilename=\"%s\"'"):format(opts.filename) or ""
local output = ("-o %s"):format(opts.output or "fontproof.pdf")
local size = opts.size and ("-e '_fpSize=\"%s\"'"):format(opts.size) or ""
local style = opts.style and ("-e '_fpStyle=\"%s\"'"):format(opts.style) or ""
local template = opts.template and ("templates/%s.sil"):format(opts.template) or ""
local weight = opts.weight and ("-e '_fpWeight=\"%s\"'"):format(opts.weight) or ""
local args = opts.SILEARGS and table.concat(opts.SILEARGS, " ") or ""

local _, status, signal =
   os.execute(table.concat({"sile", filename, family, style, weight, size, features, output, args, template}, " "))

if status == "exit" then
   os.exit(signal)
else
   error(("Interrupted with signal %s"):format(signal))
   os.exit(1)
end
