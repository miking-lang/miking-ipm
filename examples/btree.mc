-- This is an example file for generating and visualizing
-- a Binary Tree model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr
-- Defining the components of the tree

-- create your Binary Tree
let btreeModel = Node(2, Node(3, Nil (), Leaf 4), Leaf 5) in
let btreeModel2 = Node(23, Node (29, Node(7,( Leaf 5), Node (10, (Leaf 12), Nil())), Leaf 19), Leaf 14) in
let btree = btreeConstr btreeModel eqi in
let btree2 = btreeConstr btreeModel2 eqi in

-- Last argument is a list that maps nodes to extra settings.
-- The purpose is to visualize a node's name differently if
-- needed. This examples maps node 10 to the output name (label)
-- of "root".
visualize [
	BTree(btree, int2string,"TB",[]),
    -- with the display names
	BTree(btree, int2string,"TB",[(2,[("label","Two")]),(3,[("label","Three")]),(4,[("label","Four")]),(5,[("label","Five")])]),
	BTree(btree2, int2string,"TB",[])
]