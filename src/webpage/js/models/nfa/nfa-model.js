class NFAModel {
    /**
     * This class is responsible for the data and the current state of a NFA.
     * 
     * @param {object} visualizationModel Valid types: NFA (DFA)
     * @param {[string]} input An array of strings, each representing a transition.
     */
    constructor(model){
        this.input = model.simulation.input
        this.configurations = model.simulation.configurations
        this.model = new Model(model.id, model.type, model.model)
        this.currentConfigurationIndex = 0
        this.simulationState = this.getSimulationState()
        this.updateNFA()
    }

    getSimulationState(){
        let current = this.configurations[this.currentConfigurationIndex].state
        let prev = this.currentConfigurationIndex <= 0 ? "start" : this.configurations[this.currentConfigurationIndex-1].state
        let color = this.inputWasNotAccepted() || this.nfaGotStuck() ? 
                        "red"
                    : this.nfaBranchGotStuck() || this.inputWasNotAcceptedByBranch() ?
                        "yellow"
                    :   "green"
        return {node:current,edge:prev+"->"+current,color: color}
    }

    /**
     * Adds a callback function, executed when the model is changed.
     * @param {function} callback The callback function to add.
     */
    addObserver(callback) {
       this.model.addObserver(callback)
    }

    /**
     * Notifies the observers of the model.
     */
    notifyObservers() {
       this.model.notifyObservers()
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
        this.simulationState = this.getSimulationState()
        this.notifyObservers()
    }

    /**
     * Translates the NFA object to dot syntax.
     * @returns {string} The NFA object in dot syntax.
     */
    getDot() {
        return this.model.getDot()
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
     * Returns whether the simulation is at the last input or not.
     */
    isAtFinalInput() {
        return this.configurations[this.currentConfigurationIndex].index === this.input.length-1
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
        return this.simulationIsFinished() && this.getConfigurationStatus() === "accepted"
    }

    /**
     * Returns whether the input was rejected by the NFA or not.
     */
    inputWasNotAccepted() {
        return this.simulationIsFinished() && this.getConfigurationStatus() === "not accepted"
    }

    /**
     * Returns whether the NFA is stuck or not.
     */
    nfaGotStuck() {
        return this.simulationIsFinished() && this.getConfigurationStatus() === "stuck"
    }

    /**
     * Returns whether the given input was accepted by the current branch or not.
     */
    inputWasNotAcceptedByBranch() {
        return this.getConfigurationStatus() === "stuck"
    }

    /**
     * Returns whether the NFA is stuck at the current branch.
     */
    nfaBranchGotStuck() {
        return this.isAtFinalInput() && this.getConfigurationStatus() === "not accepted"
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
     * Gets the status of the previous configuration.
     */
    getPreviousConfigurationStatus() {
        return this.currentConfigurationIndex > 0
                ? this.configurations[this.currentConfigurationIndex-1].status
                : false
    }

    /**
     * Gets the status and text for the current model configuration.
     */
    getInfoStatusAndText() {
        let automata = this.model.getType() === "dfa" ? "DFA" : "NFA"
        return this.inputWasNotAccepted() ?
            {status: "danger", text: `Not accepted: The given input string is not accepted by the ${automata}.`}
        : this.nfaGotStuck() ?
            {status: "danger", text: `Not accepted: The automata is stuck in the current state.`}
        : this.inputWasAccepted() ?
            {status: "accepted", text: `The input is accepted by the ${automata}.`}
        : this.nfaBranchGotStuck() ?
            {status: "warning", text: `This NFA is stuck at the current state: Out of input. 
                                       Click next to trace back to the branching state.`}
        : this.inputWasNotAcceptedByBranch() ?
            {status: "warning", text: `The NFA is stuck at the current state: No matching outgoing transition. 
                                       Click next to trace back to the branching state.`}
        : null
    }

    /**
     * Gets the previous state name.
     */
    getPreviousStateName() {
        return this.configurations[this.currentConfigurationIndex-1] ? this.configurations[this.currentConfigurationIndex-1].state : undefined
    }

    /**
     * Gets the name of the visualization model.
     */
    getName() {
        return this.model.getName()
    }

    /**
     * Gets the type of the visualization model.
     */
    getType() {
        return this.model.getType()
    }
}