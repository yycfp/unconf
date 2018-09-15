module Queue : sig 
  type 'a t

  val empty : 'a t
          
  val enqueue: 'a t -> 'a -> 'a t
  val dequeue: 'a t -> ('a * 'a t) option

  (* Including the Container signature to expose Container-specific functions *)
                                   
  include Base.Container.S1 with type 'a t := 'a t
end
