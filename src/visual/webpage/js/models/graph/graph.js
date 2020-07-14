/**
 * This class acts as a model for a Graph. It contains methods for 
 * manipulating the object.
 */
class Graph {
    /**
     * @param {object} model Contains nodes and edges of the graph model.
     * @param {boolean} directed Whether the graph is directed or not.
     * @param {string} name A generated name, used to distinguish between visualized models.
     */
    constructor(model, directed, name) {
        this.name = name
        // Sets the render direction. Allowed values: TB, BT, RL, LR.
        this.rankDirection = "LR"
        // Used for general node settings. 
        // See: https://graphviz.org/documentation/ for allowed values.
        this.nodeSettings = {style: 'filled', fillcolor: 'white', shape:"circle"}
        this.colors = {active: "green", white: "white", black:"black", warning:"red3"}
        // Init states
        this.directed = directed
        this.nodes = model.nodes.map(node => {
            node.settings = {}
            return node
        })
        this.edges = model.edges
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
        return `${this.directed ? `digraph` : `graph`} {
            rankdir=${this.rankDirection}
            node [${this.objectToString(this.nodeSettings)}]
            ${this.nodes.map(node =>
                `${node.name} [id=${node.name} class="${this.name}-node" ${this.objectToString(node.settings)}]`
            ).join("\n")}
            ${this.edges.map(edge =>
                `${edge.from} ${this.directed ? `->` : `--`} ${edge.to} [${edge.label ? `label=${edge.label}`:``} fontcolor=${edge.fontcolor} color=${edge.color}]`
            ).join("\n")}
        }`
    }

    /*              GETTERS               */
    /**
     * Gets a node by name.
     */
    getNodeByName(name) {
        return this.nodes.find(node => node.name === name)
    }
}