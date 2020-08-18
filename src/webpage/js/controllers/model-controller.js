class ModelController {
    /**
     * Controller class for the Model view.
     * 
     * @param {object} model An object representing a model.
     * @param {div} modelRoot The root element of the view.
     */
    constructor(inputModel, modelRoot){
        let model = new Model(inputModel.id, inputModel.type, inputModel.model)
        // Defining the callback function, which is called when the model is rendered.
        const interactionCallback = nodes => {
            // Adds on click event listeners to each of the nodes.
            this.modelView.getEdges().on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(name)
            })
            this.modelView.getNodes().on("click", function () {
                let name = d3.select(this).attr("id")
                console.log(name)
            })
        }
        this.modelView = new ModelView(
            model,
            interactionCallback,
            () => {}
        )
        this.modelView.init(modelRoot)
    }
}