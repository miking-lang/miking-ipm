class GraphController {
    /**
     * Controller class for the Graph view.
     * 
     * @param {ApplicationModel} model 
     * @param {<div>} root 
     */
    constructor(model, modelRoot, modelName){
        model.model.directed = model.type === "digraph"
        model.model.name = modelName
        let graphModel = new GraphModel(new Graph(model.model))
        // Defining the callback function, which is called when the graph is rendered.
        const callbackFunction = nodes =>
            /*      TEMPORARY -->   */
            // Adds on click event listeners to each of the nodes.
            nodes.on("click", function () {
                let id = d3.select(this).attr("id")
                console.log(graphModel.visualizationModel.getNodeByID(id))
            })
            /* < -- TEMPORARY       */

        this.graphView = new GraphView(graphModel, modelRoot, callbackFunction)
    }
}