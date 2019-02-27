open Printf

type term = Cons of int | Div of (term * term)
                                 
let rec eval = function
  | Cons i -> i
  | Div (ti,tj) -> (eval ti) / (eval tj)


(* Adding exceptions *)
type 'a or_exception = Return of 'a | Except of string

let rec eval_exception : term -> int or_exception =
  function
  | Cons i -> Return i
  | Div (ti, tj) ->
     match eval_exception ti with
     | Except err -> Except err
     | Return i ->
        match eval_exception tj with
        | Except err -> Except err
        | Return j -> 
           if j=0 then
             Except "Division by zero"
           else
             Return (i/j)
              
(* Adding state - e.g. how many division were made *)
type ('a, 'b) state = 'b -> ('a * 'b)

let rec eval_state: term -> (int, int) state =
  function
  | Cons i -> fun s -> (i,s)
  | Div (ti, tj) ->  fun s -> 
                   let (i, s1) = eval_state ti s in
                   let (j, s2) = eval_state tj s1 in
                   (i/j, s2+1)

(* Adding logging - e.g. describe the operations being done *)

type 'a output = 'a * string

let rec eval_output : term -> int output =
  function
  | Cons i -> (i, (sprintf "Cons %d => %d\n" i i) )
  | Div (ti, tj) ->
     let (i, output_i) = eval_output ti in
     let (j, output_j) = eval_output tj in
     (i/j, output_i ^ output_j ^ (sprintf "Div %d %d => %d\n" i j (i/j)))


       (* Same pattern *)
let (>!) : 'a or_exception -> ('a -> 'b or_exception) -> 'b or_exception = 
  fun ma f ->
  match ma with
  | Return a -> f a
  | e -> e

let return_er a = Return a
                        
let return_ee exn = Except exn
           
let rec eval_exception_m : term -> int or_exception =
  function
  | Cons i -> Return i
  | Div (ti, tj) ->
     eval_exception_m ti >!
       fun i -> eval_exception_m tj >!
                  fun j -> if j=0 then
                             return_ee "Division by zero"
                           else
                             return_er (i/j)

let (>@) : ('a, 'b) state -> ('a -> ('c, 'b) state) -> ('c, 'b) state =
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
     eval_state_m ti >@
       fun i -> eval_state_m tj >@
                  fun j -> tick >@ fun () -> return_s (i/j) 
                             

let (>$) : 'a output -> ('a -> 'b output) -> 'b output =
  fun (a, out) f ->
  let (b, out1) = f a in
  (b, out ^ out1)

let return_o a = (a, "")


let log msg = ((), msg)
                
let rec eval_output_m : term -> int output =
  function
  | Cons i -> log (sprintf "Cons %d => %d\n" i i) >$ fun () -> return_o i
  | Div (ti, tj) ->
     eval_output_m ti >$
       fun i -> eval_output_m tj >$
                  fun j -> log (sprintf "Div %d %d => %d\n" i j (i/j)) >$
                             fun () -> return_o (i/j) 
