include "../src/model/gen.mc"

mexpr
let string2string = (lam b. b) in
let eqString = setEqual eqchar in
let char2string = (lam b. [b]) in


-- create your DFA
let alphabet = ['0','1','2','3'] in
let states = ["a","b","c"] in
let transitions = [("c","a",'0'),("a","b",'1'),("b","c",'0'),("c","a",'1'),("a","b",'3'),("c","a",'2'),("a","b",'0')] in
let startState = "a" in
let acceptStates = ["a", "c"] in

let dfa = dfaConstr states transitions alphabet startState acceptStates (setEqual eqchar) eqchar in


-- create your graph
let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) 
              (foldr graphAddVertex (graphEmpty eqi eqString) [1,2,3,4]) 
              [(1,2,""),(3,2,""),(1,3,""),(3,4,"")] in


-- create your directed graph
let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
                (foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in

let nfa = nfaConstr states transitions alphabet startState acceptStates (setEqual eqchar) eqchar in

let btree = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) in

visualize [
    DFA(dfa, "1011", string2string, char2string),
    Digraph(digraph, char2string,int2string),
    Graph(graph,int2string,string2string),
    BTree(btree, int2string),
    NFA(nfa, "1101", string2string, char2string)

]
