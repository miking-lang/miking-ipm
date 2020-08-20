class ModelSimulation {
    /**
     * This class is responsible for the data of a model.
     * 
     * @param {int} id The model identifier.
     * @param {string} type The modeltype.
     * @param {string} model A model object in dot syntax.
     * @param {[object]} model An array of configurations. The content can take any form but must be controlled 
     *                         in the controller.
     * @param {function} statusContainer A function which returns a html tree, which is visualized in the 
     *                                   status container.
     */
    constructor(id, type, model, configurations, statusContainer){
        this.model = new Model(id, type, model)
        this.configurations = configurations
        this.currentConfigurationIndex = 0
        this.getStatusContainer = () => statusContainer(this.getConfigurationBy(this.currentConfigurationIndex), 
                                                        this.simulationIsFinished())
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
     * Updates the visualizationModel to the next configuration and notifies the 
     * observers of the model.
     */
    nextState() {
        this.currentConfigurationIndex = this.simulationIsFinished() 
                                            ? 0 
                                            : this.currentConfigurationIndex+=1
        this.notifyObservers()
    }

    /**
     * Updates the visualizationModel to the previous configuration and notifies 
     * the observers of the model.
     */
    previousState() {
        this.currentConfigurationIndex = this.isAtStartState() 
                                            ? 0 
                                            : this.currentConfigurationIndex-=1
        this.notifyObservers()
    }

    /*              GETTERS             */
    /**
     * Returns whether the current state is the start configuration of the execution or not.
     */
    isAtStartState() {
        return this.currentConfigurationIndex === 0
    }

    /**
     * Returns the status of whether the simulation has finished or not.
     * True if the simulations is at the last state, false otherwise.
     */
    simulationIsFinished() {
        return this.currentConfigurationIndex >= this.configurations.length-1
    }

    /**
     * Gets the content of the control pandel.
     */
    getControlPanel() {
        return `<span class="simulation-title">Change state:</span>
        <button class="previousButton std-btn" ${this.isAtStartState()?"disabled=true":""}>Previous</button>
        <button class="nextButton std-btn">${this.simulationIsFinished()?`Restart simulation`:`Next`}</button>`
    }

    /**
     * Gets a configuration by index.
     * @param {int} index 
     */
    getConfigurationBy(index) {
        return index < 0 ? null : this.configurations[index]
    }

    /**
     * Gets the current configuration index.
     */
    getCurrentConfigurationIndex() {
        return this.currentConfigurationIndex
    }

    /**
     * Translates the NFA object to dot syntax.
     * @returns {string} The NFA object in dot syntax.
     */
    getDot() {
        return this.model.getDot()
    }

    /**
     * Gets the name of the visualization model.
     */
    getID() {
        return this.model.getID()
    }

    /**
     * Gets the type of the visualization model.
     */
    getType() {
        return this.model.getType()
    }
}