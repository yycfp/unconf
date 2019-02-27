include A_simple_evaluator

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

