# misc-topics

Some small howtos and explanations that aren't big enough for separate
projects. The files in the _src_ directory each contain a separate
topic.
At the moment there is

 - Gadts.hs

   Generalised Algebraic data-types
 - TypeCalcs.hs
 
   Some examples for calculations with types and how to use the type
   literals in the GHC.TypeLit module.
 - Singles.hs
 
   Some experiments to understand the singletons library and how to
   use it with *Nat*.

 - TypeLitX.hs

   Some extended insights into the use of the GHC.TypeLit module.

 - Utils.hs

   Some examples of how common utilities would be implemented in Haskell.
   
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
4. ## Debugging
   Although there is a common perception that "if it compiles it works" holds
   for Haskell code, there are still many roads to perdition. They can be
   explored with the ghci debugging facilities documented in
   https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/ghci.html#the-ghci-debugger
   for the latest _ghc_.
   
   The closest to the popular `printf` procedure would be to take
   subexpressions out
   of their parents and run them separately in _ghci_ to see if they do what
   they are supposed to do.
   
   Using _gdb_ on generated machine code is only recommended
   for people who need to to test their resilience to insanity. Due to
   lazy evaluation, there is little correspondence between anything that may
   be construed as a variable and its value.

   This is even a problem in the
   native _ghci_ debugger, where values often have to be `:forced` to be
   evaluated, a normal `:print` request often just reveals a number of
   _thunks_ available at a certain step of the evaluation.
   
5. ## A Syntax Primer
   In order to understand what's going on in the examples, here is a short
   syntax primer for Haskell expressions. For more detail, see the cheat-sheet
   for Haskell syntax at http://cheatsheet.codeslower.com/
   ### Expressions and Functions
   Everything starting with upper case is either type related, be it a type,
   a type function or type constructor or a module name. A function is defined
   by a type annotation followed by an equation.
   ```haskell
   functionname :: InputType -> OutputType
   functionname arg = ...
   ```
   There are no keywords like _fun_ or _def_ because every definition in
   Haskell is an equation and the question of whether it is a function
   solely resides in the mind of the observer.
   
   The type annotation is often not required because the compiler can deduce
   them from the function definition.
   
   For example, a squaring function might be defined as
   ```haskell
   square :: Double -> Double
   square x = x*x
   ```
   For Haskell, this is unsatisfactory because the function type of `Double`
   is too strict, the only thing that is needed is a type that allows
   multiplication. This is where type classes, constraints and type variables
   enter the fray:
   ```haskell
   square :: Num a => a -> a
   square x = x*x
   ```
   In this example, `Num` is a predefined Haskelltype class providing `+`, `-`,
   `*` and some conversion functions, `a` is a type variable and `Num a` is
   a _constraint_ on the type variable. As a result, `square` works on any
   type that is an _instance_ of `Num`. Instance examples are `Double`, 
   `Integer`, `Int` and anything conceivable that may implement the
   requirements of `Num`.

   The signature ```Num a => a -> a``` is actually what the compiler
   would have deduced from the use of x in the absence of the type annotation
   ```Double -> Double```.
   
   In a true functional language, the concept of _arity_ becomes fuzzy because
   a function can return another function so the number of arguments of a
   function becomes debatable. A function like ```add``` can be considered
   a function of two arguments returning a number or a function of one argument
   returning a function that can take another argument.

   Haskell's position is that every function takes one argument
   and returns something, perhaps a function ready to take another
   argument.
   
   Thus, a seemingly two argument function like `add` is a one argument
   function which returns another function taking the second argument. This
   means that, for example, ```add 1 ``` is a function that adds
   _1_ to its argument so that ```add 1 2``` results in the expected
   _3_. This concept is called _Currying_ and is FUNDAMENTAL to functional
   programming, which is why there can be no parentheses around function
   arguments. Code like ```f (x,y)``` does not indicate a function of two
   arguments, rather ```f``` is a function of one argument taking a tuple
   ```(x,y)``` as argument.
   
   ## Types
   Types are introduced with the ```data``` keyword, type synonyms, somewhat
   confusingly, with the ```type``` keyword and a hybrid of the two with
   the ```newtype``` keyword. A ```newtype``` wraps a type in a way that
   it almost becomes a type synonym for the wrapped type but is treated like a
   separate type by the compiler.
   ### Union Types
   TODO
   ### Product Types
   TODO
   
