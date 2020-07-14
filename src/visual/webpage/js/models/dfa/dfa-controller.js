class DFAController {
    /**
     * Controller class for the DFA view.
     * 
     * @param {ApplicationModel} model 
     * @param {<div>} root 
     */
    constructor(model, modelRoot, modelName){
        let dfaModel = new DFAModel(new DFA(model.model, modelName), model.simulation)

        // Defining the callback function, which is called when the graph is rendered.
        const callbackFunction = nodes =>
            /*      TEMPORARY -->   */
            // Adds on click event listeners to each of the nodes.
            nodes.on("click", function () {
                let id = d3.select(this).attr("id")
                console.log(dfaModel.visualizationModel.getStateByID(id))
            })
            /* < -- TEMPORARY       */

        this.dfaView = new DFAView(dfaModel, modelRoot, callbackFunction)
        
        // Add event listeners
        this.dfaView.controlPanelView.getNextButton().addEventListener("click", () => dfaModel.nextState())
        this.dfaView.controlPanelView.getPreviousButton().addEventListener("click", () => dfaModel.previousState())
    }
}