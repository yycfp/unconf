(* Algebraic Datatypes - ADTs*)

type sum =
  | A
  | B

type product = (int * string)

type both =
  | C of { an_int: int; a_string: string}
  | D of int


let do_something_with_both =
  function
  | C {an_int; a_string} ->
         "An int " ^ (string_of_int an_int) ^ " a string " ^ a_string
  | D i -> "An int " ^ (string_of_int i)
                         
(* 

fun fact: records and tuples are "the same" 

{ an_int: int; a_string: string}

(int, string)

*)

(* Another ADT: *)
type ('a, 'b) typ =
  | Int of int
  | String of string
  | Pair of 'a * 'b 

(* Rewritting the example above in GADT syntax 
   Note: all constructors have type ('a, 'b) typ *)

type ('a, 'b) typ =
  | Int: int -> ('a, 'b) typ
  | String: string -> ('a, 'b) typ
  | Pair: 'a * 'b -> ('a, 'b) typ
                              
(* Now using GADT's feature
   Note: the constructors now have specific type *)

type _ typ =
  | Int: int -> int typ
  | String: string -> string typ
  | Pair: 'a * 'b -> ('a * 'b) typ
                  
(* With GADT we can define function for individual constructors 
   (and it type checks!) *)
                               
let function_for_int : (int typ -> int) = function
  | Int i -> i
               
let function_for_string = function
  | String s -> s

(* Or a function for all constructors *)                  

let function_for_all : type t . t typ -> string =
  function
  | Int _ -> "int"
  | String _ -> "string"
  | Pair _ -> "pair"

(* Sources: 
   - https://www.reddit.com/r/ocaml/comments/1jmjwf/explain_me_gadts_like_im_5_or_like_im_an/ 
*)
