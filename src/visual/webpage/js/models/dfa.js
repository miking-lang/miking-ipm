/**
 * This class acts as a model for DFA. It contains methods for 
 * manipulating the object.
 */
class DFA {
    /**
     * @param {string} rankDirection Sets the render direction. Allowed values: TB, BT, RL, LR.
     * @param {object} nodeSettings Used for general node settings. See:
     *                              https://graphviz.org/documentation/ for allowed values.
     * @param {[object]} nodes Each node instance requires a name (string), id (string) and a 
     *                         settings (object) property. Node specific attributes are listed 
     *                         as properties of the settings object attribute. 
                               Note: If no extra settings are wanted, pass an empty object for 
                               the settings attribute: "settings: {}".
     * @param {string} startID The ID of the node from where to start the simulation.
     * @param {string} acceptedIDs  The accepting nodes.
     * @param {[object]} transitions Transistions between nodes. Each transition requires the 
     *                               following attributes: from (string), to (string) and 
     *                               label (string).
     */
    constructor(rankDirection = "TB", nodeSettings = {}, nodes = [], startID, acceptedIDs = [], transitions = []) {
        this.rankDirection = rankDirection
        this.nodeSettings = nodeSettings
        this.startNodeID = startID
        this.acceptedIDs = acceptedIDs
        this.colors = {active: "green", white: "white", black:"black", warning:"red3"}
        // Init nodes
        this.nodes = nodes.map(node => {
            node.settings = node.settings 
                                ? node.settings : {}
            if (this.isAcceptedState(node.id))
                node.settings.shape = "doublecircle"
            return node
        })
        // Init transitions
        this.transitions = transitions.map(transition => {
            transition.fontcolor = this.colors.black
            return transition
        })
        this.makeTransition(startID)
    }

    /**
     * Returns whether the given node id belongs to one of the accepted id:s
     * of the DFA or not.
     * @param {string} nodeID The node id to check.
     */
    isAcceptedState(nodeID) {
        return this.acceptedIDs.includes(nodeID)
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
     * Translates the DFA object to dot syntax.
     * @returns {string} The DFA object in dot syntax.
     */
    toDot() { 
        return `digraph {
            rankdir=${this.rankDirection}
            node [${this.objectToString(this.nodeSettings)}]
            start [fontcolor = white color = white class="start-node"]
            ${this.nodes.map(node =>
                `${node.id} [label=${node.label} id=${node.id} class="dfa-node" ${node.settings ? this.objectToString(node.settings):""}]`
            ).join("\n")}
            start -> ${this.startNodeID} [label="start"]
            ${this.transitions.map(transition =>
                `${transition.from} -> ${transition.to} [label=${transition.label} fontcolor=${transition.fontcolor} color=${transition.color}]`
            ).join("\n")}
        }`
    }

    /**
     * Updates the state of the DFA by changing the active node and coloring 
     * nodes and transitions.
     * @param {string} activeNodeID The id of the node to be visualized as active.
     * @param {string} previousNodeID The id of the previous node.
     */
    makeTransition(activeNodeID, previousNodeID) {
        this.nodes.map(node => {
            node.settings.fillcolor = activeNodeID === node.id
                                       ? this.colors.active
                                       : this.colors.white
            node.settings.fontcolor = activeNodeID === node.id
                                       ? this.colors.white
                                       : this.colors.black
        })
        this.updateTransitionsColor(activeNodeID, previousNodeID)
    }

    /**
     * Changes the color to warning for the node associated with the given node id.
     * @param {int} The id of the node to change.
     */
    setNodeColorToWarningByID(previousNodeID) {
        this.getNodeByID(previousNodeID).settings.fillcolor = this.colors.warning
        this.updateTransitionsColor()
    }

    /**
     * Updates the colors of the transitions. Colors the previous transition to 
     * the active color.
     * @param {string} activeNodeID The id of the active node.
     * @param {string} previousNodeID The id of the previous node.
     */
    updateTransitionsColor(activeNodeID, previousNodeID) {
        this.transitions.map(transition => {
            let isPreviousTransition = transition.from === previousNodeID && transition.to === activeNodeID
            
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
     * Gets a DFA node by id.
     */
    getNodeByID(id) {
        return this.nodes.find(node => node.id === id)
    }
}