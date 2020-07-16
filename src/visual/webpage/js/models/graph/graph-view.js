class GraphView {
    /**
     * This class is responsible for displaying the graph view.
     * Includes render methods, and getters for elements in the DOM tree.
     * 
     * @param {GraphModel} model The model including the data used in this view.
     * @param {<div>} modelRoot The root element of the view.
     * @param {function} callbackFunction The callback function called, when interacting with the
     *                                    graphviz graph.
     */
    constructor(model, modelRoot, callbackFunction){
        this.model = model
        this.modelRoot = modelRoot
        this.initView() 

        this.modelView = new ModelView(model, modelRoot.lastElementChild, () => callbackFunction(this.getNodes()))
    }
    
    /**
     * Renders the DOM tree of the graph view including 
     */
    initView() {
        this.modelRoot.innerHTML=`<h3 class="capitalize">${this.model.getType()}</h3>
                                  <div></div>`
    }
    
    /*              GETTERS               */
    /**
     * Gets the nodes of the graph.
     */
    getNodes() {
        return d3.selectAll("."+this.model.visualizationModel.name+"-node")
    }
}
