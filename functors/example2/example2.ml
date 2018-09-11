module Queue = struct
  module T = struct
    type 'a t = 'a list

    let fold xs ~init ~f = List.fold_left f init xs
  end
               
  include Base.Container.Make(struct include T let iter = `Define_using_fold end)

  include T

  let empty = []

  (* Inefficient implementation of a queue...*)
  let enqueue ls e = ls @ [e]

  let dequeue = function
      | [] -> None
      | x::xs -> Some (x,xs)

end
