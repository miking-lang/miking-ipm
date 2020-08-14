# Architecture

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

## File structure
.
├── examples
│  ├── btree.mc
│  ├── dfa.mc
│  ├── digraph.mc
│  ├── graph.mc
│  └── nfa.mc
├── src
│  ├── models
│  │  ├── types
│  │  │  └── btree.mc
│  │  ├── model.mc
│  │  ├── modelDot.mc
│  │  └── modelVisualizer.mc
│  ├── ocaml-server
│  │  ├── _build
│  │  │  ├── .aliases
│  │  │  │  └── default
│  │  │  │     └── .formatted
│  │  │  │        └── fmt-4007ea48347d17ce0d08fb2013fece14
│  │  │  ├── default
│  │  │  │  ├── .dune
│  │  │  │  │  ├── .dune-keep
│  │  │  │  │  ├── configurator
│  │  │  │  │  └── configurator.v2
│  │  │  │  ├── .formatted
│  │  │  │  │  ├── dune
│  │  │  │  │  └── main.ml
│  │  │  │  ├── .main.eobjs
│  │  │  │  │  ├── byte
│  │  │  │  │  │  ├── dune__exe__Main.cmi
│  │  │  │  │  │  ├── dune__exe__Main.cmo
│  │  │  │  │  │  └── dune__exe__Main.cmt
│  │  │  │  │  ├── native
│  │  │  │  │  │  ├── dune__exe__Main.cmx
│  │  │  │  │  │  └── dune__exe__Main.o
│  │  │  │  │  ├── dune__exe__Main.impl.all-deps
│  │  │  │  │  └── main.ml.d
│  │  │  │  ├── .merlin
│  │  │  │  ├── .merlin-exists
│  │  │  │  ├── dune
│  │  │  │  ├── main.exe
│  │  │  │  └── main.ml
│  │  │  ├── .db
│  │  │  ├── .digest-db
│  │  │  ├── .filesystem-clock
│  │  │  ├── .to-delete-in-source-tree
│  │  │  └── log
│  │  ├── .merlin
│  │  ├── dune
│  │  ├── dune-project
│  │  └── main.ml
│  └── webpage
│     ├── css
│     │  └── style.css
│     ├── js
│     │  ├── components
│     │  │  ├── control-panel.js
│     │  │  ├── model.js
│     │  │  ├── status-container.js
│     │  │  └── title.js
│     │  ├── models
│     │  │  ├── graph
│     │  │  │  ├── graph-controller.js
│     │  │  │  ├── graph-model.js
│     │  │  │  ├── graph-view.js
│     │  │  │  └── graph.js
│     │  │  ├── nfa
│     │  │  │  ├── nfa-controller.js
│     │  │  │  ├── nfa-model.js
│     │  │  │  ├── nfa-view.js
│     │  │  │  └── nfa.js
│     │  │  └── dfa.js
│     │  ├── app.js
│     │  ├── data-source.json
│     │  └── data-source.json
│     ├── jsonInterface
│     │  ├── ex.js
│     │  ├── example.json
│     │  └── interface.md
│     └── index.html
├── test
│  ├── test-conv-to-pdf.mc
│  └── test.mc
├── ARCHITECTURE.md
├── LICENSE
├── make
├── Makefile
└── README.md

### Models directory

The file structure is displayed in a tree format above. Every piece of code is written in the subfolder **src/**. 
The modelling and definition of everything is located under **src/models**. There, you can find
the programs that transform your models into JSON objects, as well as the definitions of models under
**src/models/types** (btree.mc for example).
When compiling a source file, the **src/models/modelVisualizer.mc** file should be sourced, thus making
the visualize function from there available. 

### The server directory

The server is located in the **src/ocaml-server/** sub-directory. The server does not need to know anything
about the models, as long as the model declaration file (source-file/test-file) is working properly.
The server knows the path given to the source file as an argument, and then also the path to the webpage
through the environment variable **MI_IPM** set to the root of the directory.

### The webpage directory

The webpage directory is what is sourced in the server to be sent over to the client. Every file in there
can be sent over HTTP to the client, thus there is the code to display the data models, given by the 
output of the function visualize from the above mentioned generator file.

## Rest API
