open Core
let filename = "inputs/day1"

let lines = In_channel.read_lines filename

(* Lines look like "84283   63343". All numbers are always 5 digits so it can just be normally string sliced *)
(* This splits the line into the 2 numbers and converts them to ints *)
let process_line line = (Int.of_string (String.slice line 0 5), Int.of_string(String.slice line 8 13))
(* Convert the list of pairs into a pair of lists *)
let (a, b) = Stdlib.List.split (List.map lines ~f:process_line)
(* PART 1 *)
let a_sorted = List.sort a ~compare:(-)
let b_sorted = List.sort b ~compare:(-)
(* Calculate the distance between 2 numbers *)
let distance a b = Int.abs (a - b)
let distances = List.map2_exn a_sorted b_sorted ~f:distance
let ans = List.fold distances ~init:0 ~f:(+)
let () = print_endline (Int.to_string ans)
(* PART 2 *)
let similarity value = value * (List.count b ~f:((=) value))
let similarities = List.map a ~f:similarity
let ans = List.fold similarities ~init:0 ~f:(+)
let () = print_endline (Int.to_string ans)
