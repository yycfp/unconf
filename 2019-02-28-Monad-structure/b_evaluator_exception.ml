(* Adding exceptions *)

type term = Cons of int | Div of (term * term)

(* With side effects *)
let rec eval' : term -> int =
  function
  | Cons i -> i
  | Div (ti, tj) ->
     let i = eval' ti in
     let j = eval' tj in
     if j=0 then
       raise (Invalid_argument "Division by Zero")
     else
       i/j


(* Pure function *)
type 'a or_exception = Value of 'a | Except of string

let rec eval : term -> int or_exception =
  function
  | Cons i -> Value i
  | Div (ti, tj) ->
     match eval ti with
     | Except err -> Except err
     | Value i ->
        match eval tj with
        | Except err -> Except err
        | Value j -> 
           if j=0 then
             Except "Division by zero"
           else
             Value (i/j)

(* Now with Monads *)
let (>>=) : 'a or_exception -> ('a -> 'b or_exception) -> 'b or_exception = 
  fun ma f ->
  match ma with
  | Value a -> f a
  | e -> e

let unit a = Value a
                        
let except exn = Except exn
           
let rec eval_exception_m : term -> int or_exception =
  function
  | Cons i -> Value i
  | Div (ti, tj) ->
     eval_exception_m ti >>= fun i ->
     eval_exception_m tj >>= fun j ->
     if j=0 then
       except "Division by zero"
     else
       unit (i/j)

