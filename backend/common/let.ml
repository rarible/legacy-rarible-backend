let (let>) = Lwt.bind
let (let|>) p f = Lwt.map f p
let (let>?) p f = Lwt.bind p (function Error e -> Lwt.return_error e | Ok x -> f x)
let (let|>?) p f = Lwt.map (function Error e -> Error e| Ok x -> Ok (f x)) p

let (>>=) = Lwt.bind
let (>|=) p f = Lwt.map f p
let (>>=?) p f = Lwt.bind p (function Error e -> Lwt.return_error e | Ok x -> f x)
let (>|=?) p f = Lwt.map (function Error e -> Error e| Ok x -> Ok (f x)) p

type error = [
  | Crawlori.Rp.error
]

let fold_rp f acc l =
  let rec aux acc = function
    | [] -> Lwt.return_ok acc
    | h :: t ->
      Lwt.bind (f acc h) (function
          | Error e -> Lwt.return_error e
          | Ok () -> aux acc t) in
  aux acc l

let iter_rp f l = fold_rp (fun () x -> f x) () l
