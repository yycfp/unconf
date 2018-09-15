(* Functor can be extend to extend the functionalities of module

   For example, a queue can also be seen as a container of values. A container
   can have functions like `length`, `mem`bership, `count`, `exists`, etc. But
   those all be defined in terms of `fold` *)

module Queue = struct

  (* If we define our Queue and the `fold` function *)
  module T = struct
    type 'a t = 'a list

    let fold xs ~init ~f = List.fold_left f init xs
  end

  (* We can use the `Container.Make` functor to obtain all the Container related
     functions *)
  include Base.Container.Make(struct include T let iter = `Define_using_fold end)

  include T

  (* and Queue-specific functions *)
  let empty = []

  (* Note: inefficient implementation of a queue...*)
  let enqueue ls e = ls @ [e]

  let dequeue = function
      | [] -> None
      | x::xs -> Some (x,xs)

end
