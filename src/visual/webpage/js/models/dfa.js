/**
 * This class acts as a model for DFA. It contains methods for 
 * manipulating the object.
 */
class DFA {
    /**
     * @param {string} rankDirection Sets the render direction. Allowed values: TB, BT, RL, LR.
     * @param {object} nodeSettings Used for general node settings. See:
     *                              https://graphviz.org/documentation/ for allowed values.
     * @param {string} startID The ID of the node from where to start the simulation.
     * @param {string} endIDs  The accepting nodes.
     * @param {[object]} nodes Each node instance requires a name (string), id (string) and a 
     *                         settings (object) property. Node specific attributes are listed 
     *                         as properties of the settings object attribute. 
                               Note: If no extra settings are wanted, pass an empty object for 
                               the settings attribute: "settings: {}".
     * @param {[object]} transitions Transistions between nodes. Each transition requires the 
     *                               following attributes: from (string), to (string) and 
     *                               label (string).
     */
    constructor(rankDirection = "TB", nodeSettings = {}, startID, endIDs = [], nodes = [], transitions = []) {
        this.rankDirection = rankDirection,
        this.nodeSettings = nodeSettings
        this.startNode = nodes.find(node => node.id === startID)
        this.nodes = nodes.map(node => {
            node.settings = node.settings ? node.settings : {}
            return node
        })
        this.transitions = transitions
        this.nodes.filter(node => endIDs.includes(node.id)).map(node => node.settings.shape = "doublecircle")
        this.colors = {active: "green", normal: "white"}
        this.initState()
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
            s [fontcolor = white color = white]
            ${this.nodes.map(node =>
                `${node.name} [id=${node.id} class="dfaNode" ${node.settings ? this.objectToString(node.settings):""}]`
            ).join("\n")}
            s -> ${this.startNode.name} [label=start]
            ${this.transitions.map(transition =>
                `${transition.from} -> ${transition.to} [label=${transition.label}]`
            ).join("\n")}
        }`

    /**
     * Initializes the state of the DFA. 
     */
    initState = () => {
        this.updateNodesColor(this.startNode.name)
    }

    /**
     * Sets the active color to the given value.
     * @param {string} to The color to set
     */
    setActiveNodeColor = to => {
        let activeNode = this.getActiveNode()
        this.colors.active = to
        activeNode.settings.fillcolor = to
    }

    /**
     * Update the DFA to the new state by a given transition.
     * @param {Transition} transition The transition to accomplish.
     */
    updateState = transition => {
        let activeNode = this.getActiveNode()
        let currentTransition = this.transitions.find(trans => 
            activeNode.name === trans.from && transition === trans.label
        )
        this.updateNodesColor(currentTransition.to)
    }

    /**
     * Updates the color of the nodes.
     * @param {Node} activeNodeName The node to be visualized as active.
     */
    updateNodesColor = activeNodeName => {
        this.nodes.map(node =>
            node.settings.fillcolor = activeNodeName === node.name
                                       ? this.colors.active
                                       : this.colors.normal
        )
    }

    /*              GETTERS               */

    /**
     * Gets the current active node.
     */
    getActiveNode = () =>
        this.nodes.find(node => node.settings.fillcolor === this.colors.active)
}