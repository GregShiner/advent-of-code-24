open Core
let filename = "inputs/day2"

type level_comparison = 
    | Ascending
    | Descending
    | Invalid

let compare_levels (a, b) : level_comparison = 
    match b - a with
        | diff when (diff >= 1 && diff <= 3) -> Ascending
        | diff when (diff <= -1 && diff >= -3) -> Descending
        | _ -> Invalid

let rec pair_list (lst : 'a list) : ('a * 'a) list =
    match lst with
        | a :: b :: [] -> [(a, b)]
        | a :: b :: rest -> (a, b) :: pair_list (b :: rest)
        | _ -> raise (Invalid_argument "String must have 2 or more elements")

let is_valid_report (report : level_comparison list) : bool =
    (List.for_all report ~f:(fun level -> 
        match level with
            | Ascending -> true
            | _ -> false)) ||
    (List.for_all report ~f:(fun level -> 
        match level with
            | Descending -> true
            | _ -> false))

(* Part 1*)
let _ = 
    In_channel.read_lines filename
    |> List.map ~f:(String.split ~on:' ')
    |> List.map ~f:(List.map ~f:Int.of_string)
    |> List.map ~f:pair_list
    |> List.map ~f:(List.map ~f:compare_levels)
    |> List.count ~f:is_valid_report
    |> Int.to_string
    |> print_endline

