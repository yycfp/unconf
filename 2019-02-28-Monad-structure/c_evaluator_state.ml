type term = Cons of int | Div of (term * term)

(* Adding state: how many divisions were made *)
let count = ref 0
          
let rec eval': term -> int =
  function
  | Cons i -> i
  | Div (ti, tj) ->
     let i = eval' ti in
     let j = eval' tj in
     count := !count + 1;
     i/j

(* Adding state - e.g. how many division were made *)
type ('a, 'b) state = 'b -> ('a * 'b)

let rec eval: term -> (int, int) state =
  function
  | Cons i -> fun s -> (i,s)
  | Div (ti, tj) ->  fun s -> 
                   let (i, s1) = eval ti s in
                   let (j, s2) = eval tj s1 in
                   (i/j, s2+1)

let (>>=) : ('a, 'b) state -> ('a -> ('c, 'b) state) -> ('c, 'b) state =
  fun ma f ->
  fun s ->
  let (a,s1) = ma s in
  f a s1

let return_s a = fun s -> (a,s)
    
let tick : (_, int) state =
  fun s -> ((), s+1)

let rec eval_state_m : term -> (int, int) state =
  function
  | Cons i -> return_s i
  | Div (ti, tj) ->
     eval_state_m ti >>=
       fun i -> eval_state_m tj >>=
                  fun j -> tick >>= fun () -> return_s (i/j) 
                             

