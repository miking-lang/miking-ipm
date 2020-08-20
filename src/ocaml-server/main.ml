open Lwt.Infix
open Cohttp_lwt_unix
open Websocket

let modified = ref true
let visualize = ref ""
let no_file = ref false
let port = ref 3030
let message = ref ""

let path_to_ipm =
  try Sys.getenv "MI_IPM"
  with Not_found -> prerr_endline "The environment variable MI_IPM must be set before running the server"; exit 1

let contains s1 s2 =
  let re = Str.regexp_string s2 in
  try ignore (Str.search_forward re s1 0); true
  with Not_found -> false

let check_if_specific_file_mod event =
  let file_name = !visualize
                  |> String.split_on_char '/'
                  |> List.filter (fun s -> s <> "")
                  |> List.rev
                  |> List.hd
  in
  if contains event "Updated" && contains event file_name then
    modified := true

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
           modified := true;
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

let rec read_all input_stream output =
  try
    let line = input_line input_stream in
    read_all input_stream (String.concat "" [output; line])
  with End_of_file ->
    close_in input_stream;
    output


let handler ~docroot ~index (_ch ,_conn) req _body =
  let uri = Cohttp.Request.uri req in
  let path =  Uri.path uri in
  match Request.meth req with
  | (`GET | `HEAD) ->
     begin
       match path with
       | "/ws" ->
          Cohttp_lwt.Body.drain_body _body >>= fun () ->
          Websocket_cohttp_lwt.upgrade_connection
            req (fun _ -> ()) >>= fun (response, send_func) ->
          let rec refresh () =
            if !modified = true then
              begin
                if not !no_file then
                  begin
                    modified := false;
                    let stream = Unix.open_process_in (String.concat "" ["mi "; !visualize;]) in
                    let msg =  read_all stream "" in
                    Lwt.wrap1 send_func @@
                      Some (Frame.create ~content:msg ());
                    >>= fun () ->
                    Lwt_unix.sleep 0. >>=
                      refresh
                  end
                else
                  begin
                    Lwt_unix.sleep 0. >>=
                      refresh
                  end
              end
            else
              Lwt_unix.sleep 1. >>=
                refresh
          in
          Lwt.async refresh;
          Lwt.return response
       | _ ->
          serve ~docroot ~index uri path >|= fun resp ->
          `Response resp
     end
  | `POST ->
     if contains (Uri.to_string uri) "js/data-source.json" then
       begin
         modified := true;
         Cohttp_lwt.Body.to_string _body >|= (fun msg ->
           message := msg;
           let oc = open_out (String.concat "" [path_to_ipm; "/src/webpage/js/data-source.json "]) in
           Printf.fprintf oc "%s" msg;
           close_out oc;
         )
         >>= (fun _ -> Server.respond_string ~status:`OK
                         ~body:"POST request accepted" ())
         >|= fun resp -> `Response resp
       end
     else
       Server.respond_string ~status:`Method_not_allowed ~body:"No such file or directory" ()
       >|= fun resp -> `Response resp


  | _ ->
     Server.respond_string ~status:`Method_not_allowed
       ~body:"Method not allowed" () >|= fun resp ->
     `Response resp

let start_server port () =
  print_endline (String.concat "" ["Server running, listening on port "; (string_of_int port); " for HTTP requests\n http://127.0.0.1:"; string_of_int port]);
  let docroot = (String.concat "" [ path_to_ipm; "/src/webpage/."]) in
  let index = "index.html" in
  let callback = handler ~docroot ~index in
  Cohttp_lwt_unix.Server.create ~mode:(`TCP (`Port port))
    (Cohttp_lwt_unix.Server.make_response_action
       ~callback ())


open Fswatch
open Lwt

let parse_folder_to_file () =
  !visualize
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
     add_path handle (String.concat "" ["./"; parse_folder_to_file ()]);
     async (Fswatch_lwt.start_monitor handle);
     listen msgBox
  | err-> Lwt_io.eprintf "%s\n" (Status.t_to_string err)


exception PortInUseException of string

let () =
  let speclist = [
      "--no-file", Arg.Set(no_file), "\t Enables POST receive for compiled models";
      "-p", Arg.Set_int(port), "<int> \t Enables user defined port. Defaults to 3030.";
      "--help",Arg.Unit(fun () -> ()),"\t Display this list of options";
      "-help",Arg.Unit(fun () -> ()),"\t Display this list of options";
    ] in
  let anon_fun arg = visualize := arg in
  let usage_msg = "Usage: ipm-server <file> \n\nOptions:" in
  Arg.parse speclist anon_fun usage_msg;
  if !visualize = "" && not !no_file then
    Arg.usage speclist usage_msg
  else
    begin
      if not !no_file then
        begin
          Lwt_main.run (Lwt.pick [source_updates ();
                                  Lwt.catch
                                    (fun () -> start_server !port ())
                                    (function
                                     | Unix.Unix_error(Unix.EADDRINUSE, _, _) -> Lwt.fail (PortInUseException (String.concat "" ["Error: Port "; (string_of_int !port); " already in use. Run the same command again with a different port. " ]))
                                     | _ as e -> Lwt.fail e)])
        end
      else
        Lwt_main.run (Lwt.catch
                        (fun () -> start_server !port ())
                        (function
                         | Unix.Unix_error(Unix.EADDRINUSE, _, _) -> Lwt.fail (PortInUseException (String.concat "" ["Error: Port "; (string_of_int !port); " already in use. Run the same command again with a different port. " ]))
                         | _ as e -> Lwt.fail e))
    end



