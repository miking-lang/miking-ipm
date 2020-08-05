
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


### Getting Started

Before you can start visualizing your models inside a web browser, you need to
install the following OCaml packages using **opam**: cohttp-lwt-unix, fswatch_lwt fswatch and str.
You can use this command to install them all:

	opam install cohttp-lwt-unix fswatch_lwt fswatch

You can start the server for watching your file using this command and sourcing your **.mc** file (this would be if your file is in the root directory of the project):
	
	cd src/ocaml-server/
	dune exec ./main.exe path/to/source.mc

This will prompt you to the port on your localhost on which the server is started, now if you modify and save the file which contains your models, it should generate a file called **data-source.js** and reflect the update in the browser immediately. The generated file will appear in the src/visual/webpage directory.

## Data types

This environment supports the datatypes of type _model_. Right now this includes:
* DFA
* NFA
* Directed graph
* Graph
* Binary tree

## This is how you would write your DFA:

Starting State:

	let startState = "s0"

States:

	let states = ["s0","s1","s2"]

Labels:

	let alfabeth = ['0','1']

Transitions:

	let transitions = [("s0","s1",'1'),("s1","s1",'1'),("s1","s2",'0')]

Accepted States:

	let acceptStates = ["s1"]
	
To visualize the DFA in action, please write your input in the form of an array of labels as follows:

	let input = "11"
	
There are no data type requirements, thus you would need to write equality functions for the states (eqv) and labels (eql) (X and L in the above examples). The equality functions get 2 inputs and returns either **true** or **false** (true if the two states/labels are equal and false otherwise). 

* For example, if your states were integers and your labels were chars, you could do:

		let eqv = setEqual eqchar
		let eql = lam s1. lam s2.
			eqchar s1 s2

To construct a DFA use this function:

	let your_dfa = dfaConstr states transitions
    alfabeth startState acceptStates eqv eql


## This is how you would write your NFA:
A NFA works the same as a DFA, just replace "dfa" with "nfa". The transitions labels do not need to be unique for a state.

## This is how you would write your directed graph:

To start, create an empty digraph. This can be done with:
	
	digraphEmpty eqchar eqi

There are no data type requirements, thus you would need to write equality functions for the vertices (eqv) and labels (eql). The equality functions get 2 inputs and returns either **true** or **false** (true if the two states/labels are equal and false otherwise). 

For example, if your vertices were integers and your labels were charecters, you could do:

	let empty = digraphEmpty eqi eqchar

To add vertexes and edges to the graph use these commands:

	digraphAddVertex v g
	digraphAddEdge v1 v2 l g

Where v, v1 and v2 are vertices, l is a label for an edge and g is the previous digraph. If you for example want the nodes 'A' and 'B' with a transition with from 'A' to 'B' with label 0, you would write:

	digraphAddEdge 'A' 'B' 0 (digraphAddVertex 'B' (digraphAddVertex 'A' empty))

## This is how you would write your graph:
A graph works the same was as the digraph, just replace `digraph` with `graph` in the functions.

## This is how you would write your binary tree:
To create a binary tree the constructor BTree can be used.

	BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) 
	
Here, the main wrapper object would be a BTree to start with. The following can have 3 types: Node, Leaf or Nil. The BTree wraps a Node that has 3 sub-objects, starting with a value and 2 other objects, arbitrary picked from the same 3 above mentioned, in this example, one is another Node and the other is a Leaf.

## Visualizing the data
To visualize any of the types defined above they need to be of type model. **toString**  functions are also required. These **toString** functions returns a string that represents the type you are modelling. For example, if you had a graph with vertices of type integer and labels of type character, the toString methods would be:

		let vertex2string = lam s.
			int2string s
		let label2string = lam s.
			char2string s

There is also the option to define a display name for any of the nodes when visualizing any of the datatypes defined above. These values must be strings, and have no affect on the model other than that when visualized the labels for the states will not be the names used in the model, but the display names. All names used in the model must be unique, but display names do not. The display names are defined by a list of tuples `(a,b)`, where `a` is the name of the node that is used in the model and `b` is the string that will be shown as the label instead. 

** Note: this does not work with file conversion at the moment. 

The model constructors for the types are:

* DFA 

  `DFA(dfa,input, state2string, label2string,displayNames)`
  
* NFA 

  `NFA(nfa,input, state2string, label2string,displayNames)`
  
* Digraph : 
    
	`Digraph(digraph, vertex2string,label2string,displayNames),`
	
* Graph 

  `Graph(graph, vertex2string,label2string,displayNames)`

* BTree

  `BTree (btree,node2string,displayNames)`

To create the visualizer, use this function:

	visualize data

Where `data` is a list of models.

# Creating files with the datatypes
Before you can start converting your models to pdf and other formats, you need to
install the graphviz package. Follow the instructions on <a href="https://graphviz.org/download/">graphviz.org</a>.

Functions for writing the datatypes in dot are provided. Given the dot code, a command can be used to create a file with the datatype. Make sure that you include the model.mc file. 

	include "path/to/model.mc"

To write the dot code for some data of type `model`, use this command:

	modelPrintDot "YOUR-DATA" "RENDER-DIRECTION"

where "RENDER-DIRECTION" takes one of the following values "TB", "RL", "BT", "LR".

This command then creates your new file:

	dot  -"YOUR-FILETYPE" "NAME-OF-INPUT-FILE" -o "NAME-OF-OUTPUT-FILE"

The filetype decides the type of file you are going to get. It can for example be -Tjpg. -Tps or -Tpdf. The input file will in this case be data-source.js. If you want to take the input directly without a file, the commands can also be piped:

	mi "NAME-OF-CODE-FILE.mc" | dot  -"YOUR-FILETYPE" -o "NAME-OF-OUTPUT-FILE"

# Examples

There is a **test.mc** in the root folder of the project which already contains a DFA as a starting point. If you want to write your own, make sure to source the **modelVisualizer.mc** properly:

	include "path/to/modelVisualizer.mc"

### DFA with display names.

	mexpr
	let string2string = (lam b. b) in
	let eqString = setEqual eqchar in
	let char2string = (lam b. [b]) in

	-- create your DFA
	let alfabeth = ['0','1'] in
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

	let dfa = dfaConstr states transitions alfabeth startState acceptStates eqString eqchar in

	visualize [
		-- accepted by the DFA
    DFA(dfa,"10010100",string2string, char2string,[("s0","start state"),("s3","accept state")]),
    -- not accepted by the DFA
    DFA(dfa,"101110",string2string, char2string,[]),
    -- not accepted by the DFA
    DFA(dfa,"1010001",string2string, char2string,[])
	] 


### Different types: digraph and graph

This program displays a digraph and a graph on the same page.

	mexpr
	let string2string = (lam b. b) in
	let eqString = setEqual eqchar in
	let char2string = (lam b. [b]) in

	-- create your directed graph
	let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
	(foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in

	-- create your graph
	let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) 
	(foldr graphAddVertex (graphEmpty eqi eqString) [1,2,3,4]) [(1,2,""),(3,2,""),(1,3,""),(3,4,"")] in

	visualize [
	Digraph(digraph, char2string,int2string,[]),
    Graph(graph,int2string,string2string,[])
	]


### Different types: NFA and Binary Tree

This program creates both a NFA and a Binary tree and displays them. 

	mexpr 
	let string2string = (lam x. x) in
  	let char2string = (lam x. [x]) in
	let eqString = setEqual eqchar in
	
	let nfaAlphabet = ['0','1','2','3'] in
	let nfaStates = ["a","b","c","d","e","f"] in
	let nfaTransitions = [("a","b",'1'),("b","c",'0'),("c","d",'2'),("c","e",'2'),("d","a",'1'),("e","f",'1')] in
	let nfaStartState = "a" in
	let nfaAcceptStates = ["a"] in
	
	-- create your NFA
	let nfa = nfaConstr nfaStates nfaTransitions nfaAlphabet nfaStartState nfaAcceptStates eqString eqchar in


	-- create your Binary Tree
	let btree = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) in

	visualize [
    BTree(btree, int2string,[(2,"Two"),(3,"Three"),(4,"Four"),(5,"Five")],[]),
    NFA(nfa, "1021", string2string, char2string,[]),
    NFA(nfa, "102", string2string, char2string,[])
	]

## Printing to pdf


The following code creates a directed graph and prints it as dot code. To do the same with any other model object, create your objects the same way as the examples above and call the modelPrintDot function with the object as argument.

	mexpr 
	let char2string = (lam b. [b]) in

	-- create your directed graph
	let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
	(foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in
  
	let digraphModel = Digraph(digraph, char2string,int2string,[]) in

	modelPrintDot digraphModel "LR"

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
