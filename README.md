
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
	
Write your **hello.mc** file and then run either of these commands for your OS:

	build/boot-linux hello.mc
	
	build/boot-macos hello.mc
	
This will create a folder called **webpage** and a file inside it called **index.html**. Your **hello.mc** file is now watched for updates.


### Flow plan:

1. The server listens to changes in the file called **miking-ipm/src/server/model.mc** and will call the parser that transforms the MCore project into an AST and generates a JSON. 

2. The program that reads the JSON and visualizes the state machine is then invoked and that should update the **miking-ipm/src/visual/index.html** file. The browser automatically updates then.

##### Following steps:

Re-create this whole scenario in OCaml in order to decrease dependancies.

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
