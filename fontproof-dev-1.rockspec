-- DO NOT EDIT! Modify template fontproof.rockspec.in and rebuild with `make fontproof-dev-1.rockspec`
rockspec_format = "3.0"
package = "fontproof"
version = "dev-1"

source = {
   url = "git+https://github.com/sile-typesetter/fontproof.git",
   branch = "master"
}

description = {
   summary = "A font design testing class for SILE",
   detailed = [[FontProof enables you to produce PDF font test documents without
     fiddling with InDesign or other manual page layout or word
     processing programs. You can apply one of the predesigned test
     documents (to be added later) or use FontProof to build your own
     custom font test document.]],
   license = "MIT",
   homepage = "https://github.com/sile-typesetter/fontproof",
   issues_url = "https://github.com/sile-typesetter/fontproof/issues",
   maintainer = "Caleb Maclennan <caleb@alerque.com>",
   labels = { "typesetting", "fonts" }
}

dependencies = {
   "lua >= 5.1",
   "lua_cliargs == 3.0-2"
}

build = {
   type = "builtin",
   modules = {
      ["sile.classes.fontproof"] = "classes/fontproof/init.lua",
      ["sile.packages.fontproof"] = "packages/fontproof/init.lua",
      ["sile.packages.fontproof.groups"] = "packages/fontproof/groups.lua",
      ["sile.packages.fontproof.gutenberg"] = "packages/fontproof/gutenberg.lua",
      ["sile.packages.fontproof.texts"] = "packages/fontproof/texts.lua"
   },
   install = {
     lua = {
       ["sile.packages.fontproof.templates.full"] = "templates/full.sil",
       ["sile.packages.fontproof.templates.gutenberg"] = "templates/gutenberg.sil",
       ["sile.packages.fontproof.templates.test"] = "templates/test.sil",
       ["sile.packages.fontproof.templates.unichar"] = "templates/unichar.sil"
     },
     bin = {
       fontproof = "src/fontproof.lua"
     }
   }
}
