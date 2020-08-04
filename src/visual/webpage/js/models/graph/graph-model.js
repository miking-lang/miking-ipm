class GraphModel {
    /**
     * This class is responsible for the data and the current state of a graph.
     * 
     * @param {object} visualizationModel Valid types: Graph (Digraph, Tree)
     */
    constructor(visualizationModel){
        this.visualizationModel = visualizationModel
        this.callbacks = []
    }

    /**
     * Adds a callback function, executed when the model is changed.
     * @param {function} callback The callback function to add.
     */
    addObserver(callback) {
       this.callbacks.push(callback)
    }

    /**
     * Notifies the observers of the model.
     */
    notifyObservers() {
       this.callbacks.map(callback => callback())
    }

    /**
     * Translates the graph object to dot syntax.
     * @returns {string} The graph object in dot syntax.
     */
    toDot() {
        return this.visualizationModel.toDot()
    }

    /**
     * Gets the type of the visualization model.
     */
    getType() {
        return this.visualizationModel.type
    }
}