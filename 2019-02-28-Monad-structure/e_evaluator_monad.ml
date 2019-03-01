(* By now you probably noticed the same pattern :

 M >>= fun a -> n

- Exception:
  eval_exception_m ti >>= fun i ->
  eval_exception_m tj >>= fun j ->
  if j=0 then
    except "Division by zero"
  else
    unit (i/j)

- State:
  eval_state_m ti >>= fun i ->
  eval_state_m tj >>= fun j ->
  tick >>= fun () ->
  return_s (i/j) 

- Logging:
  eval_output_m ti >>= fun i ->
  eval_output_m tj >>= fun j ->
  log (sprintf "Div %d %d => %d\n" i j (i/j)) >>= fun () ->
  unit (i/j) 

*)


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

(* Thoughts

- We can achieve purity writting code that is very similar to impure

- Monad captures effect: state, generate output, raise an exception, etc

- Monads capture "effects" (or computations) and compose them.
  - how do you personally think about monads?

- You can compose values, but also functions. E.g. the State Monad:

  ('a, 'b) state -> ('a -> ('c, 'b) state) -> ('c, 'b) state
  
  is actually

  'b -> ('a, 'b) -> ('a -> 'b -> ('c, 'b)) -> 'b -> ('c, 'b)

- In your day to day, which computations could be written as compositions?
  - Exception, Logging and State are well known uses. How do you find those use 
    cases? 
  - There are other forms of composition: function composition, monoids

- Interesting quote from the papre "the structuring methods presented here 
  would have been discovered without the insight afforded by category theory. 
  But once discovered they are easily expressed without any reference to things 
  categorical"

- Comment from the group: check out Kleisli triplets (or category)

 *)
