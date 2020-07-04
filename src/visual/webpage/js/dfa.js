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
     * @param {[object]} transitions Transistions between nodes. Each transition requires the 
     *                               following attributes: from (string), to (string) and 
     *                               label (string).
     */
    constructor(rankDirection = "TB", nodeSettings = {}, nodes = [], transitions = []) {
        this.rankDirection = rankDirection,
        this.nodeSettings = nodeSettings
        this.nodes = nodes
        this.transitions = transitions
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
            ${this.nodes.map(node =>
                `${node.name} [id=${node.id} ${node.settings ? this.objectToString(node.settings):""}]`
            ).join("\n")}
            ${this.transitions.map(transition =>
                `${transition.from} -> ${transition.to} [label=${transition.label}]`
            ).join("\n")}
        }`
}