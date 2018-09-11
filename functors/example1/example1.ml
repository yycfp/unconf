module type X_int = sig val x : int end

(* More complex than function from module to module
   f : (arg types) -> (result type)
   Functor (Module variable: arg types) -> (result type)
 *)

                      
module Increment (M : X_int) : X_int = struct
  let x = M.x + 1
end

module M1 : X_int = struct
  let x = 1
end

module M2 : X_int = Increment (M1)

(* Functors are similar to object oriented when evaluating if a module satisfy the interface *)

module More_than_3 = struct
  let x = 3
  let as_string = "three"
end

module M4 : X_int = Increment(More_than_3)                       
