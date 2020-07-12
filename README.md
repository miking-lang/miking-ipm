
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
install the following Node package using NPM (Node Package Manager): browser-sync.
Install it in the root directory of the project.

	npm install browser-sync


This is how you would write your DFA:

Starting State:

	let startState = X_i

States:

	let states = [X_1,X_2,X_3,...]

Labels:

	let alfabeth = [L_1, L_2,..]

Transitions:

	let transitions = [(X_i,X_j,L_h),...]

Accepted States:

	let acceptStates = [X_i,X_j,...]
	
To visualize the DFA in action, please write your input in the form of an array of labels as follows:

	let input = [L_1,L_1,L_2,L_1,...]
	
There are no data type requirements for states or labels (X and L in the above examples), thus you would need to write 2 functions for each of them: one equal function that gets 2 inputs and returns either **true** or **false**(true if the two states/labels are equal and false otherwise) and another **2string** function that returns a string that represents the type you are modelling. 

* For example, if your states were integers, you could do:

		let eqv = lam s1. lam s2.
			eqi s1 s2
			
		let state2string = lam s.
			int2string s
			
			

To construct a DFA use this function:

	let your_dfa = dfaConstr states transitions alfabeth startState acceptStates eqv eql state2string label2string

To create the visualizer, make sure to use either of this two:

	let visual = dfaVisualNoInput your_dfa in
	print visual

or if you want to see the input:

	let visual = dfaVisual your_dfa input in
	print visual

You can start the server for watching your file using this command and sourcing your **.mc** file (this would be if your file is in the root directory of the project):

	node src/visual/boot.js path/to/your_file.mc

This will prompt you to the port on your localhost on which the server is started, now if you modify and save the dfa, it should generate a file called **data-source.js** and reflect the update in the browser immediately. The generated file will appear in the src/visual/webpage directory.

### Example

There is a **test.mc** in the root folder of the project which already contains a DFA as a starting point. If you want to write your own, make sure to source the **gen.mc** properly:

	include "path/to/gen.mc"

##### TO DO:

- Handling errors on display
- Generic data-types for labels and states
- Method for the next button to check input
- Instead of passing transitions, pass the an array of states
- Handling wrong input on not-allowed transitions (something like "this is not an accepted transition input")
- Ocaml server
- Extending the input from an array of strings to an array of tuples
- Planning on how to get modifications from the browser to the source-file
- Adding more modelling subjects (electric circuits, tree structures, directed/undirected graphs)


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
