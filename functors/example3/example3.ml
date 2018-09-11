open Base

(* Implementing Haskell's Data.Sort
   sort: (Ord a) => [a] -> [a] *)                         

module type Sortable = sig
  type t
  val compare: t -> t -> int
end

module SortableList
         (X: Sortable) = struct
  let sort ls = List.sort ~compare:X.compare ls
end

module IntSortableList =
  SortableList(struct
      type t=int
      let compare = Int.compare
    end)

module StringSortableList =
  SortableList(struct
      type t=string
      let compare = String.compare
    end)



(* In OCaml, you have to be explicit about everything
   - downside: can't do generic programming
   - upside: you are explicit about it and always know what's being used in your program *)
