class NFAController {
    /**
     * Controller class for the NFA view.
     * 
     * @param {object} model An object representing a model.
     * @param {div} modelRoot The root element of the view.
     */
    constructor(model, modelRoot){
        let nfaModel = new NFAModel(model)

        // Defining the callback function, which is called when the graph is rendered.
        const interactionCallback = nodes =>
            /*      TEMPORARY -->   */
            // Adds on click event listeners to each of the nodes.
            nodes.on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(nfaModel.visualizationModel.getStateByName(name))
            })

        const simulationCallback = d => {
            /*might need to be more general if users can change the shapes of nodes*/
            let simulationState = nfaModel.getSimulationState()
            if (d.key.includes("path") && (d.parent != undefined) && d.parent.key == simulationState.node){
                d.attributes.fill = simulationState.color;
            }
            else if ((d.tag == "path" && d.parent.key == simulationState.edge)){
                d.attributes.stroke = simulationState.color;
            }
            else if (d.tag == "polygon" && d.parent.key == simulationState.edge){
                d.attributes.fill = simulationState.color;
                d.attributes.stroke = simulationState.color;
            }
        }
            /* < -- TEMPORARY       */
        this.nfaView = new NFAView(nfaModel, modelRoot, model.model, interactionCallback, simulationCallback)
    }
}