(* Interface for example0.ml. Only the functions below are exposed for use *)

module type SimpleModule_intf = sig
  val value: int
  val id : 'a -> 'a
end

module SimpleModule : SimpleModule_intf
                        
module SimpleModuleRedefined : SimpleModule_intf
                                                
module Result : sig

  (* Note that the actual implementation of Result.t is not exposed. Users of
     this module can use the type, but don't have access to the underlying
     constructors *)
  
  type ('a,'b) t
               
  val bind: ('a,'b) t -> f:('a -> ('c,'b) t) -> ('c,'b) t

  val return: 'a -> ('a,'b) t

  val error: 'b -> ('a,'b) t

  val get_ok : ('a,'b) t -> 'a option

  val get_error : ('a,'b) t -> 'b option
                                                             
end
