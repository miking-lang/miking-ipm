class GraphController {
    /**
     * Controller class for the Graph view.
     * 
     * @param {ApplicationModel} model 
     * @param {<div>} root 
     */
    constructor(model, modelRoot, modelName){
        let graphModel = new GraphModel(new Graph(model.model, model.type === "digraph", modelName))
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