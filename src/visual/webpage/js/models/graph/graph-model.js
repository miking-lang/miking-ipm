class GraphModel {
    /**
     * This class is responsible for the data and the current state of a graph.
     * 
     * @param {object} visualizationModel Valid types: Graph
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
     * Translates the DFA object to dot syntax.
     * @returns {string} The DFA object in dot syntax.
     */
    toDot() {
        return this.visualizationModel.toDot()
    }
}