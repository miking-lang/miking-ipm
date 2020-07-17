/**
 * This function is responsible for visualizing the model.
 * Renders the DOM tree of the model. 
 * @param {div} root The root element, defining where to render.
 * @param {string} dot The model in dot format.
 * @param {function} callbackFunction The callback function called, when interacting with the graph.
 */
function ModelRender(root, dot, callbackFunction) {
    d3.select(root)
        .graphviz({zoom: false})
        .renderDot(dot)
        .on("end", callbackFunction)
}
