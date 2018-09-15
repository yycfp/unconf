(* An example of SimpleModule. It contains one `value` and one function `id` *)
(* A module is definde with the `struct ... end` construct *)
module SimpleModule = struct
  let value = 1
  let id x = x
end

(* Modules have types too. They can inferred or defined using the `sig .. end` construct *)
module type SimpleModule_intf = sig
  val value: int
  val id : 'a -> 'a
end

(* You can define a module enforcing its type *)                                 
module SimpleModuleRedefined  = struct
  let value = 1
  let id x = x
end

(* A more complex example, a sum type and associated functions *)
module Result = struct
  type ('a,'b) t = Ok of 'a | Error of 'b

  let bind ra ~f =
    match ra with
        | Ok a -> f a
        | Error b -> Error b

  let return a = Ok a

  let error b = Error b

  let get_ok = function
    | Ok a -> Some a
    | _ -> None

  let get_error = function
    | Error a -> Some a
    | _ -> None

end
