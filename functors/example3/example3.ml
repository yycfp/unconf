open Base

(* Let's implement Haskell's Data.Sort

     sort: (Ord a) => [a] -> [a]
*)

(* Let's define what it means to be a module of type `Ord`: *)
module type Ord = sig
  type t
  val compare: t -> t -> int
end

(* Given a module `X` that has the `Ord` signature, the functor will produce a
   `sort` functions for that module *)
module SortableList
         (X: Ord) = struct
  let sort ls = List.sort ~compare:X.compare ls
end

(* Instantiating a list of integers that is sortable *)
module IntSortableList =
  SortableList(struct
      type t=int
      let compare = Int.compare
    end)

(* And a list of strings that is sortable *)
module StringSortableList =
  SortableList(struct
      type t=string
      let compare = String.compare
    end)

