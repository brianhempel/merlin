open Std
module Ex = Merlin_recovery_explain

type t = {
  loc: Location.t;
  explanation: Ex.explanation;
}
exception Error of t

let loc t = t.loc

let friendly_concat = function
  | [] -> ""
  | [a] -> a
  | [a; b] -> a ^ " or " ^ b
  | hd :: tl ->
    String.concat ", " tl ^ " or " ^ hd

let classify {explanation = {Ex. item; unclosed; expected}} =
  let inside = match item with
    | None -> ""
    | Some (name, _) -> " inside " ^ name in
  let after = match unclosed with
    | None -> ""
    | Some (name, _) -> " after unclosed '" ^ name ^ "'" in
  let expecting = match expected with
    | [] -> ""
    | classes ->
      let names = List.filter_map ~f:Raw_parser_values.friendly_name classes in
      let names = List.filter_dup names in
      let symbols = List.map ~f:Raw_parser_values.string_of_class classes in
      let symbols = List.filter_dup symbols in
      ", expecting " ^ friendly_concat names ^ " (" ^ friendly_concat symbols ^ ")"
  in
  Printf.sprintf "Syntax error%s%s%s"
    inside after expecting

let from parser (s,token,e) =
  let loc = {Location. loc_start = s; loc_end = e; loc_ghost = false } in
  Error { loc; explanation = Ex.explain parser }