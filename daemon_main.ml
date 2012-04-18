(*
 * Copyright (C) Citrix Systems Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *)

(* A helper method for processing requests. *)
let xmlrpc_handler process req bio context =
	let body = Http_svr.read_body req bio in
	let s = Buf_io.fd_of bio in
	let rpc = Xmlrpc.call_of_string body in
	try
		let result = process context rpc in
		let str = Xmlrpc.string_of_response result in
		Http_svr.response_str req s str
	with e ->
		Printf.printf "Caught %s" (Printexc.to_string e);
		Printf.printf "Backtrace: %s" (Printexc.get_backtrace ());
		Http_svr.response_unauthorised ~req (Printf.sprintf "Go away: %s" (Printexc.to_string e)) s

(* Bind the service interface to the server implementation. *)
module Server = Daemon_interface.Server(Daemon_server)

(* Full path to the file descriptor. *)
let fd_path = Filename.concat Fhs.vardir Daemon_interface.name

(* Bind server to the file descriptor. *)
let start fd_path process =
	let server = Http_svr.Server.empty () in
	Http_svr.Server.add_handler server Http.Post "/" (Http_svr.BufIO (xmlrpc_handler process));
	Unixext.mkdir_safe (Filename.dirname fd_path) 0o700;
	Unixext.unlink_safe fd_path;
	let domain_sock = Http_svr.bind (Unix.ADDR_UNIX(fd_path)) "unix_rpc" in
	Http_svr.start server domain_sock;
	(* Only needed when binding the HTTP server to localhost. *)
	(*
	let localhost = Unix.inet_addr_of_string "127.0.0.1" in
	let localhost_sock = Http_svr.bind (Unix.ADDR_INET(localhost, 4094)) "inet-RPC" in
	Http_svr.start server localhost_sock;
	*)
	()

(* Entry point. *)
let _ =
	print_endline "daemon_main: START";

	print_endline "daemon_main: processing arguments ..";
	let pidfile = ref "" in
	let daemonize = ref false in
	Arg.parse (Arg.align [
			"-daemon", Arg.Set daemonize, "Create a daemon";
			"-pidfile", Arg.Set_string pidfile, Printf.sprintf "Set the pid file (default \"%s\")" !pidfile;
		])
		(fun _ -> failwith "Invalid argument")
		(Printf.sprintf "Usage: %s [-daemon] [-pidfile filename]" Daemon_interface.name);
	print_endline "daemon_main: arguments processed.";

	if !daemonize then begin
		print_endline "daemon_main: daemonizing ..";
		Unixext.daemonize ()
	end else begin
		print_endline "daemon_main: not daemonizing ..";
	end;

	if !pidfile <> "" then begin
		print_endline "daemon_main: storing process id into specified file ..";
		Unixext.mkdir_rec (Filename.dirname !pidfile) 0o755;
		Unixext.pidfile_write !pidfile;
	end;

	print_endline "daemon_main: starting server ..";
	start fd_path Server.process;

	while true do
		Thread.delay 300.
	done;

	print_endline "daemon_main: END"
