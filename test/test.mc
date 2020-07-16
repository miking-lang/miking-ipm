include "../src/model/gen.mc"

mexpr
let string2string = (lam b. b) in
let eqString = setEqual eqchar in
let char2string = (lam b. [b]) in

-- create your directed graph
let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) (foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in

-- create your graph
let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) (foldr graphAddVertex (graphEmpty eqi eqString) [1,2,3,4]) [(1,2,""),(3,2,""),(1,3,""),(3,4,"")] in

visualize [
    Digraph(digraph, char2string,int2string),
    Graph(graph,int2string,string2string)
]
