-- This is an example file for generating and visualizing
-- a Graph model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr
-- Display function for vertices and labels (edges)
let string2string = (lam b. b) in

-- create an empty graph, specify the equality functions for both the vertices and the edge's labels
let eqString = setEqual eqchar in
let graph = graphEmpty eqi eqString in

-- adding vertices to the graph
let graph = foldr graphAddVertex graph [1,2,3,4] in

-- adding the edges to the graph
let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) graph [(1,2,""),(3,2,""),(1,3,""),(3,4,"")] in

-- This function parses the graph and visualizez it
-- Source the to string functions for both vertices and edges here
visualize [
	  Graph(graph,int2string,string2string,[])
	]
