/**
 * This class is responsible for visualizing the model.
 * Renders the DOM tree of the model. 
 */
class ModelSimulationView {
    /**
     * @param {div} root The root element, defining where to render.
     * @param {ModelSimulation} model The model which is visualizes and simulated.
     * @param {function} interactionCallback The callback function called, when interacting with the model.
     * @param {function} simulationCallback The callback function called, when pressing the simulation buttons.
     */
    constructor(root, model, interactionCallback, simulationCallback) {
        this.root = root
        this.model = model
        this.modelView = new ModelView(model, interactionCallback, simulationCallback)
        this.init()
        this.model.addObserver(() => this.render())
    }

    /**
     * Initializes the DOM tree of the model simulation view.
     */
    init() {
        this.root.innerHTML=`
            <div class="model-container"></div>
            <div class="control-panel-container"></div>
            <div class="status-container"></div>`
        this.modelView.init(this.root.firstElementChild)
        this.render()
    }

    /**
     * Renders the model simulation view.
     */
    render() {
        this.modelView.render()
        this.root.firstElementChild.nextElementSibling.innerHTML = this.model.getStatusContainer()
        let controlPanel = this.root.lastElementChild
        controlPanel.innerHTML = this.model.getControlPanel()
        controlPanel.firstElementChild.nextElementSibling.onclick = () => this.model.previousState()
        controlPanel.lastElementChild.onclick = () => this.model.nextState()
    }

    /*              GETTERS               */
    /**
     * Gets the edges of the model.
     */
    getEdges() {
        return this.modelView.getEdges()
    }

    /**
     * Gets the nodes of the model.
     */
    getNodes() {
        return this.modelView.getNodes()
    }
}