(* Canonical example of GADT... expressing type-checked AST *)

(* ADT-only *)

type value =
  | Bool of bool
  | Int of int

type expr =
  | Value of value
  | If of expr * expr * expr
  | Eq of expr * expr
  | Lt of expr * expr

let rec eval: expr -> value = function
  | Value v -> v
  | Lt (x, y) ->
     begin match eval x, eval y with
     | Int x, Int y -> Bool (x < y)
     | Int _, Bool _
       | Bool _, Int _
       | Bool _, Bool _ -> failwith "Invalid AST"
     end
  | If (b, l, r) ->
     begin match eval b with
     | Bool true -> eval l
     | Bool false -> eval r
     | Int _ -> failwith "Invalid AST"
     end
  | Eq (a, b) ->
     begin match eval a, eval b with
     | Int  x, Int  y -> Bool (x = y)
     | Bool _, Bool _
     | Bool _, Int  _
     | Int  _, Bool _ -> failwith "Invalid AST"
     end

(* Valid AST *)
let a = eval (If ((Lt ((Value (Int 2)), (Value (Int 4)))), (Value (Int 42)), (Value (Int 0))))

(* Invalid AST - fails a runtime only *)
let b = eval (Eq ((Value (Int 42)), (Value (Bool false))))

(* With GADT *)
       
type _ value =
  | Bool : bool -> bool value
  | Int : int -> int value

type _ expr =
  | Value : 'a value -> 'a expr
  | If : bool expr * 'a expr * 'a expr -> 'a expr
  | Eq : 'a expr * 'a expr -> bool expr
  | Lt : int expr * int expr -> bool expr


let rec eval : type a. a expr -> a = function
  | Value (Bool b) -> b
  | Value (Int i) -> i
  | If (b, l, r) -> if eval b then eval l else eval r
  | Eq (a, b) -> (eval a) = (eval b)
  | Lt (a,b) -> (eval a) < (eval b)

(* Valid AST - type checks *)
let a = eval (If ((Eq ((Value (Int 2)), (Value (Int 2)))), (Value (Int 42)), (Value (Int 12))))

(* Invalid AST - doesn't type check *)
(* let b = eval (If ((Value (Int 42)), (Value (Int 42)), (Value (Int 42)))) *)

(*
Source:
- https://mads-hartmann.com/ocaml/2015/01/05/gadt-ocaml.html
 *)
