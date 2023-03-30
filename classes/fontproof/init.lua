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

-- useful functions
local function fontsource (fam, file)
  local family, filename
  if file then
    family = nil
    filename = file
  elseif fam then
    family = fam
    filename = nil
  elseif _scratch.testfont.filename then
    filename = _scratch.testfont.filename
    family = nil
  else
    family = _scratch.testfont.family
    filename = nil
  end
  return family, filename
end

local function sizesplit (str)
  local sizes = {}
  for s in string.gmatch(str, "%w+") do
    if not string.find(s, "%a") then s = s .. "pt" end
    table.insert(sizes, s)
  end
  return sizes
end

local function processtext (str)
  local newstr = str
  local temp = str[1]
  if string.sub(temp, 1, 5) == "text_" then
    local textname = string.sub(temp, 6)
    if _scratch.texts[textname] ~= nil then
      newstr[1] = _scratch.texts[textname].text
    end
  end
  return newstr
end

function class:_init (options)

  _scratch = {
    runhead = {},
    section = {},
    subsection = {},
    testfont = {},
    groups = {}
  }

  -- luacheck: ignore _fpFilename _fpFamily _fpSize _fpFeatures
  _scratch.testfont.filename = (options.filename and options.filename) or (_fpFilename and _fpFilename) or nil
  _scratch.testfont.family = (options.family and options.family) or (_fpFamily and _fpFamily) or "Gentium Plus"
  _scratch.testfont.size = (options.size and options.size) or (_fpSize and _fpSize) or "8pt"
  _scratch.testfont.features = (options.features and options.features) or (_fpFeatures and _fpFeatures) or nil
  SILE.call("font", _scratch.testfont)

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
  _scratch.texts = require("packages.fontproof.texts")
  _scratch.groups = require("packages.fontproof.groups")
  -- self:loadPackage("fontproof.gutenberg-client")

  SILE.settings:set("document.parindent", SILE.nodefactory.glue(0))
  SILE.settings:set("document.spaceskip")
  return self

end

function class:endPage ()
  SILE.call("nofolios")
  local fontinfo
  if _scratch.testfont.filename then
    fontinfo = ("Font file: %s %s"):format(_scratch.testfont.filename, _scratch.testfont.features)
  else
    fontinfo = ("Font family: %s %s"):format(_scratch.testfont.family, _scratch.testfont.features)
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
    _scratch.testfont = pl.tablex.merge(options, _scratch.testfont, true)
    SILE.call("font", _scratch.testfont)
  end)

  -- optional way to override defaults
  self:registerCommand("setRunHeadStyle", function (options, _)
    _scratch.runhead.family = options.family
    _scratch.runhead.size = options.size or "8pt"
  end)

  -- basic text styles
  self:registerCommand("basic", function (_, content)
    SILE.settings:temporarily(function()
      SILE.call("font", {
          filename = _scratch.testfont.filename,
          size = _scratch.testfont.size
        }, function () SILE.call("raggedright", {}, content) end)
    end)
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

  -- special tests
  self:registerCommand("proof", function (options, content)
    local proof = {}
    local procontent = processtext(content)
    if options.type ~= "pattern" then
      if options.heading then
        SILE.call("subsection", {}, { options.heading })
      else
        SILE.call("bigskip")
      end
    end
    if options.size then
      proof.sizes = sizesplit(options.size)
    else proof.sizes = { _scratch.testfont.size }
    end
    if options.shapers then
      if SILE.settings.declarations["harfbuzz.subshapers"] then
        SILE.settings:set("harfbuzz.subshapers", options.shapers)
      else SU.warn("Can't use shapers on this version of SILE; upgrade!")
      end
    end
    proof.family, proof.filename = fontsource(options.family, options.filename)
    SILE.call("color", options, function ()
      for i = 1, #proof.sizes do
        SILE.settings:temporarily(function ()
          local fontoptions = {
            family = proof.family,
            filename = proof.filename,
            size = proof.sizes[i]
          }
          -- Pass on some options from \proof to \font.
          local tocopy = { "language"; "direction"; "script" }
          for j = 1, #tocopy do
            if options[tocopy[j]] then fontoptions[tocopy[j]] = options[tocopy[j]] end
          end
          -- Add feature options
          if options.featuresraw then fontoptions.features = options.featuresraw end
          if options.features then
            for j in SU.gtoke(options.features, ",") do
              if j.string then
                local feat = {}
                local _, _, k, v = j.string:find("(%w+)=(.*)")
                feat[k] = v
                SILE.call("add-font-feature", feat, {})
              end
            end
          end
          SILE.call("font", fontoptions, {})
          SILE.call("raggedright", {}, procontent)
        end)
      end
    end)
  end)

  self:registerCommand("pattern", function(options, content)
    --SU.required(options, "reps")
    local chars = pl.stringx.split(options.chars, ",")
    local reps = pl.stringx.split(options.reps, ",")
    local format = options.format or "table"
    local size = options.size or _scratch.testfont.size
    local cont = processtext(content)[1]
    local paras = {}
    if options.heading then SILE.call("subsection", {}, { options.heading })
    else SILE.call("bigskip")
    end
    for i, _ in ipairs(chars) do
      local char, group = chars[i], reps[i]
      local gitems
      if string.sub(group, 1, 6) == "group_" then
        local groupname = string.sub(group, 7)
        gitems = SU.splitUtf8(_scratch.groups[groupname])
      else
        gitems = SU.splitUtf8(group)
      end
      local newcont = ""
      for r = 1, #gitems do
        if gitems[r] == "%" then gitems[r] = "%%" end
        local newstr = string.gsub(cont, char, gitems[r])
        newcont = newcont .. char .. newstr
      end
      cont = newcont
    end
    if format == "table" then
      if chars[2] then
        paras = pl.stringx.split(cont, chars[2])
      else
        table.insert(paras, cont)
      end
    elseif format == "list" then
      for _, c in ipairs(chars) do
        cont = string.gsub(cont, c, chars[1])
      end
      paras = pl.stringx.split(cont, chars[1])
    else
      table.insert(paras, cont)
    end
    for _, para in ipairs(paras) do
      for _, c in ipairs(chars) do
        para = string.gsub(para, c, " ")
      end
      SILE.call("proof", { size = size, type = "pattern" }, { para })
    end
  end)

  self:registerCommand("patterngroup", function(options, content)
    SU.required(options, "name")
    local group = content[1]
    _scratch.groups[options.name] = group
  end)

end

return class
