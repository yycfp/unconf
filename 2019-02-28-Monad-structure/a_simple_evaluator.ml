type term = Cons of int | Div of (term * term)
                                 
let rec eval = function
  | Cons i -> i
  | Div (ti,tj) -> (eval ti) / (eval tj)
