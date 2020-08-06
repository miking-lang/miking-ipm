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

-- Last argument is a list that maps nodes to displayNames.
-- The purpose is to visualize a node's name differently if
-- needed. This examples maps node 10 to the output name
-- of "root".
visualize [
	BTree(btree, int2string,[]),
    -- with the display names
	BTree(btree, int2string,[(2,"Two"),(3,"Three"),(4,"Four"),(5,"Five")]),
	BTree(btree2, int2string,[])
]