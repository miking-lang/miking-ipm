// Renders a given DFA to the given graphviz object.
const render = dfa => {
    // Defining the callback function
    const interactive = () =>
        // Adds on click event listeners to each of the nodes.
        d3.selectAll('.node').on("click", function () {
            let id = d3.select(this).attr('id')
            console.log(id)
        });
    // Renders the dfa with the interactive callback function.
    graph.renderDot(dfa.toDot())
        .on("end", interactive)
    }

// Initializes the graphviz object.
const graph = d3.select("#graph").graphviz({zoom: false})

// Checks for an existing DFA object defined in the generated source file.
dfa
 ? render(dfa)
 : console.error("Error: DFA is not defined! See README.md for how use this package.")
