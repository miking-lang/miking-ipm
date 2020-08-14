class NFAController {
    /**
     * Controller class for the NFA view.
     * 
     * @param {object} model An object representing a model.
     * @param {div} modelRoot The root element of the view.
     */
    constructor(model, modelRoot){
        // Defining the callback function called when the graph is rendered.
        const interactionCallback = () => {
            // Adds on click event listeners to each of the nodes.
            this.simulationView.getEdges().on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(name)
            })
            this.simulationView.getNodes().on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(name)
            })
        }

        // Defining the callback function called when the simulation buttons is pressed
        const simulationCallback = d => {
            let configurationIndex = simulationModel.getCurrentConfigurationIndex()
            let current = simulationModel.getConfigurationBy(configurationIndex)
            let prev = configurationIndex <= 0 ? "start" : simulationModel.getConfigurationBy(configurationIndex-1).state
            let color = ["not accepted", "stuck"].includes(current.status) 
                            ? simulationModel.simulationIsFinished()
                                ? "darkred"
                                : "yellow"
                            : "darkgreen"
            let simulationState = {node:current.state,edge:prev+"->"+current.state,color: color}
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

        // This function is responsible for visualizing the status container.
        const nfaStatusContainerCallback = (configuration, simulationIsFinished) => {
            let automata = model.type === "dfa" ? "DFA" : "NFA"
            let info = simulationIsFinished && configuration.status === "not accepted" ?
                {status: "danger", text: `Not accepted: The given input string is not accepted by the ${automata}.`}
            : simulationIsFinished && configuration.status === "stuck" ?
                {status: "danger", text: `Not accepted: The automata is stuck in the current state.`}
            : configuration.status === "accepted" ?
                {status: "accepted", text: `The input is accepted by the ${automata}.`}
            : configuration.status === "not accepted" ?
                {status: "warning", text: `This NFA is stuck at the current state: Out of input. 
                                        Click next to trace back to the branching state.`}
            : configuration.status === "stuck" ?
                {status: "warning", text: `The NFA is stuck at the current state: No matching outgoing transition. 
                                        Click next to trace back to the branching state.`}
            : null
            return `<span>
                    ${model.simulation.input.map((input,idx) =>
                        `<span class="transition ${configuration.index === idx ? "active-transition" : ""}">
                            ${input}
                        </span>`
                    ).join("")}
                    </span>
                    ${info?`<span class="${info.status}">${info.text}</span>`:``}`
        }
        let simulationModel = new ModelSimulation(model.id, model.type, model.model, model.simulation.configurations, 
                                                  nfaStatusContainerCallback)
        this.simulationView = new ModelSimulationView(modelRoot, simulationModel, interactionCallback, simulationCallback)
    }
}