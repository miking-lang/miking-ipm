class NFAView {
    /**
     * This class is responsible for displaying the NFA view.
     * Includes render methods, and getters for elements in the DOM tree.
     * 
     * @param {NFAModel} model The model including the data used in this view.
     * @param {div} modelRoot The root element of the view.
     * @param {function} interactionCallback The callback function called, when interacting with the
     *                                    graphviz graph.
     */
    constructor(model, modelRoot, dotModel, interactionCallback, simulationCallback){
        this.model = model
        this.modelRoot = modelRoot
        this.dotModel = dotModel
        this.interactionCallback = () => interactionCallback(this.getNodes())
        this.simulationCallback = simulationCallback
        this.initView()

        // Add the view as an observer to the model.
        model.addObserver(() => this.update())
    }
    
    /**
     * Renders the DOM tree of the graph view including 
     */
    initView() {
        this.modelRoot.innerHTML=`
            <div class="title-container"></div>
            <div class="control-panel-container"></div>
            <div class="status-container"></div>
            <div class="model-container"></div>`
        this.update()
    }
    /**
     * Updates the DOM tree with the current values of the model.
     */
    update() {
        TitleRender(
            this.modelRoot.firstElementChild, 
            "uppercase", 
            this.model.getType())
        ControlPanelRender(
            this.modelRoot.firstElementChild.nextElementSibling, 
            this.model.isAtStartState(), 
            this.model.simulationIsFinished(),
            () => this.model.nextState(),
            () => this.model.previousState())
        StatusContainerRender(
            this.modelRoot.firstElementChild.nextElementSibling.nextElementSibling,
            this.model.getInfoStatusAndText(),
            this.model.input,
            idx => this.model.isCurrentInputIndex(idx))

        ModelRender(
            this.modelRoot.lastElementChild, 
            this.model.getDot(), 
            this.interactionCallback,
            this.simulationCallback)
    }
    
    /*              GETTERS               */
    /**
     * Gets the nodes of the graph.
     */
    getNodes() {
        return d3.selectAll("."+this.model.getName()+"-node")
    }
}
