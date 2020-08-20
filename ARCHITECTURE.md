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

The webpage directory consists of the index.html file and and the css and js directories. The css directory simple contains a style.css file which is not necessary but makes the GUI prettier. The js directory consists of a app.js file and the three directories: controllers, models and views. The app.js file acts as the main file of the application and handles the communication between the server. This file also initializes all the necessary objects defined in the other files. A controller, a model and a view is initialized for each model. This means that each model sent from the server is independent from the others on the JS side. 

The controller instance of the model is dependent of the model type. Each controller class defines the simulation and interaction methods. Hence, a new controller class must be created if a new model type with different simulation behavior is created in mcore. If a new model type with simulation is created, make sure to include the configurations attribute as stated in the Rest api below. A model without simulation can simply use the model.js controller which doesn't make use of simulation. The controller instantiates a view and a model object. If the model includes simulation, the controller should make use of the model-simulation view/model, and the model view/model otherwise.

## Rest API
This section describes the interface between the client and the server. This interface is very simple at the moment and handles only one request.

The response to all requests include a data object with one or several models where each model has the following attributes:
- <code>type</code> (string) - Ex: "dfa", "nfa", "graph".
- <code>id</code> (int) - A unique number used for model specific requests.
- <code>model</code> (string) - The model in dot-syntax.
- <code>simulation</code> (object) - An object with simulation information (only included for models with simulation). The JS code expects the simulation object to have the <code>configurations</code> attribute which refers to an array with state specific attributes. The <code>configurations</code> attribute is used in the <code>model-simulation.js</code> file and must be included. The example below gives an idea of what the <code>configurations</code> attribute looks like in the case of a DFA/NFA model.

#### REQUEST - ALL MODELS
The following request retrieves all the models defined in the user-specified <code>.mc</code> file. The models are returned in their initial state. 

<code>GET: BASE_URL + "/all-models"</code> // TO BE CHANGED!!

###### Sample output
```json
{
    "data" : {
		"models": [
			{
				"type" : "digraph",
				"id" : 0,
				"model" :"digraph {rankdir=LR;node [style=filled fillcolor=white shape=circle];
					E[id=\"E\" class=\"model0node\" ];
					D[id=\"D\" class=\"model0node\" ];
					C[id=\"C\" class=\"model0node\" ];
					B[id=\"B\" class=\"model0node\" ];
					A[id=\"A\" class=\"model0node\" ];
					E -> D [label=\"2\" id=\"E2D\" class=\"model0edge\" ];
					C -> E [label=\"5\" id=\"C5E\" class=\"model0edge\" ];
					C -> D [label=\"5\" id=\"C5D\" class=\"model0edge\" ];
					B -> D [label=\"4\" id=\"B4D\" class=\"model0edge\" ];
					B -> C [label=\"2\" id=\"B2C\" class=\"model0edge\" ];
					A -> C [label=\"5\" id=\"A5C\" class=\"model0edge\" ];
					A -> B [label=\"2\" id=\"A2B\" class=\"model0edge\" ];}"
			},
			{
				"type" : "tree",
				"id" : 2,
				"model" :"digraph {rankdir=TB;node [style=filled fillcolor=white shape=circle];
					2[id=\"2\" class=\"model2node\" ];
					3[id=\"3\" class=\"model2node\" ];
					4[id=\"4\" class=\"model2node\" ];
					5[id=\"5\" class=\"model2node\" ];
					2 -> 3 [label=\"\" id=\"23\" class=\"model2edge\" ];
					3 -> 4 [label=\"\" id=\"34\" class=\"model2edge\" ];
					2 -> 5 [label=\"\" id=\"25\" class=\"model2edge\" ];}"
			},
			{
				"type" : "nfa",
				"id" : 3,
				"simulation" : {
					"input" : ["1","0","2"],
					"configurations" : [
						{"state": "a","status": "","index": -1},
						{"state": "b","status": "","index": 0},
						{"state": "c","status": "","index": 1},
						{"state": "d","status": "not accepted","index": 2},
						{"state": "c","status": "","index": 1},
						{"state": "e","status": "not accepted","index": 2}
					]
				},
				"model" :"digraph {rankdir=LR;node [style=filled fillcolor=white shape=circle];
					start[id=\"start\" class=\"model4node\" style=invis];
					a[id=\"a\" class=\"model4node\" shape=doublecircle  ];
					b[id=\"b\" class=\"model4node\"   ];
					c[id=\"c\" class=\"model4node\"   ];
					d[id=\"d\" class=\"model4node\"   ];
					e[id=\"e\" class=\"model4node\"   ];
					f[id=\"f\" class=\"model4node\"   ];
					start -> a [label=\"start\" id=\"startstarta\" class=\"model4edge\" ];
					a -> b [label=\"1\" id=\"a1b\" class=\"model4edge\" ];
					b -> c [label=\"0\" id=\"b0c\" class=\"model4edge\" ];
					c -> d [label=\"2\" id=\"c2d\" class=\"model4edge\" ];
					c -> e [label=\"2\" id=\"c2e\" class=\"model4edge\" ];
					d -> a [label=\"1\" id=\"d1a\" class=\"model4edge\" ];
					e -> f [label=\"1\" id=\"e1f\" class=\"model4edge\" ];}"
			}
		]
	}
}
```
