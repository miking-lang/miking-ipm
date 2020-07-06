// Checks for an existing DFA and input object in the generated source file.
if (inputModel instanceof DFA && input) {
    const model = new ApplicationModel(inputModel, input)
    new ControlPanelController(model, document.body.querySelector("#controlPanelContainer"))
    new GraphController(model, document.body.querySelector("#graphContainer"))
} else {
    /*      TEMPORARY -->   */
    console.error("Error: Something is missing in the source file! See README.md for how use this package.")
    /* < -- TEMPORARY       */
}