

function render() {
    fetch('js/data-source.json')
	.then(response => response.text())
	.then((data) => {
	    console.log(data);
	    let data_models = JSON.parse(data);
	     if (data_models.models) {
	const root = document.body.querySelector("#app");
	// Maps over all models in the generated output.
    
	data_models.models.map((model, idx) => {
        // Creates a root element for the model and add it to the root of the application.
            let modelRoot = document.createElement(`div`);
            modelRoot.className = "container";
            root.appendChild(modelRoot);
        // Creates the controller for the specified model if the type is supported.
        switch (model.type) {
        case "dfa":
        case "nfa":
            new NFAController(model, modelRoot, idx);
            break;
        case "digraph":
        case "graph":
        case "tree":
            new GraphController(model, modelRoot, idx);
            break;
        default:
            modelRoot.innerHTML = `<div class="warning">Unsopported model type</div>`;
            break;
        }
    })
} else {
    console.log(data_models);
    var paragraph = document.getElementById("error-container");
    paragraph.textContent += data_models;
}
	})

   
}

render()



function checkFlag() {
    const http = new XMLHttpRequest();
    const url='/js/flag.json';
    http.open("GET", url);
    http.onreadystatechange = (e) => {
	const response = http.responseText;
	try{
	const parsedJSON = JSON.parse(response);
	if(parsedJSON.modifiedByTheServer == 1){
	    location.reload();
	    http.open("POST", url, true);
	    http.send("{\"modifiedByTheServer\":0}");
	}
	}
	catch (e){}
    };
    http.send();

}

var i = setInterval(() => checkFlag() , 1500);

