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
        this.nodes = nodes.map(node => {
            node.settings = node.settings 
                                ? node.settings : {}
            if (acceptedIDs.includes(node.id))
                node.settings.shape = "doublecircle"
            return node
        })
        this.transitions = transitions
        this.activeNodeID = startID
        this.colors = {active: "green", white: "white", black:"black"}
        this.makeTransition(startID)
    }

    /**
     * Translates the given object to a space separated string.
     * @param {object} attributes An object with attributes of primitive type.
     * @returns The translated string.
     */
    objectToString = attributes => 
        Object.keys(attributes).map(key =>
            `${key} = ${attributes[key]}`
        ).join(" ")
        
    /**
     * Translates the DFA object to dot syntax.
     * @returns {string} The DFA object in dot syntax.
     */
    toDot = () => 
        `digraph {
            rankdir=${this.rankDirection}
            node [${this.objectToString(this.nodeSettings)}]
            start [fontcolor = white color = white class="start-node"]
            ${this.nodes.map(node =>
                `${node.id} [label=${node.label} id=${node.id} class="dfa-node" ${node.settings ? this.objectToString(node.settings):""}]`
            ).join("\n")}
            start -> ${this.startNodeID} [label="start"]
            ${this.transitions.map(transition =>
                `${transition.from} -> ${transition.to} [label=${transition.label}]`
            ).join("\n")}
        }`

    /**
     * Updates the state of the DFA by changing the active node.
     * @param {string} toID The node id to transition to.
     */
    makeTransition = toID => {
        this.activeNodeID = toID
        this.updateNodesColor()
    }

    /**
     * Sets the active color to the given value.
     * @param {string} to The color to set
     */
    setActiveNodeColor = to => {
        this.getActiveNode().settings.fillcolor = to
        this.colors.active = to
    }

    /**
     * Update the DFA to the new state by a given transition.
     * @param {Transition} transition The transition to accomplish.
     */
    updateState = transition =>
        // TEMPORARY CODE
        this.makeTransition(this.transitions.find(trans => 
            this.activeNodeID === trans.from && transition === trans.label
        ).to)

    /**
     * Updates the color of the nodes.
     * @param {Node} activeNodeID The id of the node to be visualized as active.
     */
    updateNodesColor = () =>
        this.nodes.map(node => {
            node.settings.fillcolor = this.activeNodeID === node.id
                                       ? this.colors.active
                                       : this.colors.white
            node.settings.fontcolor = this.activeNodeID === node.id
                                       ? this.colors.white
                                       : this.colors.black
        })

    /*              GETTERS               */
    /**
     * Gets the active node of the DFA.
     */
    getActiveNode = () =>
        this.nodes.find(node => node.id === this.activeNodeID)
}