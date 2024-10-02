-- SPDX-FileCopyrightText: © 2016 SIL International
-- SPDX-License-Identifier: MIT

local hb = require("justenoughharfbuzz")
local plain = require("classes.plain")

local class = pl.class(plain)
class._name = "fontproof"

local _scratch = SILE.scratch.fontproof

class.defaultFrameset = {
   content = {
      left = "8%pw",
      right = "92%pw",
      top = "6%ph",
      bottom = "96%ph",
   },
   runningHead = {
      left = "left(content)",
      right = "right(content)",
      top = "top(content)-3%ph",
      bottom = "top(content)-1%ph",
   },
}

-- If we are in a git repository, report the latest commit ID
local function getGitCommit ()
   local fh = io.popen("git describe --always --long --tags --abbrev=7 --dirty='*'")
   local commit = fh:read()
   return commit and (" [%s]"):format(commit) or ""
end

function class:_init (options)

   -- Dodge deprecation notices until we drop v0.14 support
   if SILE.types then
      SILE.nodefactory = SILE.types.node
   end

   _scratch = {
      runhead = {},
      section = {},
      subsection = {},
   }

   _scratch.runhead.family = "Gentium Plus"
   _scratch.runhead.size = "5pt"
   _scratch.section.family = "Gentium Plus"
   _scratch.section.size = "12pt"
   _scratch.subsection.family = "Gentium Plus"
   _scratch.subsection.size = "12pt"

   plain._init(self, options)

   self:loadPackage("fontproof")
   self:loadPackage("linespacing")
   self:loadPackage("lorem")
   self:loadPackage("specimen")
   self:loadPackage("rebox")
   self:loadPackage("features")
   self:loadPackage("color")

   SILE.settings:set("document.parindent", SILE.types.node.glue(0))
   SILE.settings:set("document.spaceskip")
   return self
end

function class:declareOptions ()
   plain.declareOptions(self)
   local filename, family, language, script, size, style, features, weight
   self:declareOption("filename", function (_, value)
      if value then
         filename = value
      end
      return filename
   end)
   self:declareOption("family", function (_, value)
      if value then
         family = value
      end
      return family
   end)
   self:declareOption("language", function (_, value)
      if value then
         language = value
      end
      return language
   end)
   self:declareOption("script", function (_, value)
      if value then
         script = value
      end
      return script
   end)
   self:declareOption("size", function (_, value)
      if value then
         size = value
      end
      return size
   end)
   self:declareOption("style", function (_, value)
      if value then
         style = value
      end
      return style
   end)
   self:declareOption("features", function (_, value)
      if value then
         features = value
      end
      return features
   end)
   self:declareOption("weight", function (_, value)
      if value then
         weight = value
      end
      return weight
   end)
end

function class:setOptions (options)
   if not self._initialized then
      plain.setOptions(self, options)
   end
   self.options.filename = _fpFilename or options.filename or nil
   self.options.family = _fpFamily or options.family or "Gentium Plus"
   self.options.language = _fpLanguage or options.language or nil
   self.options.script = _fpScript or options.script or nil
   self.options.size = _fpSize or options.size or "12pt"
   self.options.style = _fpStyle or options.style or nil
   self.options.features = _fpFeatures or options.features or ""
   self.options.weight = _fpWeight or options.weight or nil
end

function class:endPage ()
   SILE.call("nofolios")
   local fontinfo
   if self.options.filename then
      fontinfo = ("%s %s"):format(self.options.filename, self.options.features)
   else
      fontinfo = ("%s %s %s %s"):format(
         self.options.family,
         self.options.style,
         self.options.weight,
         self.options.features
      )
   end
   if self.options.language then
      fontinfo = fontinfo .. (" %s"):format(self.options.language)
   end
   if self.options.script then
      fontinfo = fontinfo .. (" %s"):format(self.options.script)
   end
   local gitcommit = getGitCommit()
   local function inputFilename ()
      return SILE.input.filename and SILE.input.filename or SILE.input.filenames[1]
   end
   local templateinfo = ("%s"):format(inputFilename())
   local dateinfo = os.date("%A %d %b %Y %X %z %Z")
   local sileinfo = ("SILE %s"):format(SILE.version)
   local harfbuzzinfo = ("HarfBuzz %s"):format(hb.version())
   local runheadinfo = ("Fontproof: %s %s - %s - %s - %s - %s"):format(
      fontinfo,
      gitcommit,
      templateinfo,
      dateinfo,
      sileinfo,
      harfbuzzinfo
   )
   SILE.typesetNaturally(SILE.getFrame("runningHead"), function ()
      SILE.settings:set("document.rskip", SILE.types.node.hfillglue())
      SILE.settings:set("typesetter.parfillskip", SILE.types.node.glue(0))
      SILE.settings:set("document.spaceskip", SILE.shaper:measureChar(" ").width)
      SILE.call("font", {
         family = _scratch.runhead.family,
         size = _scratch.runhead.size,
      }, { runheadinfo })
      SILE.call("par")
   end)
   return plain.endPage(self)
end

function class:registerCommands ()
   plain.registerCommands(self)

   self:registerCommand("setTestFont", function (options, _)
      self:setOptions(options)
      SILE.call("font", self:_fpOptions())
   end)

   -- optional way to override defaults
   self:registerCommand("setRunHeadStyle", function (options, _)
      _scratch.runhead.family = options.family
      _scratch.runhead.size = options.size or "8pt"
   end)

   self:registerCommand("section", function (_, content)
      SILE.typesetter:leaveHmode()
      SILE.call("goodbreak")
      SILE.call("bigskip")
      SILE.call("noindent")
      SILE.call("font", {
         family = _scratch.section.family,
         size = _scratch.section.size,
      }, function ()
         SILE.call("raggedright", {}, content)
      end)
      SILE.call("novbreak")
      SILE.call("medskip")
      SILE.call("novbreak")
      SILE.typesetter:inhibitLeading()
   end)

   self:registerCommand("subsection", function (_, content)
      SILE.typesetter:leaveHmode()
      SILE.call("goodbreak")
      SILE.call("bigskip")
      SILE.call("noindent")
      SILE.call("font", {
         family = _scratch.subsection.family,
         size = _scratch.subsection.size,
      }, function ()
         SILE.call("raggedright", {}, content)
      end)
      SILE.call("novbreak")
      SILE.call("medskip")
      SILE.call("novbreak")
      SILE.typesetter:inhibitLeading()
   end)
end

function class:_fpOptions (options)
   options = options or {}
   local opts = {}
   if options.filename or self.options.filename then
      opts.filename = options.filename or self.options.filename
   else
      opts.family = options.family or self.options.family
      opts.weight = options.weight or self.options.weight
      opts.style = options.style or self.options.style
   end
   opts.language = options.language or self.options.language
   opts.script = options.script or self.options.script
   opts.size = options.size or self.options.size
   opts.features = options.features or self.options.features
   return opts
end

return class
