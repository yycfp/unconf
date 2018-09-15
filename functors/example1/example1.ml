(* Defining the signature of a module to be used in the functor *)
module type X_int = sig
  val x : int
end

(* Increment is a functor that takes module of type X_ing, `(M : X_int)` and
   returns a module of type `: X_int` *)
module Increment (M : X_int) : X_int = struct

  (* It uses the `x` value from the module `M` passed as arguments and adds 1 *)
  let x = M.x + 1
end

(* Let's define an initial module that contains the value 1 *)
module M1 : X_int = struct
  let x = 1
end

(* A module with value 2 can now be defined using the `Increment` functor *)
module M2 : X_int = Increment (M1)

(* The module passed as arguments doesn't need to be named. It can be an
   "anonymous module" *)
module M3 : X_int = Increment (struct let x = 2 end)

(* What if the module has more values than the functor expects? Say an extra
   `as_string` value *)
module More_than_3 = struct
  let x = 3
  let as_string = "three"
end

(* If the functor signature is contained in the `More_than_3`, the extraneous
   values are simply ignored *)
module M4 : X_int = Increment(More_than_3)                       

(* Note that functors are a bit more than a function from module to module.
   
   A function goes from type `'a` to type `'b`

      Function: f : 'a -> - b

   Whereas the functor goes from <module type> to <resulting module type>, but 
   the values of the module can be used as part of the resulting module 
   definition:

      Functor: (<module name>: <module type>) -> <resulting module type>
 *)
