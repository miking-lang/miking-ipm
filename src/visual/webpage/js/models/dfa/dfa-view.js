class DFAView {
    /**
     * This class is responsible for displaying the graph view.
     * Includes render methods, and getters for elements in the DOM tree.
     * 
     * @param {DFAModel} model 
     * @param {<div>} modelRoot 
     */
    constructor(model, modelRoot, callbackFunction){
        this.model = model
        this.modelRoot = modelRoot
        this.initView() 

        this.controlPanelView = new ControlPanelView(model, modelRoot.firstElementChild)
        this.modelView = new ModelView(model, modelRoot.lastElementChild, () => callbackFunction(this.getNodes()))
    }
    
    /**
     * Renders the DOM tree of the graph view including 
     */
    initView() {
        this.modelRoot.innerHTML=`<div></div>
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
