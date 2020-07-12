// Checks for existing models object in the generated source file.
if (data && data.models) {
    const root = document.body.querySelector("#app")
    // Maps over all models in the generated output.
    data.models.map(model => {
        // Creates a root element for the model and add it to the root of the application.
        let modelRoot = document.createElement(`div`)
        modelRoot.className = "container"
        root.appendChild(modelRoot)
        // Creates the controller for the specified model if the type is supported.
        if (model.type === "dfa") {
            new DFAController(model, modelRoot)
        } else {
            modelRoot.innerHTML = `<div class="warning">Unsopported model type</div>`
        }
    })
} else {
    document.getElementById("error-container").textContent += data;
}