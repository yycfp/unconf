Introduction
============

This project was presented at the [Unconf (YYC . FP) Meetup](https://www.meetup.com/Functional-Programmers-YYC/) on September 13th 2018.

To run the examples in OCaml's REPL use:

``` $ dune utop example<n> ```

Where `<n>` is the example subfolder.

Why OCaml modules and functors? 
-------------------------------

OCaml has some interesting and powerful features around its modules. I thought
it would be interesting to share that with the Functional Programming Community in Calgary.

OCaml Modules - example0
========================

A module is a collection of definitions that are stored within a namespace. See `example0`. 
For example, obtaining the value inside SimpleModule

```
utop # Example0.SimpleModule.value;;
- : int = 1
```

Or applying the `id` the function:

```
utop # Example0.SimpleModule.id 10;;
- : int = 10
```

Using the `Result` type. Note that its type is `<abstract>`:

```
utop # Example0.Result.return 1;;
- : (int, '_weak1) Example0.Result.t = <abstr>
```

Or a more elaborated example

```
utop # Example0.Result.(return 1 |> bind ~f:(fun x-> return (x + 10)) |> get_ok);;
- : int option = Some 11
```

OCaml functors - example1
=========================

Do you know the concept of Haskell functors...?

```
class Functor f where
    fmap :: (a -> b) -> f a -> f b
    (<$) :: a -> f b -> f a
```

... well, just forget about it. Functors are a different beast in OCaml! Functors are "functions" from modules to modules. See `example1`

Functors to extend functionality - example2
===========================================

Functors can be used to extend a module functionality. Check out `example2`.

Functors to extract a common pattern - example3
===============================================

How would something like Haskell Typeclasses work in OCaml?

Let's re-implement [Haskell's
Data.Sort](http://hackage.haskell.org/package/sort/docs/Data-Sort.html):

     sort: (Ord a) => [a] -> [a]

Checkout `example3`. In OCaml, you have to be explicit about the `sort` function being used. For integers:

```
utop # Example3.IntSortableList.sort [3;2;1];;
- : int list = [1; 2; 3]
```

For strings:

```
utop # Example3.StringSortableList.sort ["qwe";"asd";"zxc"];;
- : string list = ["asd"; "qwe"; "zxc"]
```

The Downside is that you can't do ad-hoc polymorphism. The upside is that you
are always explicit about the type being used; you know what's being used where.

Functors in the wild
====================

Let's see how the `Option` monad is implemented in the [Base
library](https://github.com/janestreet/base/blob/master/src/option.ml). To get
all the monad's auxiliary function, you only need to define the type `t`, `return` and `bind`:

```
include Monad.Make (struct
    type 'a t = 'a option
    let return x = Some x
    let map t ~f =
      match t with
      | None -> None
      | Some a -> Some (f a)
    ;;
    let map = `Custom map
    let bind o ~f =
      match o with
      | None -> None
      | Some x -> f x
  end)
```

And you get all the auxiliary functions:

```
val ( >>= ) : 'a X.t -> ('a -> 'b X.t) -> 'b X.t
val ( >>| ) : 'a X.t -> ('a -> 'b) -> 'b X.t
module Monad_infix :
  sig
    val ( >>= ) : 'a X.t -> ('a -> 'b X.t) -> 'b X.t
    val ( >>| ) : 'a X.t -> ('a -> 'b) -> 'b X.t
  end
val bind : 'a X.t -> f:('a -> 'b X.t) -> 'b X.t
val return : 'a -> 'a X.t
val map : 'a X.t -> f:('a -> 'b) -> 'b X.t
val join : 'a X.t X.t -> 'a X.t
val ignore_m : 'a X.t -> unit X.t
val all : 'a X.t list -> 'a list X.t
val all_unit : unit X.t list -> unit X.t
val all_ignore : unit X.t list -> unit X.t

...
```
