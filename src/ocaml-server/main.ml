open Lwt.Infix
open Cohttp_lwt_unix


type flag = { modified : bool ref}
let file_flag = {modified = ref true}
let visualize = ref ""
let no_file = ref false
let port = ref 3030

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

let method_filter meth (res,body) = match meth with
  | `HEAD -> Lwt.return (res,`Empty)
  | _ -> Lwt.return (res,body)

let check_if_specific_file_mod event =
  let file_name = !visualize
                  |> String.split_on_char '/'
                  |> List.filter (fun s -> s <> "")
                  |> List.rev
                  |> List.hd
  in
  if contains event "Updated" && contains event file_name then
    ignore @@ Sys.command (String.concat "" ["mi "; !visualize;" > ../webpage/js/data-source.json "]);
  let open Printf in
  let file = "../webpage/js/flag.json" in
  let message = "{\n \t\"modifiedByTheServer\": 1,\n \t \"modifiedByTheClient\": 0\n}" in
  let oc = open_out file in
  fprintf oc "%s\n" message;
  close_out oc;
  (file_flag.modified) := true


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

let handler ~docroot ~index (_ch ,_conn) req _body =
  let uri = Cohttp.Request.uri req in
  let path = Uri.path uri in
  match Request.meth req with
  | (`GET | `HEAD)  ->
     serve ~docroot ~index uri path
  | `POST ->
     if contains (Uri.to_string uri) "js/flag.json" then
       begin
         modify_flag ();
         Server.respond_string ~status:`OK ~body:"POST request accepted" ()
       end
     else if contains (Uri.to_string uri) "js/data-source.json" then
       begin
         Cohttp_lwt.Body.to_string _body >|= (fun msg ->
         let oc = open_out "../webpage/js/data-source.json" in
         Printf.fprintf oc "%s" msg;
         close_out oc;
       )
         >>= (fun _ -> Server.respond_string ~status:`OK
                         ~body:"POST request accepted" ())
       end
     else
       Server.respond_string ~status:`Method_not_allowed ~body:"No such file or directory" ()

  | _ ->
     Server.respond_string ~status:`Method_not_allowed
       ~body:"Method not allowed" ()


exception Invalid_input

let start_server port () =
  print_endline (String.concat "" ["Server running, listening on port "; (string_of_int port); " for HTTP requests\n http://127.0.0.1:"; string_of_int port]);
  (* Cohttp_lwt_unix.Debug.activate_debug (); *)
  let docroot = "../webpage/." in
  let index = "index.html" in
  let host = "::" in
  let callback = handler ~docroot ~index in
  let config = Server.make ~callback () in
  Conduit_lwt_unix.init ~src:host ()
  >>= fun ctx -> let ctx = Cohttp_lwt_unix.Net.init ~ctx () in
                 Server.create ~ctx ~mode:(`TCP (`Port port)) config

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


exception PortInUseException of string

let () =
  let speclist = [
      "--no-file", Arg.Set(no_file), "Enables the server to run without a file";
      "-p", Arg.Set_int(port), "Enable port choices.";
    ] in
  let anon_fun arg = visualize := arg in
  let usage_msg = "Usage: either --no-file for client sending POST data or give full path to a source file. \n Note: one of them is mandatory!" in
  Arg.parse speclist anon_fun usage_msg;
  if !visualize = "" && not !no_file then
    Arg.usage speclist usage_msg
  else
    begin
      if not !no_file then
        begin

          ignore @@ Sys.command (String.concat "" ["mi "; !visualize ;" > ../webpage/js/data-source.json "]);
          Lwt_main.run (Lwt.pick [source_updates ();
                                  Lwt.catch
                                    (fun () -> start_server !port ())
                                    (function
                                     | _ -> Lwt.fail (PortInUseException (String.concat "" ["Error: Port "; (string_of_int !port); " already in use. Run the same command again with a different port. " ])))])
        end
      else
        ignore @@ Sys.command " > ../webpage/js/data-source.json ";
      Lwt_main.run (Lwt.catch
                      (fun () -> start_server !port ())
                      (function
                       | _ -> Lwt.fail (PortInUseException (String.concat "" ["Error: Port "; (string_of_int !port); " already in use. Run the same command again with a different port. " ]))))
    end

