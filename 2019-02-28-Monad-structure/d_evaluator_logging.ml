open Printf

include A_simple_evaluator

(* Adding logging - e.g. describe the operations being done *)
type 'a output = 'a * string

let rec eval : term -> int output =
  function
  | Cons i -> (i, (sprintf "Cons %d => %d\n" i i) )
  | Div (ti, tj) ->
     let (i, output_i) = eval ti in
     let (j, output_j) = eval tj in
     (i/j, output_i ^ output_j ^ (sprintf "Div %d %d => %d\n" i j (i/j)))


let (>>=) : 'a output -> ('a -> 'b output) -> 'b output =
  fun (a, out) f ->
  let (b, out1) = f a in
  (b, out ^ out1)

let return_o a = (a, "")


let log msg = ((), msg)
                
let rec eval_output_m : term -> int output =
  function
  | Cons i -> log (sprintf "Cons %d => %d\n" i i) >>= fun () -> return_o i
  | Div (ti, tj) ->
     eval_output_m ti >>=
       fun i -> eval_output_m tj >>=
                  fun j -> log (sprintf "Div %d %d => %d\n" i j (i/j)) >>=
                             fun () -> return_o (i/j) 
