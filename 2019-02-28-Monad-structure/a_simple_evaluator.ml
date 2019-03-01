(* Here's our a example: a simple language for expressing division. E.g.
  
   (Div (Div (Cons 10, Cons 2), Cons 5)) = (10/20)/5

*)

type term = Cons of int | Div of (term * term)

let example = Div (Cons 2, Cons 2)
                                   
let rec eval = function
  | Cons i -> i
  | Div (ti,tj) -> (eval ti) / (eval tj)
