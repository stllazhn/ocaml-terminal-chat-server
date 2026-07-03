

# OCaml Terminal Chat Server

This is an OCaml command-line chat application built with Lwt. It supports running as either a server or a client. Multiple clients can connect to the server and send messages that are broadcast to the other connected clients.

## Features

- Runs in server mode or client mode
- Uses TCP connections for client/server communication
- Supports multiple connected clients
- Broadcasts messages from one client to all connected clients
- Uses Lwt for asynchronous input/output
- Prints connection and disconnection messages on the server side
- Lets each client send messages with a username label

## Tech Stack

- OCaml
- Dune
- Lwt
- lwt_ppx
- Unix networking

## Project Structure

```text
ocaml-terminal-chat-server/
├── README.md
├── .gitignore
├── dune-project
├── A7.opam
├── dune
├── bin/
│   ├── dune
│   └── main.ml
├── lib/
│   └── dune
└── gitlog.txt
```

## How to Run

Make sure you have OCaml, Dune, and Lwt installed.

First, build the project:

```bash
dune build
```

## Start the Server

Open one terminal window and run:

```bash
dune exec bin/main.exe server 127.0.0.1 9000
```

This starts a chat server on local host using port `9000`.

## Start a Client

Open a second terminal window and run:

```bash
dune exec bin/main.exe client 127.0.0.1 9000 Alice
```

Open a third terminal window and run:

```bash
dune exec bin/main.exe client 127.0.0.1 9000 Bob
```

Now Alice and Bob can send messages through the server.

## Usage Format

Server mode:

```bash
dune exec bin/main.exe server ip port
```

Client mode:

```bash
dune exec bin/main.exe client ip port username
```

Example:

```bash
dune exec bin/main.exe server 127.0.0.1 9000
dune exec bin/main.exe client 127.0.0.1 9000 Stella
```

## Example Behavior

When a client connects, the server prints a connection message.

The client receives a connection number:

```text
I am connection number 1.
```

When a client sends a message, it is sent with the username label:

```text
[Alice]: hello everyone
```

Other connected clients receive the message through the server.
