class ApplicationModel {
    /**
     * This class is responsible for the data and the current state of the application.
     * 
     * @param {object} visualizationModel Valid types: DFA
     * @param {[string]} input An array of strings, each representing a transition.
     */
    constructor(visualizationModel, input){
        this.visualizationModel = visualizationModel
        this.input = input
        this.currentTransition = -1
        this.callbacks = []
        this.colors = [
            {label: "Green", value: "green"},
            {label: "Blue",  value: "blue"},
            {label: "Red",   value: "red"}
        ]
        this.setActiveNodeColor(this.colors[0].value)
    }

    /**
     * Adds a callback function, executed when the model is changed.
     * @param {function} callback The callback function to add.
     */
    addObserver = callback => {
       this.callbacks.push(callback)
    }

    /**
     * Notifies the observers of the model.
     */
    notifyObservers = () => {
       this.callbacks.map(callback => callback())
    }

    /**
     * Sets the active color of the visualization model to the given value. 
     * @param {string} to The color to set. Possible values are defined in this.colors.
     *                    This methods expects the "value" parameter.
     */
    setActiveNodeColor = to => {
        this.visualizationModel.setActiveNodeColor(to)
        this.notifyObservers()
    }

    /**
     * Checks whether if a given transition index is equal to the current transition.
     * @param {int} index The index of the transition to compare.
     */
    isCurrentTranistionIndex = index => 
        index === this.currentTransition

    /**
     * Returns the status of whether the simulation has finished or not.
     * True if the simulations is at the last state, false otherwise.
     */
    simulationIsFinished = () =>
        this.currentTransition >= input.length-1

    /*              GETTERS               */
    /**
     * Gets the available node colors.
     */
    getAvailableColors = () =>
        this.colors
        
    /**
     * Updates the visualizationModel to the next state and notifies the observers of the model.
     */
    getNextState = () => {
        // TEMPORARY CODE
        if (this.simulationIsFinished()) {
            this.currentTransition=-1
            this.visualizationModel.makeTransition(this.visualizationModel.startNodeID)
        } else {
            this.currentTransition++
            this.visualizationModel.updateState(this.input[this.currentTransition])
        }
        this.notifyObservers()
        //
    }
}