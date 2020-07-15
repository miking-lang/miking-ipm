/**
 * This class acts as a model for NFA. It contains methods for 
 * manipulating the object.
 */
class NFA {
    /**
     * @param {object} model Contains the NFA model. Includes acceptedIDs, startID, nodes
     *                       and transitions.
     * @param {string} type The type of NFA. (NFA/DFA)
     * @param {int} index A unique model number.
     */
    constructor(model, type, index) {
        this.type = type
        this.name = type+index
        // Sets the render direction. Allowed values: TB, BT, RL, LR.
        this.rankDirection = "LR"
        // Used for general node settings. See: https://graphviz.org/documentation/ 
        // for allowed values.
        this.stateSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}
        this.colors = {active: "green", white: "white", black:"black", warning:"red3"}
        this.startStateName = model.startID
        this.acceptedStates = model.acceptedIDs
        // Init states
        this.states = model.states.map(state => {
            state.settings = state.settings 
                                ? state.settings : {}
            if (this.isAcceptedState(state.name))
                state.settings.shape = "doublecircle"
            return state
        })
        // Init transitions
        this.transitions = model.transitions.map(transition => {
            transition.fontcolor = this.colors.black
            return transition
        })
    }

    /**
     * Returns whether the given state name belongs to one of the accepted states
     * of the NFA or not.
     * @param {string} stateName The state name to check.
     */
    isAcceptedState(stateName) {
        return this.acceptedStates.includes(stateName)
    }

    /**
     * Translates the given object to a space separated string.
     * @param {object} attributes An object with attributes of primitive type.
     * @returns {string} The translated string.
     */
    objectToString(attributes) { 
        return Object.keys(attributes).map(key =>
            `${key} = ${attributes[key]}`
        ).join(" ")
    }
        
    /**
     * Translates the NFA object to dot syntax.
     * @returns {string} The NFA object in dot syntax.
     */
    toDot() { 
        return `digraph {
            rankdir=${this.rankDirection}
            node [${this.objectToString(this.stateSettings)}]
            start [fontcolor = white color = white class="start-node"]
            ${this.states.map(state =>
                `${state.name} [id=${state.name} class="${this.name}-node" ${this.objectToString(state.settings)}]`
            ).join("\n")}
            start -> ${this.startStateName} [label="start"]
            ${this.transitions.map(transition =>
                `${transition.from} -> ${transition.to} [label="${transition.label}" fontcolor=${transition.fontcolor} color=${transition.color}]`
            ).join("\n")}
        }`
    }

    /**
     * Updates the state of the NFA by changing the active state and coloring 
     * states and transitions.
     * @param {string} activeStateID The id of the state to be visualized as active.
     * @param {string} previousStateID The id of the previous state.
     * @param {boolean} warning Whether to set the node color to warning or not.
     */
    makeTransition(activeStateID, previousStateID, warning) {
        this.states.map(State => {
            State.settings.fillcolor = activeStateID === State.name
                                       ? warning ? this.colors.warning : this.colors.active
                                       : this.colors.white
            State.settings.fontcolor = activeStateID === State.name
                                       ? this.colors.white
                                       : this.colors.black
        })
        this.updateTransitionsColor(activeStateID, previousStateID)
    }

    /**
     * Updates the colors of the transitions. Colors the previous transition to 
     * the active color.
     * @param {string} activeStateID The id of the active state.
     * @param {string} previousStateID The id of the previous state.
     */
    updateTransitionsColor(activeStateID, previousStateID) {
        this.transitions.map(transition => {
            let isPreviousTransition = transition.from === previousStateID && transition.to === activeStateID
            
            transition.color = isPreviousTransition
                                ? this.colors.active
                                : this.colors.black
            transition.fontcolor = isPreviousTransition
                                ? this.colors.active
                                : this.colors.black
        })
    }

    /*              GETTERS               */
    /**
     * Gets a NFA state by name.
     */
    getStateByName(name) {
        return this.states.find(state => state.name === name)
    }
}