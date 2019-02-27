type term = Cons of int | Div of (term * term)
                                 
let rec eval' = function
  | Cons i -> i
  | Div (ti,tj) -> (eval' ti) / (eval' tj)

type 'a i = 'a                                 
                                 
let (>>=) : 'a i -> ('a -> 'b i) -> 'b =
  fun a f ->
  f a
                                 
let rec eval = function
  | Cons i -> i
  | Div (ti,tj) ->
     eval ti >>= fun i ->
     eval tj >>= fun j ->
     i/j
