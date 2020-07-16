class NFAView {
    /**
     * This class is responsible for displaying the NFA view.
     * Includes render methods, and getters for elements in the DOM tree.
     * 
     * @param {NFAModel} model The model including the data used in this view.
     * @param {<div>} modelRoot The root element of the view.
     * @param {function} callbackFunction The callback function called, when interacting with the
     *                                    graphviz graph.
     */
    constructor(model, modelRoot, callbackFunction){
        this.model = model
        this.modelRoot = modelRoot
        this.initView() 

        this.controlPanelView = new ControlPanelView(model, modelRoot.firstElementChild.nextElementSibling)
        this.modelView = new ModelView(model, modelRoot.lastElementChild, () => callbackFunction(this.getNodes()))
    }
    
    /**
     * Renders the DOM tree of the graph view including 
     */
    initView() {
        this.modelRoot.innerHTML=`<h3 class="uppercase">${this.model.getType()}</h3>
                                  <div></div>
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
