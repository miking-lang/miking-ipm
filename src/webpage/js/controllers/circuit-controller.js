class CircuitController {
    /**
     * Controller class for the Graph view.
     * 
     * @param {object} model An object representing a model.
     * @param {div} modelRoot The root element of the view.
     */
    constructor(model, modelRoot){
        let circuitModel = new Model(model.id, model.type, model.model)

        this.modelView = new ModelView(
            circuitModel,
            () => {},
            () => {}
        )
        this.modelView.init(modelRoot)
    }

    
}