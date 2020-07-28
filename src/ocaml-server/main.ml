open Cohttp_async

type flag = { modified : bool ref};;
let file_flag = {modified = ref true} ;;

let serve_file ~docroot ~uri =
  Server.resolve_local_file ~docroot ~uri
  |> Server.respond_with_file

let serve ~docroot ~index uri path =
  let open Async in
  let file_name = Server.resolve_local_file ~docroot ~uri in
  try_with (fun () ->
      Unix.stat file_name
      >>= fun stat->
      match stat.Unix.Stats.kind with
      | `Directory ->
         begin
          let uri = Uri.with_path uri (String.concat "" [path; index]) in
          serve_file ~docroot ~uri
         end
      | `File -> serve_file ~docroot ~uri
      | `Socket | `Block | `Fifo | `Char | `Link ->
         Server.respond_string "Forbidden path or type\n"
    )
  >>= (function
       | Ok res -> return res
       | Error err -> raise err )

let handler ~docroot ~index ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let path = Uri.path uri in
  match Request.meth req with
  | (`GET | `HEAD) ->
     serve ~docroot ~index uri path;
  | _ ->
     Server.respond_string "Method not accepted\n"

let run_server ()=
  let open Async in
  let docroot = "../visual/webpage/." in
  let port = 3030 in
  let index = "index.html" in
  Server.create
    ~on_handler_error:(`Call (fun addr exn ->
        Logs.err (fun f -> f "Error from %s" (Socket.Address.to_string addr));
        Logs.err (fun f -> f "%s" @@ Base.Exn.to_string exn)))
    (Tcp.Where_to_listen.of_port port)
    (handler ~docroot ~index) >>= fun _serv ->
  Deferred.never ()


let parse_folder_to_file =
  Sys.argv.(1)
  |> String.split_on_char '/'
  |> List.filter (fun s -> s <> "")
  |> List.rev
  |> List.tl
  |> List.rev
  |> String.concat "/"

let contains s1 s2 =
    let re = Str.regexp_string s2
    in
        try ignore (Str.search_forward re s1 0); true
        with Not_found -> false

let check_if_specific_file_mod event =
  let file_name = Sys.argv.(1)
                  |> String.split_on_char '/'
                  |> List.filter (fun s -> s <> "")
                  |> List.rev
                  |> List.hd
  in
  if contains event "modified" && contains event file_name then
    let _ = Sys.command (String.concat "" ["mi "; Sys.argv.(1);" > ../visual/webpage/js/data-source.js "]) in
    let _ = Sys.command("./refreshpage.sh") in
    (file_flag.modified) := true;;
    ()

let check_file_updates ()=
  let inotify = Async_inotify.create (String.concat "" ["./"; parse_folder_to_file]) in
  let open Async in
  inotify >>= (fun (a , _) ->
    let s = Async_inotify.stream a in
    Async_kernel.Stream.iter' ~f:(fun ev -> Deferred.return (check_if_specific_file_mod (Async_inotify.Event.to_string ev) )) s
  )



let run_server_and_check_for_file_updates _ () =
  Async.Deferred.all_unit [check_file_updates (); run_server ()]



exception Incorrect_Arguments of string
let get_arg_cmd =
  let open Printf in
  if Array.length Sys.argv = 2 then
    printf "%s\n" Sys.argv.(1)
  else
    raise (Incorrect_Arguments "Incorrect number of arguments")

let init_data_source =
  let _ = Sys.command (String.concat "" ["mi "; Sys.argv.(1);" > ../visual/webpage/js/data-source.js "]) in
  ()
let () =
  print_endline "Server running, listening on port 3030 for HTTP requests\n http://127.0.0.1:3030\n";
  init_data_source;
  get_arg_cmd;
  let open Async_command in
  run @@
    begin
      async_spec ~summary: "Run server"
        Spec.(
      empty
      +> anon (maybe_with_default "." ("docroot" %: string))
      ) run_server_and_check_for_file_updates;
    end



