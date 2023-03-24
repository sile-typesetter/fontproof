-- DO NOT EDIT! Modify template fontproof.rockspec.in and rebuild with `make fontproof-dev-1.rockspec`
rockspec_format = "3.0"
package = "fontproof"
version = "dev-1"

source = {
   url = "git+https://github.com/sile-typesetter/fontproof.git",
   tag = "master"
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
   "lua >= 5.1"
}

build = {
   type = "builtin",
   modules = {
      fontproof = "src/fontproof.lua",
      ["sile.classes.fontproof"] = "classes/fontproof/init.lua",
      ["sile.packages.fontproofgroups"] = "packages/fontproofgroups.lua",
      ["sile.packages.fontprooftexts"] = "packages/fontprooftexts.lua",
      ["sile.packages.gutenberg-client"] = "packages/gutenberg-client.lua"
   },
   install = {
     lua = {
       -- ["fontproof.fpFull"] = "fpFull.sil",
       -- ["fontproof.fpGutenberg"] = "fpGutenberg.sil",
       -- ["fontproof.fpTest"] = "fpTest.sil",
       -- ["fontproof.fpUnichar"] = "fpUnichar.sil"
     },
     bin = {
       fontproof = "fontproof"
     }
   }
}