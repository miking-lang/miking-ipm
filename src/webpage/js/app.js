

function render() {
    fetch('js/data-source.json')
	.then(response => response.text())
	.then((data) => {
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
    document.getElementById("error-container").textContent += data_models;
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
	    let flag = (response == 'true');
	    if (flag) {
	    location.reload();
	    http.open("POST", url, true);
	    http.send("false");
	}
	}
	catch (e){}
    };
    http.send();

}

var i = setInterval(() => checkFlag() , 1500);

