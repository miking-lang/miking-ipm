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
     * Returns the status of whether the simulation has finished or not.
     * True if the simulations is at the last state, false otherwise.
     */
    simulationIsFinished = () => {
        return this.currentTransition >= input.length-1
    }

    /**
     * Updates the visualizationModel to the next state and notifies the observers of the model.
     */
    getNextState = () => {
        if (this.simulationIsFinished()) {
            this.currentTransition=-1
            this.visualizationModel.initState()
        } else {
            this.currentTransition++
            this.visualizationModel.updateState(this.input[this.currentTransition])
        }
        this.notifyObservers()
    }

    /*              GETTERS               */

    /**
     * Gets the current active node.
     */
    getAvailableColors = () => {
        return this.colors
    }
}