local D = require("pl.pretty").dump

local cliargs = require("cliargs")
-- local lfs = require("lfs")
local path = require("pl.path")
local stringx = require("pl.stringx")

local bin = arg[0]
local sile = "sile"

cliargs:set_name("fontproof")
cliargs:set_description([[
    FontProof enables you to produce PDF font test documents without fiddling with InDesign or other manual page layout
    or word processing programs. You can apply one of the predesigned test documents or use FontProof to build your own
    custom font test document.
   ]])
cliargs:option("-f, --filename=VALUE", "Specify the font to be tested as a path to a font file")
cliargs:option("-F, --family=VALUE", "Specify the font to be tested as a family name")
cliargs:option("-t, --template=VALUE", "Use the bundled template by name (full, gutenberg, test, unichar);")
cliargs:flag("-h, --help", "display this help, then exit")
cliargs:splat("SILEARGS", "All remaining args are passed directly to SILE")

local opts, parse_err = cliargs:parse(_G.arg)
if not opts and parse_err then
   print(parse_err)
   os.exit(1)
end

local templatefile

if opts.template then
   -- local cwd = lfs.currentdir()
   -- local templatesdir = path.abspath(path.dirname(bin) .. "/../templates")

   -- local pp = stringx.split(package.path, "?")[1] .. "templates"
   -- error("tt")
   -- local templatefile = ("%s/%s.sil"):format(templatesdir, opts.template)
   -- D(templatefile)
   -- opts.template = path.exists(templatefile) and templatefile or error("Unknown template")
   if not path.exists(opts.template) then
      opts.template = ("-e _fpTemplate='%s'"):format(opts.template)
   end
end

local filename = opts.filename and ("-e _pfFilename='%s'"):format(opts.filename) or ""
local family = opts.family and ("-e _pfFamily='%s'"):format(opts.family) or ""

-- if opts.font then
--    D(opts.font)
--    local attrs = lfs.attributes(opts.font, "mode")
--    error("STOPME")
-- end

local _, status, signal = os.execute(("echo %s %s %s %s %s"):format(sile, filename, family, opts.template, opts.SILEARGS or ""))

if status == "exit" then
   os.exit(signal)
else
   error(("Interupted with signal %s"):format(signal))
   os.exit(1)
end
