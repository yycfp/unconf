(* Some other examples I don't totally follow: *)
(* Source: https://caml.inria.fr/pub/docs/manual-ocaml/extn.html#sec252 *)

(* Here is an example of a polymorphic function that takes the runtime 
   representation of some type t and a value of the same type, then 
   pretty-prints the value as a string: *)
                                                        
type _ typ =
  | Int : int typ
  | String : string typ
  | Pair: 'a typ * 'b typ -> ('a * 'b) typ

let rec to_string : type t . t typ -> t -> string =
  fun typ x ->
  match typ with
  | Int -> string_of_int x
  | String -> x
  | Pair (t1, t2) ->
     let (x1, x2) = x in
     Printf.sprintf "(%s,%s)" (to_string t1 x1) (to_string t2 x2)

let example = to_string (Pair (Int, Pair (Int,String))) (1,(1,"2"))

(* Another frequent application of GADTs is equality witnesses. *)
type (_,_) eq = Eq : ('a,'a) eq

let cast : type a b. (a,b) eq -> a -> b = fun Eq x -> x

let example = cast Eq 1                                                        
                                                        
(* Here is an example using both singleton types and equality witnesses 
   to implement dynamic types. *)
let rec eq_type : type a b . a typ -> b typ -> (a,b) eq option =
  fun a b ->
  match a, b with
  | Int, Int -> Some Eq
  | String, String -> Some Eq
  | Pair (a1, a2), Pair (b1, b2) ->
     begin match eq_type a1 b1, eq_type a2 b2 with
     | Some Eq, Some Eq -> Some Eq
     | _ -> None
     end
  | _ -> None

type dyn = Dyn: 'a typ * 'a -> dyn

let get_dyn : type a. a typ -> dyn -> a option =
  fun a (Dyn (b,x)) ->
  match eq_type a b with
  | None -> None
  | Some Eq -> Some x
