class ApplicationModel {
    /**
     * This class is responsible for the data and the current state of the application.
     * 
     * @param {object} visualizationModel Valid types: DFA
     * @param {[string]} input An array of strings, each representing a transition.
     */
    constructor(visualizationModel, input, activeStates){
        this.visualizationModel = visualizationModel
        this.input = input
        this.activeStates = activeStates
        this.currentStateIndex = 0
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
     * Updates the visualizationModel to the next state and notifies the observers of the model.
     */
    nextState() {
        this.currentStateIndex = this.simulationIsFinished() 
                                    ? 0 
                                    : this.currentStateIndex+=1
        this.inputWasNotAccepted() || this.transitionWasDenied()
            ? this.visualizationModel.setNodeColorToWarningByID(this.getPreviousNodeID())
            : this.visualizationModel.makeTransition(this.getActiveNodeID(), this.getPreviousNodeID())
        this.notifyObservers()
    }

    /**
     * Updates the visualizationModel to the previous state and notifies the observers of the model.
     */
    previousState() {
        this.currentStateIndex = this.isAtStartState()
                                    ? 0 
                                    : this.currentStateIndex-=1
        this.visualizationModel.makeTransition(this.getActiveNodeID(), this.getPreviousNodeID())
        this.notifyObservers()
    }


    /*             STATE GETTERS            */
    /**
     * Checks whether a given transition index is equal to the current transition or not.
     * @param {int} index The index of the transition to compare.
     */
    isCurrentTranistionIndex(index) {
        return index === this.currentStateIndex-1
    }

    /**
     * Returs whether the current state is the start state of the execution or not.
     */
    isAtStartState() {
        return this.currentStateIndex === 0
    }

    /**
     * Returns whether the input is accepted or not.
     */
    isLastStateAndNotAccepted() {
        return this.simulationIsFinished() && !this.visualizationModel.isAcceptedState(this.getActiveNodeID())
    }

    /**
     * Returns whether the input was accepted by the DFA or not.
     */
    inputWasAccepted() {
        return this.simulationIsFinished()
    }

    /**
     * Returns whether the input was rejected by the DFA or not.
     */
    inputWasNotAccepted() {
        return this.getActiveNodeID() === "not accepted"
    }

    /**
     * Returns the status of whether the simulation has finished or not.
     * True if the simulations is at the last state, false otherwise.
     */
    simulationIsFinished() {
        return this.currentStateIndex >= this.activeStates.length-1
    }

    /**
     * Returns whether the current transition was denied by the DFA or not.
     */
    transitionWasDenied() {
        return this.getActiveNodeID() === "denied"
    }


    /*              GETTERS               */
    /**
     * Gets the active state ID.
     */
    getActiveNodeID() {
        return this.activeStates[this.currentStateIndex]
    }

    /**
     * Gets the previous state ID.
     */
    getPreviousNodeID() {
        return this.activeStates[this.currentStateIndex-1]
    }
}