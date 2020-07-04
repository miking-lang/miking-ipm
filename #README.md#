
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
install the following Node packages using NPM (Node Package Manager): http-server

	npm install -g browser-sync
	
Write your **hello.mc** file and then run this command from inside the main project folder:

	node src/visual/boot.js hello.mc
	
This will create a folder called **webpage** and a file inside it called **index.html**. Your **hello.mc** file is now watched for updates.

**!!! There is one important thing to keep in mind: this project folder should be in the same folder as the __miking__ folder** in order to atuomatically run the **mi** command (run). That is, if you do **ls** you should see both folder

	ls -la
	> miking
	> miking-ipm

This is how you would write your DFA:

Starting State:

	let startState = X_i
	
States:

	let states = [X_1,X_2,X_3,...]
	
Labels (you can use **gensym()** to generate a symbol): 

	let alfabeth = [Symbol_1, Symbol_2,..]
	
Transitions:

	let transitions = [(X_i,X_j,Symbol_h),...]
	
Accepted States:

	let acceptStates = [X_i,X_j,...]
	

### Example

There is a **test.mc** in the root folder of the project which already contains a DFA as a starting point. If you want to write your own, make sure to source the **gen.mc** properly:

	include "path/to/gen.mc"

##### TO DO:

- Fix the label for the input in DFA's
- Re-create this whole scenario in OCaml in order to decrease dependancies.

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
