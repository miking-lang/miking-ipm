class DFAModel {
    /**
     * This class is responsible for the data and the current state of a DFA.
     * 
     * @param {object} visualizationModel Valid types: DFA
     * @param {[string]} input An array of strings, each representing a transition.
     */
    constructor(visualizationModel, simulation){
        this.visualizationModel = visualizationModel
        this.input = simulation.input
        this.configurations = simulation.configurations
        this.status = simulation.state
        this.currentConfigurationIndex = 0
        this.callbacks = []
        this.updateDFA()
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
        this.updateDFA()
    }

    /**
     * Updates the visualizationModel to the previous configuration and notifies 
     * the observers of the model.
     */
    previousState() {
        this.currentConfigurationIndex = this.isAtStartState() 
                                            ? 0 
                                            : this.currentConfigurationIndex-=1
        this.updateDFA()
    }

    /**
     * Updates the DFA according to the current configuration.
     */
    updateDFA() {
        let warning = this.inputWasNotAccepted() || this.dfaGotStuck()
        this.visualizationModel.makeTransition(this.getActiveStateID(), this.getPreviousStateID(), warning)
        this.notifyObservers()
    }

    /**
     * Translates the DFA object to dot syntax.
     * @returns {string} The DFA object in dot syntax.
     */
    toDot() {
        return this.visualizationModel.toDot()
    }

    /*             STATE GETTERS            */
    /**
     * Checks whether a given index is equal to the current input index or not.
     * @param {int} index The index of the input to compare.
     */
    isCurrentInputIndex(index) {
        return index === this.currentConfigurationIndex-1
    }

    /**
     * Returns whether the current state is the start configuration of the execution or not.
     */
    isAtStartState() {
        return this.currentConfigurationIndex === 0
    }

    /**
     * Returns whether the input was accepted by the DFA or not.
     */
    inputWasAccepted() {
        return this.simulationIsFinished() && this.status === "accepted"
    }

    /**
     * Returns whether the input was rejected by the DFA or not.
     */
    inputWasNotAccepted() {
        return this.simulationIsFinished() && this.status === "not accepted"
    }

    /**
     * Returns the status of whether the simulation has finished or not.
     * True if the simulations is at the last state, false otherwise.
     */
    simulationIsFinished() {
        return this.currentConfigurationIndex >= this.configurations.length-1
    }

    /**
     * Returns whether the DFA is stuck or not.
     */
    dfaGotStuck() {
        return this.simulationIsFinished() && this.status === "stuck"
    }


    /*              GETTERS               */
    /**
     * Gets the active configuration ID.
     */
    getActiveStateID() {
        return this.configurations[this.currentConfigurationIndex]
    }

    /**
     * Gets the status and text for the current model configuration.
     */
    getInfoStatusAndText() {
        return this.inputWasNotAccepted() ?
            {status: "warning", text: "Not accepted: The given input string was not accepted by the DFA.</span>"}
        : this.dfaGotStuck() ?
            {status: "warning", text: "Not accepted: The DFA is stuck in the current state.</span>"}
        : this.inputWasAccepted() ?
            {status: "accepted", text: "The input was accepted by the DFA</span>"}
        :   null
    }

    /**
     * Gets the previous configuration ID.
     */
    getPreviousStateID() {
        return this.configurations[this.currentConfigurationIndex-1]
    }
}