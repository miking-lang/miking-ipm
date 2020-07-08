class ModelView {
    /**
     * This class is responsible for visualizing the model.
     * Includes render methods for the model.
     * 
     * @param {Model} model 
     * @param {<div>} root 
     */
    constructor(model, root, callbackFunction){
        this.root=root
        this.model=model
        this.initView() 
        // Initializes the graphviz object.
        this.graph = d3.select(root.firstElementChild).graphviz({zoom: false})

        // Render the graph view and add a model observer.
        this.update(callbackFunction)
        model.addObserver(()=>this.update(callbackFunction))
    }
    
    /**
     * Renders the DOM tree of the graph view including 
     */

    initView() {
        this.root.innerHTML=`<div class="graph"></div>`
    }

    /**
     * Updates the graphView.
     * @param {function} graphCallback The callback function executed when the graphviz
     *                                 object has finished rendering.
     */
    update(graphCallback) {
        // Renders the visualization object to the graphviz object.
        this.graph.renderDot(this.model.toDot()).on("end", graphCallback)
    }
}
