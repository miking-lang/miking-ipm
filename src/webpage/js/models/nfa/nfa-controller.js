class NFAController {
    /**
     * Controller class for the NFA view.
     * 
     * @param {object} model An object representing a model.
     * @param {div} modelRoot The root element of the view.
     * @param {int} index A unique model number.
     */
    constructor(model, modelRoot, index){
        let nfaModel = new NFAModel(new NFA(model.model, model.type, index), model.simulation)

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
    }
}