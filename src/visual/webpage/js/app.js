// Checks for existing models object in the generated source file.
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