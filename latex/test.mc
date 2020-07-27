include "../src/model/todot.mc"
include "digraph.mc"
include "string.mc"
include "map.mc"

mexpr
let string2string = lam b. b in
let char2string = lam b. [b] in
let eqString = setEqual eqchar in


let alphabet = ['0','1'] in
let states = ["s0","s1","s2"] in
let transitions = [
  ("s0","s1",'1'),
  ("s1","s1",'1'),
  ("s1","s2",'0'),
  ("s2","s1",'1'),
  ("s2","s2",'0')
] in
let startState = "s0" in
let acceptStates = ["s2"] in

let dfa = dfaConstr states transitions alphabet startState acceptStates eqString eqchar in

let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
                (foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E','F']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5)] in
                --[('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2),('F','A',0)] in
let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) 
              (foldr graphAddVertex (graphEmpty eqi eqString) [1,2,3,4]) 
              [(1,2,"g"),(3,2,"a"),(1,3,""),(3,4,"")] in

--model2dot (graphEdges graph) (graphVertices graph) int2string string2string "LR" "graph"
nfa2dot (getTransitions dfa) (getStates dfa) string2string char2string eqString "LR" startState acceptStates
--model2dot (digraphEdges digraph) (digraphVertices digraph) char2string int2string "LR" "digraph"