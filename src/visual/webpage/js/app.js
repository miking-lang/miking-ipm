// Renders a given DFA at the given graphviz object.
const render = (dfa, graph) => {
    // Defining the callback function, which is called when the graph is rendered.
    const interactive = () =>
        // Adds on click event listeners to each of the nodes.
        d3.selectAll('.node').on("click", function () {
            let id = d3.select(this).attr('id')
            console.log(id)
        });
        
    graph.renderDot(dfa.toDot())
        .on("end", interactive)
    }

// Initializes the graphviz object.
const graph = d3.select("#graph").graphviz({zoom: false})

// Checks for an existing DFA object defined in the generated source file.
dfa
 ? render(dfa, graph)
 : console.error("Error: DFA is not defined! See README.md for how use this package.")
