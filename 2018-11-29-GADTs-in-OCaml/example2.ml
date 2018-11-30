(* My own example: modelling a valve
   - Valve can be open or close.  
   - Some operations can be applied only when the valve is open, only 
     when the valve is closed or both *)

type open_
type close

type _ valve =
  | Opened: {flow:int} -> open_ valve
  | Closed : close valve

let new_valve = Closed

(* open_valve can only be applied to a Closed valve *)                  
let open_valve flow = function
  | Closed -> Opened {flow}

(* Alternative implementation: can be applied to either Opened or Closed
   valve
let open_valve : type a . int -> a valve -> op valve = fun flow ->
  function
  | Closed -> Opened {flow}
  | Opened {flow} -> Opened {flow}
 *)

(* increase_flow can only be applied to Opened valves *)
let increase_flow delta = function
  | Opened {flow} ->  Opened {flow=flow+delta}

(* close_valve can only be applied to an Opened valve *)
let close_valve = function                         
    Opened _ -> Closed

(* query_flow can be applied to either Opened or Closed valves *)
let query_flow : type a. a valve -> int = function
  | Opened {flow} -> flow
  | Closed -> 0
           
let run_procedure () =
  new_valve
  |> open_valve 10
  |> increase_flow 2
  |> increase_flow 3
(*  |> open_valve 3 *)
(* Opening an already opened valve doesn't type check! *)


(* Summing up my thoughts, when to use GADTs?

- When you want to be able to treat your sum types separately

- When you want to use the type system to represent something - 
  e.g. state

- When you need to add extra cases for invalid states to make your 
  pattern matches exhaustive

*)
