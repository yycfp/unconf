# misc-topics

A couple of examples using GADTs in Haskell presented at the Unconf(YYC.FP)
Meetup.
   
# Using the Examples
In order to run the examples a working installation of the *Glasgow Haskell
Compiler* (GHC) is needed because they use some of the GHC compiler extensions.
In addition, the standard *stack* build tool for Haskell is required, and, of
course, *git*.
After installing the prerequisites, clone the repository
```shell
$git clone https://gitlab.com/haskellhowtos/miscellaneous.git
```
from a shell, then `cd` into the resulting directory and run
```shell
$stack build
```
This may take a while because `stack build` will install a local version
of the *ghc* compiler used in the project into the project directory, as well
as some library dependencies. After a successful build, run the REPL with
```shell
$stack ghci
```
and play around with it. Note that subsequent builds will be much faster than
the initial one because only modified files will be rebuild.

## Documentation
Documentation more readable than the source files can be build with
```shell
$stack haddock --no-haddock-deps
```
followed by
```shell
$stack haddock --open misc-topics
```
which will open a tab in the browser with the documentation.

## Installation of Prerequisites
### GHC on Unix
Installation depends on the system. For GHC
https://www.haskell.org/ghc/distribution_packages.html
covers the most common unix-like systems, ie (Free)BSD, Mac, various Linux
distros. Most of the time it is as simple as using the native package manager.
### Haskell Stack on Unix
For *stack*, the place to go to is
https://docs.haskellstack.org/en/stable/install_and_upgrade/
On unix-like systems, the binaries for stack are usually installed locally
for every user in ~/.local/bin, make sure this is at the beginning of your PATH
or at least before the system directories because they may contain system-wide
variations of the same binaries, but usually older ones because the official distributions normally lag behind, quite often substantially.
### Windows (but also OSX and Ubuntu)
Windows users should check out
https://www.haskell.org/downloads
which contains binaries for windows that install both GHC and *stack*. This
seems to be the only way for windows users to install the prerequisites without
substantial effort.

Note that this route may also be followed by users of _OSX_ and _Ubuntu_.

# FAQ
Some answers to questions that came up during the meeting.
## Haskell
1. Where to go for Haskell info, news etc. ?
   * Introduction
     1. _Real_World_Haskell_ is a good choice for an introduction, not
        bleeding edge but freely available as both an online read and
	a download
     2. Haskell wiki: https://wiki.haskell.org
        Has lots of tutorials and documentation, link to _School of Haskell_
   * Documentation
     * Stack: https://docs.haskellstack.org/en/stable/README/
     * Packages: https://www.stackage.org/

       This is the home of the stack package server. All related documentation
       can be found there, changelogs for packages etc.
     * Hackage: https://hackage.haskell.org/
       Central package archive for Haskell, the place to go to for packages
       not found on stackage.
   * Latest

     Check out https://www.haskell.org/ghc/ for the latest compiler and its
     documentation.
   
## Language extensions
See https://limperg.de/ghc-extensions/ for a recent overview of available
extensions and how they came into being. This should answer a lot of questions
about language extensions.
1. Are there conflicting extensions?

   Probably not, only dangerous ones. A google search didn't reveal any
   conflicts, so it seems no one has detected any so far.
   
2. Do extension propagate from imported modules?

   Importing a module with extensions will not turn on these extensions in the
   importing module.
   
   Depending on how the imported module is used, the importing module may have
   to turn on additional extensions.

   For example, if the _Gadts_ module is imported somewhere and a pattern match
   on the constructors of _Term_ in the syle of the _eval_ function needs to be
   done, then the importing module needs the _Gadts_ extension as well.
   
   Usually, the compiler will tell and suggest that certain extensions be used.
   
3. How many extensions are there?

   Seems like 106 as of ghc-8.6.2, see
   https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html,
   which includes a list of them.
