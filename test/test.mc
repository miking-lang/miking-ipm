include "../src/models/modelVisualizer.mc"
include "String.mc"

mexpr
let string2string = (lam b. b) in
let char2string = (lam b. [b]) in

-- create your DFA
let states = ["s0","s1","s2","s3"] in
let transitions = [
("s0","s1",'1'),
("s1","s1",'1'),
("s1","s2",'0'),
("s2","s1",'1'),
("s2","s3",'0'),
("s3","s1",'1')
] in

let startState = "s0" in
let acceptStates = ["s3"] in

let dfa = dfaConstr states transitions startState acceptStates eqstr eqchar in

-- create your directed graph
let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
(foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
            [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in

-- create your graph
let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) 
(foldr graphAddVertex (graphEmpty eqi eqstr) [1,2,3,4]) [(1,2,""),(3,2,""),(1,3,""),(3,4,"")] in

let nfaStates = ["a","b","c","d","e","f"] in
let nfaTransitions = [("a","b",'1'),("b","c",'0'),("c","d",'2'),("c","e",'2'),("d","a",'1'),("e","f",'1')] in
let nfaStartState = "a" in
let nfaAcceptStates = ["a"] in
	

-- create your NFA
let nfa = nfaConstr nfaStates nfaTransitions nfaStartState nfaAcceptStates eqstr eqchar in

-- create your BTree
let btree = btreeConstr (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) eqi in

-- create your circuit
let circuit = Parallel [
    Series[
        Component ("ammeter","amp",None(),true),
        Component ("capacitator","c",Some 8.0,true),
        Component ("ground","g",Some 0.0,false)
    ],
    Series [
        Component ("battery","V",Some 11.0,true),
        Parallel [
            Component ("resistor","R1",Some 4.0,true),
            Component ("resistor","R2",Some 1.0,true)
        ],
        Component ("lamp","lamp1",None(),true)
    ]
] in

let center_width = 2 in
let side_width = 8 in
let side_height = 8 in
let center_height = 2 in

let quote = "\\\"" in
let lampSettings = join ["shape=circle color=black style=filled fillcolor=lightyellow height=0 width=0 margin=0 label=<
        <table BORDER=",quote,"0",quote," CELLBORDER=",quote,"0",quote," CELLSPACING=",quote,"0",quote," CELLPADDING=",quote,"0",quote,"> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("none",side_width,side_height),("black",center_width,side_height),("none",side_width,side_height)],
            "</tr> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,center_height),("black",center_width,center_height),("black",side_width,center_height)],
            "</tr>
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("none",side_width,side_height), ("black",center_width,side_height),("none",side_width,side_height)],
            "</tr>   
        </table>>"] in

let side_width = 1 in
let center_width = 10 in
let side_height = 5 in
let center_height = 10 in

let capacitatorSettings = join ["shape=none, color=none height=0 width=0 margin=0 label=<
        <table BORDER=",quote,"0",quote," CELLBORDER=",quote,"0",quote," CELLSPACING=",quote,"0",quote," CELLPADDING=",quote,"0",quote,"> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height),("none",center_width,side_height),("black",side_width,side_height)],
            "</tr> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height),("none",center_width,center_height),("black",side_width,side_height)],
            "</tr>
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height), ("none",center_width,side_height),("black",side_width,side_height)],
            "</tr>   
        </table>>"] in


visualize [
    Circuit(
        circuit,[
            ("ammeter","shape=circle style=filled fillcolor=lightgreen height=0.2 width=0.2 label=\\\"A\\\"",""),
            ("lamp",lampSettings,""),
            ("capacitator",capacitatorSettings,"pF")
        ]
    ),
	-- accepted by the DFA
	DFA(dfa,"100100",string2string, char2string, "LR",[("s0",[("label","start state")]),
                                                        ("s3",[("label","accept state")])]),
	-- DFA without simulation
	DFA(dfa,"",string2string, char2string,"LR",[]),
	-- not accepted by the DFA
	DFA(dfa,"101110",string2string, char2string,"LR",[]),
	-- not accepted by the DFA
	DFA(dfa,"1010001",string2string, char2string,"LR",[]),
	Digraph(digraph, char2string,int2string,"LR",[]),
	Graph(graph,int2string,string2string,"LR",[]),
	BTree(btree, int2string,"TB",[(2,[("label","Two")]),(3,[("label","Three")]),(4,[("label","Four")]),(5,[("label","Five")])]),
	NFA(nfa, "1021", string2string, char2string,"LR",[]),
	NFA(nfa, "1011", string2string, char2string,"LR",[])
]
