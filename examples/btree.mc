-- This is an example file for generating and visualizing
-- a Binary Tree model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"



mexpr

<<<<<<< HEAD

-- The input for simulation is given here as the second argument
-- in the constructor.
-- Last argument is a list that maps states to displayNames.
-- The purpose is to visualize a state's name differently if
-- needed. This examples maps the state "s0" to the output name
-- of "start state".
visualize [
	-- accepted by the DFA
	DFA(dfa,"10010100",string2string, char2string,[("s0","start state"),("s3","accept state")]),
	-- not accepted by the DFA
	DFA(dfa,"101110",string2string, char2string, []),
	-- not accepted by the DFA
	DFA(dfa,"1010001",string2string, char2string, [])
	]
=======
-- create your Binary Tree
let btree1 = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) in
let btree2 = BTree (Node(23, Node (29, Node(7,( Leaf 5), Node (10, (Leaf 12), Nil())), Leaf 19), Leaf 14)) in

visualize [
	BTree(btree1, int2string,[(2,"Two"),(3,"Three"),(4,"Four"),(5,"Five")]),
	BTree(btree1, int2string,[]),
	BTree(btree2, int2string,[])
]
>>>>>>> 8fd417b... added some examples, not all yet
