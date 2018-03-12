(* This module solves the Longest Contiguous Increasing Range (LCIR) problem *)

open Core_kernel

type result = int * int [@@deriving show]

(** [find range] finds the longest contiguous increasing in [range] *) 

let find xs : result=
  let open List in
  xs
  |> mapi ~f:(fun i n -> (n,i))
  |> group ~break:(fun (n,_) (n',_) -> n > n')
  |> max_elt ~cmp:(fun l l' ->
      Int.compare (length l) (length l'))
  |> fun x -> Option.value_exn x
  |> fun l ->
  let i = hd_exn l |> snd in
  let j = last_exn l |> snd in
  (i,j)


let l = [5; 1; 2; 3; 0]

let l2 = [1; 3; 5; -9; 11; 12; 13; 15; 78484348; 11; 12 ;13; 0; -1; 343; 1222; 0]

let () =
  print_endline (show_result (find l));
  print_endline (show_result (find l2))
  
