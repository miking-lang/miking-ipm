class GraphView {
    /**
     * This class is responsible for displaying the graph view.
     * Includes render methods, and getters for elements in the DOM tree.
     * 
     * @param {GraphModel} model The model including the data used in this view.
     * @param {div} modelRoot The root element of the view.
     * @param {function} interactionCallback The callback function called, when interacting with the
     *                                    graphviz graph.
     */
    constructor(model, modelRoot, interactionCallback){
        this.model = model
        this.modelRoot = modelRoot
        this.interactionCallback = () => interactionCallback(this.getNodes())
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
            <div class="model-container"></div>`
        this.update()
    }

    /**
     * Updates the DOM tree with the current values of the model.
     */
    update() {
        TitleRender(this.modelRoot.firstElementChild, "capitalize", this.model.getType())
        ModelRender(
            this.modelRoot.lastElementChild, 
            this.model.getDot(), 
            this.interactionCallback,
            () => {})
    }
    
    /*              GETTERS               */
    /**
     * Gets the edges of the graph.
     */
    getEdges() {
        return d3.selectAll(".model"+this.model.getID()+"edge")
    }

    /**
     * Gets the nodes of the graph.
     */
    getNodes() {
        return d3.selectAll(".model"+this.model.getID()+"node")
    }
}
