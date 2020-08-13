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
                console.log(name)
            })
            /* < -- TEMPORARY       */

        const simulationCallback = d => {
            let simulationState = nfaModel.getSimulationState()
            let basicFilter = elem => !elem.tag.includes("text") && elem.tag !== "title"
            if (d.attributes.class === "node" && d.key === simulationState.node) {
                d.attributes.fill = "white"
                d.children.filter(x => basicFilter(x))
                    .map(x => x.attributes.fill = simulationState.color)

            } else if (d.attributes.class === "edge" && d.key === simulationState.edge) {
                d.attributes.fill = simulationState.color
                let edgeParts = d.children.filter(x => basicFilter(x))
                edgeParts.map(x => x.attributes.stroke = simulationState.color)
                edgeParts.filter(x => x.tag !== "path")
                    .map(x => x.attributes.fill = simulationState.color)
            }
        }
        this.nfaView = new NFAView(nfaModel, modelRoot, model.model, interactionCallback, simulationCallback)
    }
}