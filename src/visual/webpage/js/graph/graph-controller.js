class GraphController {
    /**
     * Controller class for the Graph view.
     * 
     * @param {ApplicationModel} model 
     * @param {<div>} root 
     */
    constructor(model, root){
        this.graphView = new GraphView(model, root)

        // Defining the callback function, which is called when the graph is rendered.
        const interactive = () =>
            /*      TEMPORARY -->   */
            // Adds on click event listeners to each of the nodes.
            this.graphView.getNodes().on("click", function () {
                let id = d3.select(this).attr("id")
                console.log(id)
            });
            /* < -- TEMPORARY       */
        
        // Render the graph view and add a model observer.
        this.graphView.update(interactive)
        model.addObserver(()=>this.graphView.update(interactive))
    }
}