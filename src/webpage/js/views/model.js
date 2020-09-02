/**
 * This class is responsible for visualizing the model.
 * Renders the DOM tree of the model. 
 */
class ModelView {
    /**
     * @param {string} dot The model in dot format.
     * @param {function} interactionCallback The callback function called, when interacting with the model.
     * @param {function} simulationCallback The callback function called, when pressing the simulation buttons.
     */
    constructor(model, interactionCallback, simulationCallback) {
        this.model = model
        this.interactionCallback = interactionCallback
        this.simulationCallback = simulationCallback
    }
    /**
     * Renders the DOM tree of the model view including 
     */
    init(root) {
        this.root = root
        let className = ["dfa","nfa"].includes(this.model.getType()) ? "uppercase" : "capitalize"
        root.innerHTML=`
            <h3 class="${className}">${this.model.getType()}</h3>
            <div></div>`
        this.render()
    }

    /**
     * Renders the model at the last element in the doom tree.
     */
    render() {
        d3.select(this.root.lastElementChild)
            .graphviz({zoom: false})
            .attributer(this.simulationCallback)
            .renderDot(this.model.getDot())
            .on("end", this.interactionCallback)
    }

    /*              GETTERS               */
    /**
     * Gets the edges of the model.
     */
    getEdges() {
        return d3.selectAll(".model"+this.model.getID()+"edge")
    }

    /**
     * Gets the nodes of the model.
     */
    getNodes() {
        return d3.selectAll(".model"+this.model.getID()+"node")
    }
}