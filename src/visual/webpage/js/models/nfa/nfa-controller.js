class NFAController {
    /**
     * Controller class for the NFA view.
     * 
     * @param {ApplicationModel} model 
     * @param {<div>} root 
     * @param {int} index A unique model number.
     */
    constructor(model, modelRoot, index){
        let nfaModel = new NFAModel(new NFA(model.model, model.type === "dfa", model.type+index), model.simulation)

        // Defining the callback function, which is called when the graph is rendered.
        const callbackFunction = nodes =>
            /*      TEMPORARY -->   */
            // Adds on click event listeners to each of the nodes.
            nodes.on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(nfaModel.visualizationModel.getStateByName(name))
            })
            /* < -- TEMPORARY       */

        this.nfaView = new NFAView(nfaModel, modelRoot, callbackFunction)
        
        // Add event listeners
        this.nfaView.controlPanelView.getNextButton().addEventListener("click", () => nfaModel.nextState())
        this.nfaView.controlPanelView.getPreviousButton().addEventListener("click", () => nfaModel.previousState())
    }
}