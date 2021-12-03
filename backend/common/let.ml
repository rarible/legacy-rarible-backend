type error = [
  | Crawlori.Rp.error
  | `unexpected_michelson_value
  | `unmatched_curve
]

let (let>) = Lwt.bind
let (let|>) p f = Lwt.map f p
let (let>?) p f = Lwt.bind p (function Error e -> Lwt.return_error e | Ok x -> f x)
let (let|>?) p f = Lwt.map (function Error e -> Error e| Ok x -> Ok (f x)) p

let (>>=) = Lwt.bind
let (>|=) p f = Lwt.map f p
let (>>=?) p f = Lwt.bind p (function Error e -> Lwt.return_error e | Ok x -> f x)
let (>|=?) p f = Lwt.map (function Error e -> Error e| Ok x -> Ok (f x)) p

let (let$) = Result.bind
let (let|$) e f = Result.map f e

let fold_rp f acc l =
  let rec aux acc = function
    | [] -> Lwt.return_ok acc
    | h :: t ->
      Lwt.bind (f acc h) (function
          | Error e -> Lwt.return_error e
          | Ok acc -> aux acc t) in
  aux acc l

let iter_rp f l = fold_rp (fun () x -> f x) () l

let map_rp f l =
  let rec aux acc = function
    | [] -> Lwt.return_ok acc
    | h :: t ->
      Lwt.bind (f h) (function
          | Error e -> Lwt.return_error e
          | Ok x -> aux (x :: acc) t) in
  Lwt.map (Result.map List.rev) (aux [] l)

let map_res f l =
  let rec aux acc = function
    | [] -> Ok (List.rev acc)
    | t :: q -> match f t with
      | Ok x -> aux (x :: acc) q
      | Error e -> Error e in
  aux [] l

let string_of_error : error -> string = function
  | #Crawlori.Rp.error as e -> Crawlori.Rp.string_of_error e
  | `unexpected_michelson_value -> "unexpected_michelson_value"
  | `unmatched_curve -> "unmatched_curve"
