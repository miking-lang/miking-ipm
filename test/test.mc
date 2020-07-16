include "../src/model/gen.mc"

mexpr
let string2string = (lam b. b) in
let char2string = (lam b. [b]) in

-- create your DFA
let alfabeth = ['0','1','2','3'] in
let states = ["a","b","c"] in
let transitions = [("c","a",'0'),("a","b",'1'),("b","c",'0'),("c","a",'1'),("a","b",'3'),("c","a",'2'),("a","b",'0')] in
let startState = "a" in
let acceptStates = ["a", "c"] in

let dfa = dfaConstr states transitions alfabeth startState acceptStates (setEqual eqchar) eqchar in

-- create your directed graph
let digraph = digraphAddEdge 1 2 0 (foldr digraphAddVertex (digraphEmpty eqi eqi) [1,2,3]) in

let graph = graphAddEdge 1 2 3 (foldr graphAddVertex (digraphEmpty eqi eqi) [1,2]) in

let btree = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5), int2string) in

visualize [
    DFA(dfa, "1011", string2string, char2string),
    Digraph(digraph, int2string,int2string),
    Graph(graph, int2string,int2string),
    BTree(btree, int2string)
]
