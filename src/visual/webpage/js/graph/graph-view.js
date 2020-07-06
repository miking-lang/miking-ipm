class GraphView {
    /**
     * This class is responsible for displaying the graph view.
     * Includes render methods, and getters for elements in the DOM tree.
     * 
     * @param {ApplicationModel} model 
     * @param {<div>} root 
     */
    constructor(model, root){
        this.root=root
        this.model=model
        this.initView() 
        // Initializes the graphviz object.
        this.graph = d3.select("#graph").graphviz({zoom: false})
    }
    
    /**
     * Renders the DOM tree of the graph view including 
     */
    initView = () => {
        this.root.innerHTML=`<div id="graph"></div>`;
    }

    /**
     * Updates the graphView.
     * @param {function} graphCallback The callback function executed when the graphviz
     *                                 object has finished rendering.
     */
    update = graphCallback => {
        // Renders the visualization object to the graphviz object.
        this.graph.renderDot(this.model.visualizationModel.toDot()).on("end", graphCallback)
    }

    /*              GETTERS               */

    /**
     * Gets the nodes of the graph.
     */
    getNodes = () => {
        return d3.selectAll(".node")
    }
}