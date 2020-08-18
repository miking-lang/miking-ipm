class Model {
    /**
     * This class is responsible for the data of a model.
     * 
     * @param {int} id The model identifier.
     * @param {string} type The modeltype.
     * @param {string} model A string in dot format representing the initial state of the model.
     */
    constructor(id, type, model){
        this.id = id
        this.type = type
        this.dot = model
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
    getID() {
        return this.id
    }

    /**
     * Gets the type of the model.
     */
    getType() {
        return this.type
    }
}