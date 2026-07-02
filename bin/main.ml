(** @author Juanru(Stella) Zhang (jz766) *)

let clients : (Lwt_io.input_channel * Lwt_io.output_channel) list ref = ref []

let string_of_addr = function
  | Unix.ADDR_UNIX s -> s
  | ADDR_INET (ip, port) ->
      Printf.sprintf "%s:%d" (Unix.string_of_inet_addr ip) port

let counter = ref 0

let error_handler error_message client_in client_out =
  let%lwt () = Lwt_io.printl error_message in
  clients := List.filter 
  (fun (inn, out) -> inn != client_in && out != client_out) !clients;
  Lwt.return () 

let rec process_messages client_in client_addr client_out =
  try%lwt
  let%lwt message = Lwt_io.read_line client_in in
  let%lwt () = Lwt_io.printlf "Client from %s sent a message: %s" 
  (string_of_addr client_addr) message in
  let%lwt () = Lwt_list.iter_p (fun (other_in, other_out) -> Lwt.catch 
  (fun () -> Lwt_io.write_line other_out message) 
  (fun _ -> Lwt.return())) !clients
  in process_messages client_in client_addr client_out
  with
  | exn -> 
    let%lwt () = error_handler (string_of_addr client_addr ^ 
    ": An exception has occured: " ^ Printexc.to_string exn) 
    client_in client_out in 
    let%lwt () = Lwt_io.printlf "Client from %s disconnected." 
    (string_of_addr client_addr) in 
    Lwt.return ()

let client_handler client_addr (client_in, client_out) : unit Lwt.t =
  incr counter;
  let c = !counter in
  clients := (!clients) @ [(client_in, client_out)];
  let address_string = string_of_addr client_addr in
  let%lwt () = Lwt_io.printlf "I got a connection from %s." address_string in
  let%lwt () = Lwt_io.flush Lwt_io.stdout in
  let%lwt () = Lwt_io.fprintlf client_out "I am connection number %d." c in
  let%lwt () = Lwt_io.flush client_out in
  process_messages client_in client_addr client_out

let run_server ip port =
  let server () =
    let%lwt () = Lwt_io.printlf "I am the server." in
    let%lwt running_server =
      Lwt_io.establish_server_with_client_address 
      (Unix.ADDR_INET (Unix.inet_addr_of_string ip, port)) client_handler
    in
    let (never_resolved : unit Lwt.t), _unused_resolver = Lwt.wait () in
    never_resolved
  in
  Lwt_main.run (server ())

let run_client ip user_name port =
  let client () =
    let%lwt () = Lwt_io.printlf "I am client %s." user_name in
    let%lwt server_in, server_out = Lwt_io.open_connection 
    (Unix.ADDR_INET (Unix.inet_addr_of_string ip, port)) in
    let%lwt () = Lwt_io.printlf "I have connected to the server" in
    let rec receive_message () =
      let%lwt message = Lwt_io.read_line server_in in
      let%lwt () = Lwt_io.printl message in receive_message ()
    in Lwt.async (fun () -> receive_message ()); 
    let%lwt () = Lwt_io.write_line server_out (user_name^" joined the chat") in
    let%lwt () = Lwt_io.flush server_out in
    let rec send_message () =
      let%lwt message = Lwt_io.read_line Lwt_io.stdin in
        let output_message = "[" ^ user_name ^ "]: " ^ message in
        let%lwt () = Lwt_io.write_line server_out output_message in
        let%lwt () = Lwt_io.flush server_out in send_message ()
        in send_message ()
    in Lwt_main.run (client ())

let _ =
  let print_usage () =
    Printf.printf "Usage: %s <server | client>\n" Sys.argv.(0)
  in
  let argv : string list = Array.to_list Sys.argv in
  if List.length argv != 4 && List.length argv != 5 then print_usage ()
  else if (List.nth argv 1) = "server" || (List.nth argv 1) = "client" then
    try 
    match Sys.argv.(1) with
    | "server" -> run_server (List.nth argv 2) 
    (int_of_string (List.nth argv 3))
    | "client" -> run_client (List.nth argv 2) (List.nth argv 4) 
    (int_of_string (List.nth argv 3))
    | _ -> print_usage ()
  with
  | exn -> print_endline ("Exception occurred: " ^ Printexc.to_string exn)
  else print_endline "Please ensure you entered valid inputs. The input 
  format are as follows: dune exec bin/main.exe server ip port OR 
  dune exec bin/main.exe client ip port client_name"

