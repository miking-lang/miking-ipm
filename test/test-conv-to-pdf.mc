include "../src/models/modelDot.mc"

mexpr
let string2string = lam b. b in
let char2string = lam b. [b] in
let eqString = setEqual eqchar in

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

let dfa = dfaConstr states transitions startState acceptStates eqString eqchar in
let myDfa = DFA(dfa, "101", string2string, char2string,"LR",[]) in

let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
                (foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E','F']) 
                [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5)] in
let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) 
              (foldr graphAddVertex (graphEmpty eqi eqString) [1,2,3,4]) 
              [(1,2,"g"),(3,2,"a"),(1,3,""),(3,4,"")] in

let treeModel = Node(2, Node(3, Nil (), Leaf 4), Leaf 5) in
let btree =  BTree(btreeConstr treeModel eqi, int2string,"TB",[]) in

--create your NFA
let nfaStates = ["a","b","c","d","e","f"] in
let nfaTransitions = [("a","b",'1'),("b","c",'0'),("c","d",'2'),("c","e",'2'),("d","a",'1'),("e","f",'1')] in
let nfaStartState = "a" in
let nfaAcceptStates = ["a"] in
let nfa = nfaConstr nfaStates nfaTransitions nfaStartState nfaAcceptStates (setEqual eqchar) eqchar in
let myNfa = NFA(nfa, "102", string2string, char2string,"LR",[]) in


let circuit = Circuit (
                Parallel [
                    Component ("ground","g",None ()),
                    Component ("battery","V3",0.0),
                    Series [
                        Component ("battery","V11",0.0),
                        Parallel [
                            Series [
                                Component ("battery","V20",0.0),
                                Parallel [
                                    Component ("battery","V31",0.0),
                                    Component ("battery","V32",0.0)
                                ]
                            ],
                            Component ("battery","V12",0.0)
                        ]
                    ],
                    Series [
                        Component ("resistor", "R5",0.0),
                        Component ("resistor", "R7",0.0)
                    ],
                    Component ("battery","V10",0.0)
                ]
            ) in

let myGraph = Graph(graph,int2string,string2string,"LR",[(1, [("label","hej")])]) in
let myDigraph = Digraph(digraph, char2string,int2string,"LR",[]) in
  modelPrintDot btree