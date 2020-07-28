include "../src/models/model.mc"

mexpr 
	let char2string = (lam b. [b]) in

	-- create your directed graph
	let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
	(foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in
  
	let digraphModel = Digraph(digraph, char2string,int2string) in

	model2dot digraphModel