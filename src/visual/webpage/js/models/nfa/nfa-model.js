class NFAModel {
    /**
     * This class is responsible for the data and the current state of a NFA.
     * 
     * @param {object} visualizationModel Valid types: NFA (DFA)
     * @param {[string]} input An array of strings, each representing a transition.
     */
    constructor(visualizationModel, simulation){
        this.visualizationModel = visualizationModel
        this.input = simulation.input
        this.configurations = simulation.configurations
        this.currentConfigurationIndex = 0
        this.callbacks = []
        this.updateNFA()
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
        this.updateNFA()
    }

    /**
     * Updates the visualizationModel to the previous configuration and notifies 
     * the observers of the model.
     */
    previousState() {
        this.currentConfigurationIndex = this.isAtStartState() 
                                            ? 0 
                                            : this.currentConfigurationIndex-=1
        this.updateNFA()
    }

    /**
     * Updates the NFA according to the current configuration.
     */
    updateNFA() {
        let activeColor = this.inputWasNotAccepted() || this.nfaGotStuck() ? 
                        "danger"
                    : this.nfaBranchGotStuck() ?
                        "warning"
                    :   "active"
        this.visualizationModel.makeTransition(this.getActiveStateName(), this.getPreviousStateName(), activeColor)
        this.notifyObservers()
    }

    /**
     * Translates the NFA object to dot syntax.
     * @returns {string} The NFA object in dot syntax.
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
        return index === this.configurations[this.currentConfigurationIndex].index
    }

    /**
     * Returns whether the current state is the start configuration of the execution or not.
     */
    isAtStartState() {
        return this.currentConfigurationIndex === 0
    }

    /**
     * Returns whether the input was accepted by the NFA or not.
     */
    inputWasAccepted() {
        return this.simulationIsFinished() && this.getConfigurationStatus() === 1
    }

    /**
     * Returns whether the input was rejected by the NFA or not.
     */
    inputWasNotAccepted() {
        return this.simulationIsFinished() && this.getConfigurationStatus() === -2
    }

    /**
     * Returns whether the NFA is stuck or not.
     */
    nfaGotStuck() {
        return this.simulationIsFinished() && this.nfaBranchGotStuck()
    }

    /**
     * Returns whether the NFA is stuck at the current branch.
     */
    nfaBranchGotStuck() {
        return this.getConfigurationStatus() === -1
    }

    /**
     * Returns the status of whether the simulation has finished or not.
     * True if the simulations is at the last state, false otherwise.
     */
    simulationIsFinished() {
        return this.currentConfigurationIndex >= this.configurations.length-1
    }


    /*              GETTERS               */
    /**
     * Gets the active state name.
     */
    getActiveStateName() {
        return this.configurations[this.currentConfigurationIndex].state
    }

    /**
     * Gets the status of the current configuration.
     */
    getConfigurationStatus() {
        return this.configurations[this.currentConfigurationIndex].status
    }

    /**
     * Gets the status and text for the current model configuration.
     */
    getInfoStatusAndText() {
        let automata = this.visualizationModel.type==="dfa" ? "DFA" : "NFA"
        return this.inputWasNotAccepted() ?
            {status: "danger", text: `Not accepted: The given input string was not accepted by the ${automata}.</span>`}
        : this.nfaGotStuck() ?
            {status: "danger", text: `Not accepted: The automata is stuck in the current state.</span>`}
        : this.inputWasAccepted() ?
            {status: "accepted", text: `The input was accepted by the ${automata}.</span>`}
        : this.nfaBranchGotStuck() ?
            {status: "warning", text: `This branch is stuck at the current branch. Click next to trace back to the branching state.</span>`}
        : null
    }

    /**
     * Gets the previous state name.
     */
    getPreviousStateName() {
        return this.configurations[this.currentConfigurationIndex-1] ? this.configurations[this.currentConfigurationIndex-1].state : undefined
    }

    /**
     * Gets the type of the visualization model.
     */
    getType() {
        return this.visualizationModel.type
    }
}