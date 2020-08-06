open Lwt.Infix
open Cohttp_lwt_unix


type flag = { modified : bool ref};;
let file_flag = {modified = ref true} ;;

let contains s1 s2 =
    let re = Str.regexp_string s2 in
    try ignore (Str.search_forward re s1 0); true
    with Not_found -> false

let modify_flag () =
  let open Printf in
  let file = "../webpage/js/flag.json" in
  let message = "{\n \t\"modifiedByTheServer\": 0,\n \t \"modifiedByTheClient\": 0\n}" in
  let oc = open_out file in
  fprintf oc "%s\n" message;
  close_out oc;
  ()
       
let check_if_specific_file_mod event =
  let file_name = Sys.argv.(1)
                  |> String.split_on_char '/'
                  |> List.filter (fun s -> s <> "")
                  |> List.rev
                  |> List.hd
  in
  if contains event "Updated" && contains event file_name then
     let _ = Sys.command (String.concat "" ["mi "; Sys.argv.(1);" > ../webpage/js/data-source.json "]) in
     let open Printf in
     let file = "../webpage/js/flag.json" in
     let message = "{\n \t\"modifiedByTheServer\": 1,\n \t \"modifiedByTheClient\": 0\n}" in
     let oc = open_out file in
     fprintf oc "%s\n" message;
     close_out oc;
     (file_flag.modified) := true;
  else
    if contains event "Updated" && contains event "data-source.json" then
      let open Yojson.Basic.Util in
      let flag_json = Yojson.Basic.from_file "./../webpage/js/flag.json" in
      let modifiedByTheClient = flag_json |> member "modifiedByTheClient" |> to_int in
      if modifiedByTheClient = 1 then
        (* Get the ID of the modified model *)
        print_endline "Modified by the client"
        


let decode_post uri () =
  if contains (Uri.to_string uri) "js/flag.json" then
      modify_flag ()
     
let serve_file ~docroot ~uri =
  let fname = Server.resolve_local_file ~docroot ~uri in
  Server.respond_file ~fname ()

let serve ~docroot ~index uri path =
  let file_name = Server.resolve_local_file ~docroot ~uri in
  Lwt.catch (fun () ->
      Lwt_unix.stat file_name
      >>= fun stat ->
      match stat.Unix.st_kind with
      | S_DIR ->
         begin
           let uri = Uri.with_path uri (String.concat ""[path; index]) in
           serve_file ~docroot ~uri
         end
      | S_REG ->
         serve_file ~docroot ~uri
      | _ ->
         Server.respond_string ~status:`Forbidden
           ~body:"Forbidden path" ()
    ) (function
      | _ -> Server.respond_string ~status:`Not_found
               ~body:"Not found"
               ())


let handler ~docroot ~index _ req _body =
  let uri = Cohttp.Request.uri req in
  let path = Uri.path uri in
  match Request.meth req with
  | (`GET | `HEAD)  ->
     serve ~docroot ~index uri path
  | `POST ->
     decode_post uri ();
     Server.respond_string ~status:`Method_not_allowed
       ~body:"Changed file" ()
  | _ ->
     Server.respond_string ~status:`Method_not_allowed
       ~body:"Method not allowed" ()



let start_server () =
  let docroot = "../webpage/." in
  let port = 3030 in
  let index = "index.html" in
  let host = "::" in
  let callback = handler ~docroot ~index in
  let config = Server.make ~callback () in
  let mode = `TCP (`Port port) in
  Conduit_lwt_unix.init ~src:host ()
  >>= fun ctx -> let ctx = Cohttp_lwt_unix.Net.init ~ctx () in
                 Server.create ~ctx ~mode config


open Fswatch
open Lwt

let parse_folder_to_file =
  Sys.argv.(1)
  |> String.split_on_char '/'
  |> List.filter (fun s -> s <> "")
  |> List.rev
  |> List.tl
  |> List.rev
  |> String.concat "/"



let rec listen msgBox=
  Lwt_mvar.take msgBox >>= fun events->
  Array.iter (fun event->
    check_if_specific_file_mod (Event.t_to_string event))
    events;
  flush stdout;
  listen msgBox

let source_updates ()=
  match init_library () with
  | Status.FSW_OK->
    let handle, msgBox= Fswatch_lwt.init_session Monitor.System_default in
    add_path handle (String.concat "" ["./"; parse_folder_to_file]);
    async (Fswatch_lwt.start_monitor handle);
    listen msgBox
  | err-> Lwt_io.eprintf "%s\n" (Status.t_to_string err)

let data_updates () = 
  match init_library () with
  | Status.FSW_OK->
    let handle, msgBox= Fswatch_lwt.init_session Monitor.System_default in
    add_path handle "./../webpage/js/.";
    async (Fswatch_lwt.start_monitor handle);
    listen msgBox
  | err-> Lwt_io.eprintf "%s\n" (Status.t_to_string err)


let () =
  print_endline "Server running, listening on port 3030 for HTTP requests\n http://127.0.0.1:3030\n";
  let _ = Sys.command (String.concat "" ["mi "; Sys.argv.(1);" > ../webpage/js/data-source.json "]) in
  Lwt_main.run (start_server () <&> source_updates () <&> data_updates ())

