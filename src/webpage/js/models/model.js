class Model {
    /**
     * This class is responsible for the data of a model.
     * 
     * @param {int} id The model identifier.
     * @param {string} type The modeltype. Valid types: Graph (Digraph, Tree)
     * @param {string} model A string in dot format representing the initial state of the model.
     */
    constructor(id, type, model){
        this.id = id
        this.type = type
        this.dot = model
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
     * Gets the model object to dot syntax.
     * @returns {string} The model object in dot syntax.
     */
    getDot() {
        return this.dot
    }

    /**
     * Gets the name of the model.
     */
    getName() {
        return this.getType()+this.id
    }

    /**
     * Gets the type of the model.
     */
    getType() {
        return this.type
    }
}