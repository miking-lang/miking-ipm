

function render() {
  
  
  
    if (data && data.models) {
	const root = document.body.querySelector("#app")
	// Maps over all models in the generated output.
    
	data.models.map((model, idx) => {
        // Creates a root element for the model and add it to the root of the application.
        let modelRoot = document.createElement(`div`)
        modelRoot.className = "container"
        root.appendChild(modelRoot)
        // Creates the controller for the specified model if the type is supported.
        switch (model.type) {
        case "dfa":
        case "nfa":
            new NFAController(model, modelRoot, idx)
            break;
        case "digraph":
        case "graph":
        case "tree":
            new GraphController(model, modelRoot, idx)
            break;
        default:
            modelRoot.innerHTML = `<div class="warning">Unsopported model type</div>`
            break;
        }
    })
} else {
    console.log(data);
    var paragraph = document.getElementById("error-container");
    paragraph.textContent += data;
}
}

render()



function checkFlag() {
    const http = new XMLHttpRequest();
    const url='http://localhost:3030/js/flag.json';
    http.open("GET", url);
    http.setRequestHeader("Access-Control-Allow-Origin", "*");
    http.send();
    http.onreadystatechange = (e) => {
	const response = http.responseText;
	console.log(response);
	try{
	const parsedJSON = JSON.parse(response);
	if(parsedJSON.flag == 1){
	    location.reload();
	    http.open("POST", url, true);
	    http.send("{\"flag\":0}");
	}
	}
	catch (e){
	    console.log(e);
	}
    }
}

var i = setInterval("checkFlag();", 1500);

