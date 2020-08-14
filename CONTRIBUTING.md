# Contributing

This document is meant to better describe the architecture of this
project, thus making it easier for other developers to jump in
and understand how this piece of software works.

## The server

The server uses **cohttp** and **websocket** as the main two modules for
communicating with the client. All the files are served via HTTP through 
cohttp with a basic HTTP Request flow:

1. The client connects to the server and asks for index.html with a
GET request.

2. The server serves the file over HTTP and then the client asks for 
further files declared in index.html the same way. Only HTTP GET 
request are happening here.

3. For modelling data transfers, the server also open a websocket
that the client connects to, thus making it easy for transfers
even when the client does not create a request.
NOTE: Only the modelling data is transfered through the websocket
The websocket is located on the relative path **/ws**.

4. Furthermore, the server has two main options: one in which no
source file is required (thus waiting for the model through HTTP POST)
and the one in which it compiles the source file given as an 
argument.
	One of two options is chosen when executing the command to run the
	server: --no-file for listening to HTTP POST or /path/to/file.mc 
	for the server compiling the MCore source file.
	
5. In the second case, when a file is also given as an argument,
the server is running two main threads: the server itself and one
for listening to file updates. The module used for the second one 
is **fswatch**, a OS-agnostic module that creates events whenever
a file within the specified directory has updates (modifications,
creation, deletion, etc).

## The file watcher

1. The file watcher process is first decoding the relative path
to the directory containing the specified file, as it can only 
listen to a directory, not to a single file.

2. The events that arise in that specific directory are then 
decoded to decide if they contain the keywords "Updated" and
the file name.

3. If they do, the only thing that the file-watcher process
does is to update an internal flag that is then used in the
server process to send the updates through the websocket,
finally resetting the flag.

## Rest API
