-- This is an example file for generating and visualizing
-- a Binary Tree model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"



mexpr

-- create your Binary Tree
let btree1 = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) in
let btree2 = BTree (Node(23, Node (29, Node(7,( Leaf 5), Node (10, (Leaf 12), Nil())), Leaf 19), Leaf 14)) in

visualize [
	BTree(btree1, int2string,[(2,"Two"),(3,"Three"),(4,"Four"),(5,"Five")]),
	BTree(btree1, int2string,[]),
	BTree(btree2, int2string,[])
]

