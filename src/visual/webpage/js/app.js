// Checks for an existing DFA and input object in the generated source file.
if (inputModel instanceof DFA && input && activeStates) {
    const model = new ApplicationModel(inputModel, input, activeStates)
    new ControlPanelController(model, document.body.querySelector("#control-panel-container"))
    new GraphController(model, document.body.querySelector("#graph-container"))
} else {
    console.log(inputModel);
    var paragraph = document.getElementById("error-container");
    paragraph.textContent += inputModel;
}
