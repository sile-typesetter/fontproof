[![Luacheck Lint Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/fontproof/luacheck.yml?branch=master&label=Luacheck&logo=Lua)](https://github.com/sile-typesetter/fontproof/actions?workflow=Luacheck)
[![SILE Render Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/fontproof/sile.yml?branch=master&label=SILE&logo=Github)](https://github.com/sile-typesetter/fontproof/actions?workflow=SILE)
[![Docker Build Status](https://img.shields.io/github/actions/workflow/status/sile-typesetter/fontproof/deploy.yml?branch=master&label=Docker%20Build&logo=Docker)](https://github.com/sile-typesetter/fontproof/pkgs/container/fontproof)

# FontProof

A font design testing class for SILE.

FontProof enables you to produce PDF font test documents without fiddling with InDesign or other manual page layout or word processing programs.
You can apply one of the predesigned test documents (to be added later) or use FontProof to build your own custom font test document.

_Note that FontProof is very much a work-in-progress, so there's a lot that doesn't work yet, or doesn't work very elegantly. Use at your own risk, and help us make it better._

## Installation

FontProof requires [The SILE Typesetter](https://sile-typesetter.org).
You'll need to [install SILE](https://github.com/sile-typesetter/sile/#download-and-installation) according to that package's instructions.

_Note that SILE is changing rapidly. The current class was developed for and tested with release 0.15.0 or newer._
For support of older versions of SILE see older versions of FontProof.

Installation of FontProof is primarily done through Lua Rocks:

``` console
$ luarocks install fontproof
```

A working installation of SILE v0.15.0 or newer is required but not checked at installation time.

You may also install from manually from the source directory:

``` console
$ luarocks make
```
## Usage

Running FontProof is done through its own CLI:

``` console
$ fontproof --help
Usage: fontproof [OPTIONS] [--] [SILEARGS-1 [SILEARGS-2 [...]]]

ARGUMENTS:
  SILEARGS             All remaining args are passed directly to SILE
                       (optional)

OPTIONS:
  -F, --family=VALUE   Specify the font to be tested as a family name
                       (ignored if --filename used)
  -f, --filename=VALUE Specify the font to be tested as a path to a
                       font file
  -o, --output=FILE    output file name
  -p, --features=VALUE Specify the test font features
  -s, --size=VALUE     Specify the test font size
  -S, --style=VALUE    Specify the test font style (ignored if
                       --filename used)
  -t, --template=VALUE Use the bundled template by name (full,
                       gutenberg, test, unichar);
  -w, --weight=VALUE   Specify the test font weight (ignored if
                       --filename used)
  -h, --help           display this help, then exit
  -v, --version        display version information, then exit
```

## Using the templates

Four starter templates are provided out of the box.
To adapt them, the best thing to do is probably copy the one most similar to where you plan to head and modify it yourself.
The main feature of a template is that it uses the *fontproof* class.
Use of the specialty commands it defines is on an as-needed basis.

For example:

``` console
$ cp /usr/local/share/lua/<version>/fontproof/templates/full.sil mytemplate.sil
$ fontproof -- mytemplate.sil
```

At this point there is one main template - _fpFull.sil_ - but more will follow.
That template will show you almost all that FontProof can do.
SILE itself is capable of far, far, more, and you're very welcome to play around with it.

## Docker usage

As an alternative method to use FontProof, Docker images are available from [Docker Hub](https://hub.docker.com/repository/docker/siletypesetter/fontproof) or the [GitHub Container Registry](https://github.com/sile-typesetter/fontproof/pkgs/container/fontproof%2Ffontproof) with SILE and the *fontproof* class baked in and ready for use.
Released versions are tagged to match (e.g. `v2.0.5`), the latest release will be tagged `latest`, and a `master` tag is also available with the freshest development build.
In order to be useful you need to tell the Docker run command a way to reach your source documents (and hence also to give it a place to write the output) as well as tell it who you are on the host machine so the output generated inside the container can be created with the expected ownership properties.
You may find it easiest to run with an alias like this:

```console
$ alias fontproof='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" siletypesetter/fontproof:latest'
$ fontproof proofs.sil
```

## Remote usage

Any remote CI system that can use Docker images as job runners could be configured to run FontProof jobs.
Additionally a ready-made GitHub Action is [available on the marketplace](https://github.com/marketplace/actions/fontproof):

```yaml
name: FontProof
on: [push, pull_request]
jobs:
  fontproof:
    runs-on: ubuntu-latest
    name: FontProof
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: FontProof
        uses: sile-typesetter/fontproof@latest
        with:
          args: proofs.sil
```

Add to your repository as `.github/workflows/fontproof.yml`.
This work flow assumes your project has a source file `proofs.sil` and will leave behind a `fontproof.pdf`.
Note that the comments in [the section about Docker](#docker-usage) regarding tagged versions besides `latest` apply equally here, but GitHub Actions uses an `@` separator instead of Docker's `:`.

## Adding or modifying tests

Each template can contain a full selection of tests. Each test is specified using a command in this general format:

``` sile
\commandname[set of parameters]{text to be typeset}
```

Some tests may have only parameters, or only text, or neither, as in this example that is natively supported within SILE itself:

``` sile
\pangrams
```

More details on running commands in SILE can be found in the SILE [manual](https://sile-typesetter.org/manual/sile-latest.pdf).

## Headings and sections

By default, the running head lists the filename, font (family or filename), date, and time. The content is not (currently) configurable, but you can set the font and size with the `\setRunHeadStyle` command. Note that this has no relation to the test font.

``` sile
%\setRunHeadStyle[filename="Example-Bold.ttf", size="12pt"]
```

To add a section and subsection headings:

``` sile
\section{Heading text}
\subsection{Heading text}
```

The style of these is not currently configurable, but you can manually tweak them for all FontProof docs by changing the settings in _classes/fontproof.lua_.

## Test types

The following kinds of tests are supported, and are illustrated in _fpFull.sil_ :

- Simple test text
- Waterfall (a text repeated in multiple sizes)
- Patterns (where a text is repeated with one or more substituted characters)
- Lorem ipsum
- Pangrams
- Full glyph repertoire

Details on the commands used to specify these are below.

## Contributing to the project

FontProof is Copyright © 2016 [SIL International](http://www.sil.org) and licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).
BTW - Despite the name similarity, SILE itself is not developed by SIL International, though we like the project very much.
You're very welcome to contribute to both FontProof and SILE.

---

# Proof Tests and Options

## Commands provided by FontProof

These commands are currently supported.

#### __\proof[]{}__

This is the main FontProof command, and can be used to set both simple test texts and waterfalls.
Optional parameters include font (by family or filename) and size(s).
You can also set a test heading here rather than using a separate `\section` command.

``` sile
\proof{This is basic proof text using the test font}

\proof[family="Gentium Plus",heading=A basic family test]{This is basic text with a font defined by family}

\proof[size="10pt",filename="Example-Light.ttf",heading=A basic filename test]{This is another basic text with common parameters}

\proof[size="10pt,11pt,12pt,16pt"]{This is basic proof text in a range of sizes}

\proof[size="10,11,12,13,20"]{This is basic proof text in a range of sizes with numbers only}

\proof[features="Ligatures=Rare, Ligatures=Discretionary"]{This is a proof with rare ligatures turned on}

\proof[features="+dlig,+hlig"]{This is a proof with features manipulated manually}

\proof[language="grk",direction = "rtl"]{Here are some options which are passed on to the font command}

\proof[color="green"]{Here are some options which are passed on to the color command}

\proof[shapers="ot,fallback"]{Here we pass a list of subshapers to Harfbuzz}
```

#### __\pattern[]{}__

This produces multiple copies of a text with a range of characters substituted in key places.
These are sometimes referred to as 'frame tests'.
Traditionally a common test of this type was the 'hobonop' test.
A 'hobonop' for the letters a b c d would look like:

> _haoabaoanaoap hbobbbobnbobp hcocbcocncocp hdodbdodndodp_

The command to produce this would be:

``` sile
\pattern[chars="@",reps="abcd"]{h@o@b@o@n@o@p}
```

This defines a placeholder character, then the set of letters used to replace it, then the text pattern containing the placeholder(s).

You can also use multiple placeholders to create all combinations, as in:

> _ooaxoo oobxoo oocxoo_   
> _ooayoo oobyoo oocyoo_

The command for this would be: (Be sure to follow the syntax of this exactly, or you may get very confusing errors!)

``` sile
\pattern[chars="@,#",reps="abc,xy"]{oo@#oo}
```

There are some characters that are special to SILE and Lua and shouldn't be used as _chars_.
(A list of suggested safe ones would be a good addition here!)
It's also a bad idea to use a character that is in _reps_.

There is one more optional parameter to the `\pattern` command:

- _format = "table"_ (the default) will typeset patterns with multiple placeholders grouped into one paragraph per second placeholder replacement.
- _format = "list"_ will typeset each pattern in a separate line (paragraph).
- _format = "para"_ will group all results into a single paragraph.

It's easier to demonstrate this than to explain.
First the formatted example, then the command to produce it:

> _ooaxoo oobxoo oocxoo_   
> _ooayoo oobyoo oocyoo_

``` sile
\pattern[chars="@,#",reps="abc,xy",format="table"]{oo@#oo}
```

> _ooaxoo_   
> _oobxoo_   
> _oocxoo_   
> _ooayoo_   
> _oobyoo_   
> _oocyoo_

``` sile
\pattern[chars="@,#",reps="abc,xy",format="list"]{oo@#oo}
```

> _ooaxoo oobxoo oocxoo ooayoo oobyoo oocyoo_

``` sile
\pattern[chars="@,#",reps="abc,xy",format="para"]{oo@#oo}
```

#### __\patterngroup[]{}__

This is cool!
Say that you have a group of letters that you want to use in multiple pattern tests, but don't want to have to define them over and over again.
You can define these as a pattern group, with a specific name.
Note that you have to define these groups in your document before you refer to them.
Also note that this command doesn't really produce anything on the page by itself.
It's only useful for later `\pattern` commands.

``` sile
\patterngroup[name="vowels"]{aeiou}
```

To refer to this in a `\pattern` command prefix the group name with "group_" and use in the `reps` parameter.
For example:

``` sile
\pattern[chars="@,#",reps="group_vowels,xy",format="table"]{oo@#oo}
```

There are also a few predefined groups, as listed below.
You can also define your own permanent groups in _packages/fontproofgroups.lua_.

| Group Name      | Description                |
|-----------------|----------------------------|
| group_az        | basic lowercase alphabet   |
| group_AZ        | basic uppercase alphabet   |
| group_combdiacs | basic combining diacritics |
| group_09        | basic numerals             |
| group_punct     | basic punctuation          |


## Additional FontProof Features

#### __text_*xxxxx*__

FontProof includes a range of built-in test texts.
Set the content of a `\proof` or `\pattern` command to any of the following preset `text_xxxx` names.
You can also add your own texts in _packages/fontprooftexts.lua_.

| Content           | Description                                                            |
|-------------------|------------------------------------------------------------------------|
| text_az           | basic lowercase alphabet                                               |
| text_AZ           | basic uppercase alphabet                                               |
| text_combdiacs    | basic combining diacritics                                             |
| text_spacingdiacs | basic spacing diacritics                                               |
| text_09           | basic numerals                                                         |
| text_numsym       | numerals and related symbols                                           |
| text_nummath      | mathematical symbols                                                   |
| text_symbols      | common symbols                                                         |
| text_punct        | basic punctuation                                                      |
| text_pangram      | simple pangram                                                         |
| text_verne        | excerpt from *20,000 Leagues Under the Sea*                            |
| text_verneCaps    | uppercase version                                                      |
| text_revEng       | excerpt from Revelation 7 (English)                                    |
| text_revFin       | excerpt from Revelation 7 (Finnish)                                    |
| text_revGer       | excerpt from Revelation 7 (German)                                     |
| text_revDut       | excerpt from Revelation 7 (Dutch)                                      |
| text_revInd       | excerpt from Revelation 7 (Indonesia)                                  |
| text_revSwa       | excerpt from Revelation 7 (Swahili)                                    |
| text_arrowroot    | traditional font testing text                                          |
| text_capslower    | Latin capitals against the lowercase key letters /o and /n             |
| text_bringhurst   | Kerning test from Bringhurst’s “Elements of Typographic Style”         |
| text_allkernpairs | Text containing all combinations of Latin upper and lower case letters |
| text_jafkerns     | Kerning test from Just Another Foundry’s text generator                |

#### __\adhesion__

This uses dictionaries to produce garbage text made up of real words, similar to `\lorem`.
However the words would only contain letters from a set you supply:

``` sile
\adhesion[characters=hamburgefonsiv]
```

Optional arguments are `words`, the number of words (defaulting to 120), and `dict`, the path of a dictionary file.
The class looks in `/usr/share/dict/words` and `/usr/dict/words` if the `dict` option is not provided.
Words are selected from the dictionary file if they contain only the characters specified.

####  __\gutenberg__

This downloads and typesets a text from Project Gutenberg.

``` casile
\gutenberg[id=100] % The complete works of Shakespeare
```

####  __\pi__

Typesets some digits of pi:

``` sile
\pi[digits=500]
```
#### __\unicharchart__

This produces a simple unbordered table that would show a range of unicode and any glyphs that represent the USVs in that range.

Some examples:

``` sile
\unicharchart[type="all",columns="12",rows="16"]
```

This produces a table that shows every encoded character in the font, formatted as a table with increasing USVs descending down a column, 16 chars per column, with a maximum of 12 columns before breaking into a new table.
This is very similar to the tables in The Unicode Standard code charts, and could be the default settings for a simple `\unicharchart`.

``` sile
\unicharchart[type="range",start="AA80",end="AADF"]
```

This produces the same, except only showing the given range of USVs.

## Commands provided natively by SILE

These work in SILE even without FontProof, although you would then need to load them with `\script[src=packages/specimen]`.

#### __\pangrams__

This produces a set of predefined pangrams.

#### __\lorem[words=#]__

This produces garbage _lorem ipsum_ text, with the number of words indicated.

#### __\repertoire__

This produces a nicely arranged table of all the glyphs in the font.

## Future features

Here are some commands we hope to someday support, with suggested command formats.
Some may never be implemented. Suggestions welcome!

#### Enhancements to __\proof__

We'd love to see even more potential parameters to `\proof`:

``` sile
\proof[
  size = "10, 11/13, 12/16",
  columns = 3,
  lines = 12
]{Text}
```

#### Support for multiple fonts with a single test type

Oooooh!

#### _What else would you like?_
