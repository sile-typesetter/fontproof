-- Copyright (C) 2016-2023 SIL International
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
    bottom = "96%ph"
  },
  runningHead = {
    left = "left(content)",
    right = "right(content)",
    top = "top(content)-3%ph",
    bottom = "top(content)-1%ph"
  }
}

function class:_init (options)

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

  SILE.settings:set("document.parindent", SILE.nodefactory.glue(0))
  SILE.settings:set("document.spaceskip")
  return self

end

function class:declareOptions ()
  plain.declareOptions(self)
  local filename, family, size, style, features, weight
  self:declareOption("filename", function (_, value)
    if value then filename = value end
    return filename
  end)
  self:declareOption("family", function (_, value)
    if value then family = value end
    return family
  end)
  self:declareOption("size", function (_, value)
    if value then size = value end
    return size
  end)
  self:declareOption("style", function (_, value)
    if value then style = value end
    return style
  end)
  self:declareOption("features", function (_, value)
    if value then features = value end
    return features
  end)
  self:declareOption("weight", function (_, value)
    if value then weight = value end
    return weight
  end)
end

function class:setOptions (options)
  plain.setOptions(self, options)
  -- luacheck: ignore _fpFilename _fpFamily _fpSize _fpStyle _fpFeatures _fpWeight
  self.options.filename = _fpFilename or options.filename or nil
  self.options.family = _fpFamily or options.family or "Gentium Plus"
  self.options.size = _fpSize or options.size or "12pt"
  self.options.style = _fpStyle or options.style or nil
  self.options.features = _fpFeatures or options.features or ""
  self.options.weight = _fpWeight or options.weight or nil
end

function class:endPage ()
  SILE.call("nofolios")
  local fontinfo
  if self.options.filename then
    fontinfo = ("Font file: %s %s"):format(self.options.filename, self.options.features)
  else
    fontinfo = ("Font family: %s %s %s %s"):format(self.options.family, self.options.style, self.options.weight, self.options.features)
  end
  local templateinfo = ("Template file: %s.sil"):format(SILE.masterFilename)
  local dateinfo = os.date("%A %d %b %Y %X %z %Z")
  local sileinfo = ("SILE %s"):format(SILE.version)
  local harfbuzzinfo = ("HarfBuzz %s"):format(hb.version())
  local runheadinfo = ("Fontproof for: %s - %s - %s - %s - %s"):format(fontinfo, templateinfo, dateinfo, sileinfo, harfbuzzinfo)
  SILE.typesetNaturally(SILE.getFrame("runningHead"), function()
    SILE.settings:set("document.rskip", SILE.nodefactory.hfillglue())
    SILE.settings:set("typesetter.parfillskip", SILE.nodefactory.glue(0))
    SILE.settings:set("document.spaceskip", SILE.shaper:measureChar(" ").width)
    SILE.call("font", {
        family = _scratch.runhead.family,
        size = _scratch.runhead.size
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
        size = _scratch.section.size
      }, function () SILE.call("raggedright", {}, content) end)
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
        size = _scratch.subsection.size
      }, function () SILE.call("raggedright", {}, content) end)
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
  opts.size = options.size or self.options.size
  opts.features = options.features or self.options.features
  return opts
end

return class
