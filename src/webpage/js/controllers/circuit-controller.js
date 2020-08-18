class CircuitController {
    /**
     * Controller class for the Graph view.
     * 
     * @param {object} model An object representing a model.
     * @param {div} modelRoot The root element of the view.
     */
    constructor(model, modelRoot){
        let circuitModel = new Model(model.id, model.type, model.model)

        // Defining the callback function called when the simulation buttons is pressed
        const simulationCallback = d => {
            //console.log(d)

            /*if (d.attributes.class != undefined && d.attributes.class.includes("resistor")){
                console.log("yey")
                let node = d.children.find(x => {
                    return x.tag === "ellipse"
                })
                
                node.attributes.fill = "red"
                node.tag  = "rect"
                console.log(node)
            }
            else if (d.attributes.class != undefined && d.attributes.class.includes("battery")){
                console.log("yey")
                let node = d.children.find(x => {
                    return x.tag === "ellipse"
                })
                node.attributes.fill = "green"
            }*/
        }

        this.modelView = new ModelView(
            circuitModel,
            () => {},
            simulationCallback
        )
        this.modelView.init(modelRoot)
    }

    
}