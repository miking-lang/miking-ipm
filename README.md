
# The Miking Interactive Programmatic Modeling (IPM) Environment

The goals of the Miking IPM project are to:

* Build a complete interactive programmatic modeling (IPM) environment,
  where code and textual models can be edited in any text editor, and
  where the models are visualized using a web browser.

* Support model visualization, including, but not limited to:
automata (NFA, DFA), timed automata, tree structures, directed and
undirected graphs, and electrical circuits.

* Support parameter settings in the generated models, which are fed
  back to the Miking environment.

* Enabled interactions with the execution of models (state changes).
 
* Provide a server that watches file updates and acts as a local web server.

* Create an integration with markdown converters, where the visualized
  models can be used in Latex environments and on static web pages.

# Getting Started

Before you can start visualizing your models inside a web browser, you need to
install Dune and the following OCaml packages using **opam**: cohttp-lwt-unix, fswatch_lwt and fswatch.
You can use this command to install the OCaml packages:

	opam install dune cohttp-lwt-unix fswatch_lwt fswatch websocket-lwt-unix

** Note: mac users might need to install fswatch with homebrew first:

	brew install fswatch


If you are using an old opam version, use the following commands to update it:

	opam update
	opam upgrade

You need to source the path to the IPM root folder as an environment variable:

	export MI_IPM=/path/to/ipm

For example, if you are in the IPM root folder, use this command
	
	export MI_IPM=$(pwd)

To install the server, execute:

	make install

To run the server, execute:

	ipm-server /path/to/file [optional: -p <int> (for port number)]
	
Note: you need to source **src/models/modelVisualizer.mc** in your source file.
	
# Models

This environment supports the datatypes of type _model_. The model type extends the functions already available in the datatypes to be able to visualize them.

This includes:
* Circuit

	`Circuit (Data, fig_settings)`

* Deterministic finite automaton (DFA)

    `DFA (Data, input, node2str, label2str, direction, vSettings)`

* Nondeterministic finite automaton (NFA)

    `NFA (Data, input, node2str, label2str, direction, vSettings)`

* Directed graph (Digraph)

    `Digraph (Data, node2str, label2str,    direction, vSettings)`
    
* Graph

    `Graph (Data,  node2str, label2str,     direction, vSettings)`
    
* Binary tree (BTree)

    `BTree (Data,node2str,                  direction, vSettings)`

The arguments for the constructors are:

- **Data:** data of type (DFA/NFA/Digraph/Graph/BTree).

- **fig_settings:** custom drawing settings for a specific component type. The fig_settings are defined by a sequence of tuples `(a,b,c)`, where `a` is the component type that is used in the model, `b` is a string of space separated graphviz settings (ex: `b = "label="battery" color=green"`) and `c` is the unit for the component value (ex: `c = "V"`). 

- **(input):** a input list containing input.

- **node2str** and **label2str:**  **toString** functions that return a string that represents the type you are modelling. 

- **direction:** Defines the render direction. Takes one of the following values: "TB", "RL", "BT", "LR".

- **vSettings:** There is an option to customize the nodes when visualizing any of the datatypes (not circuits atm). The extra settings names are defined by a sequence of tuples `(a,b)`, where `a` is the name of the node that is used in the model and `b` itself is a sequence of tuples with graphviz settings. Ex `b = [("setting","value"),...]`. The different settings could be found in the documentation at <a href="https://graphviz.org/documentation/">graphviz.org</a>. Examples for custom labels could be found below or in the examples directory. If you're not interested in adding any customizes settings, just pass an empty sequence `[]`.

See the datatypes below for examples.
## DFA

The constructor for the DFA takes in seven arguments: 
1. **states:** a list containing the names of of your states. Ex:

	`let states = ["s0","s1","s2"]`

2. **transitions:** a list containing the transitions between states. One transition is represented as a tuple with the structure `(from,to,label)`. Ex:

	`let transitions = [("s0","s1",'1'),("s1","s1",'1'),("s1","s2",'0')]`

4. **start state:** the state that the automaton starts on. Ex:

    `let startState = "s0"`

5. **accepted states:** a list containing the automatons accepted states. Ex:

    `let acceptStates = ["s1"]`

6. **eqv** and 7. **eql** There are no data type requirements, thus you would need to write equality functions for the states (eqv) and the labels (eql). The equality functions take two inputs and returns either **true** if they are equal or **false** if they are not. Ex :

    `let eqv = eqstr`

	`let eql = eqchar`

	`let settings = [("s0",[("label","start state")]),("s3",[("label","accept state")])]`

The construct function is then called by:

    dfaConstr states transitions startState acceptStates eqv eql

To get a `model` containing this DFA, use the model constructor. Ex:

    DFA (my_dfa, "01010", string2string, char2string, "LR", settings)

## NFA
A NFA works the same as a DFA, except for the requirement for all transitions from a state to have unique labels. Just replace "dfa" with "nfa" in the above instructions.

## Digraph
A directed graph contains three different variables:
1. An adjacency map, which maps each vertex to a list of outgoing edges from that vertex. To add nodes or edges to this, two functions can be used:

    `digraphAddVertex v g`

    `digraphAddEdge v1 v2 l g`

    Where v, v1 and v2 are vertices, l is a label for an edge and g is the previous digraph. If you for example want the nodes 'A' and 'B' with a transition with from 'A' to 'B' with label 0, you would write:

	  `digraphAddEdge 'A' 'B' 0 (digraphAddVertex 'B' (digraphAddVertex 'A' g))`

2. **eqv** and 3. **eql:** There are no data type requirements, thus you would need to write equality functions for the nodes (eqv) and the labels (eql). The equality functions take two inputs and returns either **true** if they are equal or **false** if they are not. Ex:

    `let eqv = eqchar`

    `let eql = eqi`

To start, create an empty digraph. This can be done with:
	
    let g = digraphEmpty eqv eql

To get a `model` containing this digraph, use the model constructor. Ex:

    Digraph(g, char2string,int2string,"LR",[])

## Graph
A graph works the same was as the digraph, except that the edges are not directed. Just replace `digraph` with `graph` in the above example.

## BTree
The constructor for the binary tree takes two arguments:

1. **tree**: A binary tree. The tree is constructed of three types:

    `Node  : (a,BTree,BTree)`

    `Leaf  : (a)`
	
    `Nil   : ()`

    Ex:

    `let tree = Node(2, Node(3, Nil (), Leaf 4), Leaf 5)`
2. **eqv**: There is no data type requirements, thus you would need to write an equality function for the nodes. The equality function take two inputs and returns either **true** if they are equal or **false** if they are not.Ex:

    `let eqv = eqi`

The constructor is then called by:

	let tree = btreeConstr tree eqv

To get a `model` containing this digraph, use the model constructor. Ex:

    BTree(tree, int2string,"TB",[(2,[("label","root")])])

## Circuit
The constructor for the circuit takes two arguments:

A circuit is constructed of three types:

- `Component  : (circ_type,name,value,isConnected)`, 
	
	**Circ_type:** A string describing the component type. 
	
	**name:** The name of the component. Of type String.

	**value:** The value of the componant. Of type optional float.

	**isConnected:** False if there is only one wire connected to the component and true if there is two.

-  `Series  : [Component]`,
	
	A list of components which are connected in a series connection. 
	
-  `Parallel   : [Component]`,

	A list of components which are connected in a parallel connection. 

Ex:
	
	let circuit = Parallel [
		Series[
			Component ("ammeter","amp",None(),true),
			Component ("capacitator","c",Some 8.0,true),
			Component ("ground","g",Some 0.0,false)
		],
		Series [
			Component ("battery","V",Some 11.0,true),
			Parallel [
				Component ("resistor","R1",Some 4.0,true),
				Component ("resistor","R2",Some 1.0,true)
			],
			Component ("lamp","lamp1",None(),true)
		]
	]

To get a `model` containing this circuit, use the model constructor. Ex:

    Circuit(circuit,[])

If no settings are defined for a component, the default figure settings will be used. There exist predefined default figure settings for _`battery`_, _`ground`_ and _`resistor`_. The remaing types will be visualized as a circle if no settings are defined.

# Usage
The IPM framework can be used to visualize any data of type _model_. Make sure you source `modelVisualizer.mc` in your file:

    include "path/to/modelVisualizer.mc"

Once you have data that you want to visualize, just call the function `visualize` with a list containing your data. Make sure that the data is of type `model` as the `toString` functions are required. Ex:

    visualize [
      your_dfa,
      your_btree,
      your_graph
    ]

# Graphviz

Functions for writing the datatypes in dot are provided. The graphviz package then provides different ways to use this dot code such as generating pictures with the datatypes (pdf/jpg etc.) or generating latex code. 

## Installation 
Before you can start, you need to install the graphviz package. Follow the instructions on <a href="https://graphviz.org/download/">graphviz.org</a>.

## Generating dot code
Make sure that you include the model.mc file. 

	include "path/to/model.mc"

To write the dot code for some data of type `model`, use one of these commands:

-	`modelPrintDot "YOUR-DATA"`

	Where _"YOUR-DATA"_ data of type `model` as defined above.

- `modelPrintDotSimulateTo "YOUR-DATA" "STEPS"`
	
	Which simulates going through _"STEPS"_ steps of the input (only available for NFA/DFA).

	**Note**: only works for NFA/DFA/BTree

## Drawing graphs with dot
This command creates your new file using the dot code:

	dot  -"YOUR-FILETYPE" "NAME-OF-INPUT-FILE" -o "NAME-OF-OUTPUT-FILE"

The filetype decides the type of file you are going to get. It can for example be -Tjpg. -Tps or -Tpdf. A list of the valid filetypes can be found at <a href="https://graphviz.org/doc/info/output.html">graphviz.org</a>. If you want to take the input directly without a file, the commands can also be piped:

	mi /path/to/source.mc | dot  [-Tjpg | -Tpdf | -Tps] -o /path/to/output

## Latex
To get started you need to install dot2tex. Follow the instructions here: https://dot2tex.readthedocs.io/en/latest/installation_guide.html

There are several different ways to generate latex code, the following are some examples. Visit https://dot2tex.readthedocs.io/en/latest/usage_guide.html#invoking-dot2tex-from-the-command-line for more information.

This command creates a complete latex file: 

	mi /path/to/source.mc | dot2tex > /path/to/output.tex

To create a figure which can be included in a latex document, --figonly can be added to the command:

	mi /path/to/source.mc | dot2tex --figonly > /path/to/output.tex

# Examples

There is a **examples** folder in the root of the project which contains some files as a starting point. If you want to write your own, make sure to source the **modelVisualizer.mc** properly:

	include "path/to/modelVisualizer.mc"

### Circuit with customized components.

	-- create your circuit
	let circuit = Parallel [
		Series[
			Component ("insulator","ins1",Some 8.0,true),
			Component ("defaultSettings","ins2",Some 4.0,false)
		],
		Series [
			Component ("battery","V",Some 11.0,true),
			Component ("resistor","R1",Some 4.0,true),
			Component ("assembly","assembly1",None(),true)
		]
	] in

	-- call function 'visualize' to get visualization code for the circuit
	visualize [
		-- customized circuit
		Circuit(
			circuit,[
				("assembly","shape=assembly label=\\\"\\\"",""),
				("insulator","shape=insulator label=\\\"\\\"","pF")
			]
		)
	]


### DFA with display names.

	mexpr
	let string2string = (lam b. b) in
	let char2string = (lam b. [b]) in

	-- create your DFA
	let states = ["s0","s1","s2","s3"] in
	let transitions = [
	("s0","s1",'1'),
	("s1","s1",'1'),
	("s1","s2",'0'),
	("s2","s1",'1'),
	("s2","s3",'0'),
	("s3","s1",'1')
	] in

	let startState = "s0" in
	let acceptStates = ["s3"] in

	let dfa = dfaConstr states transitions startState acceptStates eqstr eqchar in

	visualize [
		-- accepted by the DFA
		DFA(dfa,"100100",string2string, char2string, "LR",[("s0",[("label","start state")]),
														   ("s3",[("label","accept state")])]),
		-- not accepted by the DFA
		DFA(dfa,"101110",string2string, char2string,"LR",[]),
		-- not accepted by the DFA
		DFA(dfa,"1010001",string2string, char2string,"LR",[])
	]

### DFA/NFA without simulation.

The only difference from the examples above, is that an empty sequence is given as the input parameter.

	visualize [
		DFA(dfa, [], string2string, char2string,"LR",[])
	]


### Different types: digraph and graph

This program displays a digraph and a graph on the same page.

	mexpr
	let string2string = (lam b. b) in
	let char2string = (lam b. [b]) in

	-- create your directed graph
	let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
	(foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in


	-- create your graph
	let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) 
	(foldr graphAddVertex (graphEmpty eqi eqstr) [1,2,3,4]) [(1,2,""),(3,2,""),(1,3,""),(3,4,"")] in

	visualize [
		Digraph(digraph, char2string,int2string,"LR",[]),
		Graph(graph,int2string,string2string,"LR",[])
	]


### Different types: NFA and Binary Tree

This program creates both a NFA and a Binary tree and displays them. 

	mexpr 
	let string2string = (lam x. x) in
  	let char2string = (lam x. [x]) in
	
	let nfaStates = ["a","b","c","d","e","f"] in
	let nfaTransitions = [("a","b",'1'),("b","c",'0'),("c","d",'2'),("c","e",'2'),("d","a",'1'),("e","f",'1')] in
	let nfaStartState = "a" in
	let nfaAcceptStates = ["a"] in
	
	-- create your NFA
	let nfa = nfaConstr nfaStates nfaTransitions nfaStartState nfaAcceptStates eqstr eqchar in


	-- create your Binary Tree
	let btree = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) in
	let btreeSettings = [(2,[("label","Two")]),(3,[("label","Three")]),(4,[("label","Four")]),(5,[("label","Five")])] in

	visualize [
		BTree(btree, int2string,"TB",btreeSettings),
		NFA(nfa, "1021", string2string, char2string,"LR",[]),
		NFA(nfa, "102", string2string, char2string,"LR",[])
	]

## Printing to pdf


The following code creates a directed graph and prints it as dot code. To do the same with any other model object, create your objects the same way as the examples above and call the modelPrintDot function with the object as argument.

	mexpr 
	let char2string = (lam b. [b]) in

	-- create your directed graph
	let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
	(foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in
  
	let digraphModel = Digraph(digraph, char2string,int2string,"LR",[]) in

	modelPrintDot digraphModel

The following command runs the code, which is located in the file "test.mc", and creates a pdf file called "myDigraph.pdf" from the output:

	mi test.mc | dot  -Tpdf -o graph.pdf


## MIT License

Copyright (c) 2020 David Broman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
