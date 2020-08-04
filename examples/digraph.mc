-- This is an example file for generating and visualizing
-- a Digraph model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr
-- Display function for vertices
let char2string = (lam b. [b]) in

-- create an empty digraph
let digraph = digraphEmpty eqchar eqi in

-- adding vertices to the digraph
let digraph = foldr digraphAddVertex digraph ['A','B','C','D','E'] in

-- adding the edges to the digraph
let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) digraph [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in

-- This function parses the digraph and visualizez it
-- Source the to string functions for both the vertices and the edges here
visualize [
	Digraph(digraph, char2string,int2string,[])
	]
