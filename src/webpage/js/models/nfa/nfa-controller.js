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
        const interactionCallback = () => {
            // Adds on click event listeners to each of the nodes.
            this.nfaView.getEdges().on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(name)
            })
            this.nfaView.getNodes().on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(name)
            })
        }

        const simulationCallback = d => {
            let simulationState = nfaModel.getSimulationState()
            let basicFilter = elem => !elem.tag.includes("text") && elem.tag !== "title"
            switch (d.key) {
                case simulationState.node:
                    d.attributes.fill = "white"
                    d.children.filter(x => basicFilter(x))
                        .map(x => x.attributes.fill = simulationState.color)
                    break;
                case simulationState.edge:
                    d.attributes.fill = simulationState.color
                    let edgeParts = d.children.filter(x => basicFilter(x))
                    edgeParts.map(x => x.attributes.stroke = simulationState.color)
                    edgeParts.filter(x => x.tag !== "path")
                        .map(x => x.attributes.fill = simulationState.color)
                    break;
            }
        }
        this.nfaView = new NFAView(nfaModel, modelRoot, interactionCallback, simulationCallback)
    }
}