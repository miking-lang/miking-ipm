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
        this.colors = {active: "green", white: "white", black:"black", warning:"yellow4", danger:"red3"}
        this.startStateName = model.startState
        this.acceptedStates = model.acceptedStates
        // Init states
        this.states = model.states.map(state => {
            state.settings = state.settings 
                                ? state.settings : {}
            if (this.acceptedStates.includes(state.name))
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
     * Translates the NFA object to dot syntax.
     * @returns {string} The NFA object in dot syntax.
     */
    toDot() { 
        // Translates the given object to a space separated string.
        const objectToString = attributes => Object.keys(attributes).map(key => `${key} = ${attributes[key]}`).join(" ")
        return `digraph {
            rankdir=${this.rankDirection}
            node [${objectToString(this.stateSettings)}]
            start [fontcolor = white color = white class="start-node"]
            ${this.states.map(state =>
                `${state.name} [id=${state.name} class="${this.name}-node" label="${state.displayName}" ${objectToString(state.settings)}]`
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
     * @param {string} activeStateName The name of the state to be visualized as active.
     * @param {string} previousStateName The name of the previous state.
     * @param {boolean} activeColor The color for the active node.
     * @param {boolean} colorPreviousEdge Whether to color the previous edge or not.
     */
    makeTransition(activeStateName, previousStateName, activeColor, colorPreviousEdge) {
        this.states.map(State => {
            State.settings.fillcolor = activeStateName === State.name
                                       ? this.colors[activeColor]
                                       : this.colors.white
            State.settings.fontcolor = activeStateName === State.name
                                       ? this.colors.white
                                       : this.colors.black
        })
        this.transitions.map(transition => {
            let isPreviousTransition = transition.from === previousStateName && transition.to === activeStateName
            transition.color = isPreviousTransition && colorPreviousEdge
                                ? this.colors[activeColor]
                                : this.colors.black
            transition.fontcolor = isPreviousTransition && colorPreviousEdge
                                ? this.colors[activeColor]
                                : this.colors.black
        })
    }

    /*              GETTERS               */
    /**
     * Gets a nfa state by name.
     */
    getStateByName(name) {
        return this.states.find(node => node.name === name)
    }
}