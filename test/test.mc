include "../src/models/modelVisualizer.mc"

mexpr
let string2string = (lam b. b) in
let eqString = setEqual eqchar in
let char2string = (lam b. [b]) in

-- create your DFA
let alfabeth = ['0','1'] in
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

let dfa = dfaConstr states transitions alfabeth startState acceptStates eqString eqchar in

-- create your directed graph
let digraph = foldr (lam e. lam g. digraphAddEdge e.0 e.1 e.2 g) 
(foldr digraphAddVertex (digraphEmpty eqchar eqi) ['A','B','C','D','E']) 
            [('A','B',2),('A','C',5),('B','C',2),('B','D',4),('C','D',5),('C','E',5),('E','D',2)] in

-- create your graph
let graph = foldr (lam e. lam g. graphAddEdge e.0 e.1 e.2 g) 
(foldr graphAddVertex (graphEmpty eqi eqString) [1,2,3,4]) [(1,2,""),(3,2,""),(1,3,""),(3,4,"")] in

let nfaAlphabet = ['0','1','2','3'] in
	let nfaStates = ["a","b","c","d","e","f"] in
	let nfaTransitions = [("a","b",'1'),("b","c",'0'),("c","d",'2'),("c","e",'2'),("d","a",'1'),("e","f",'1')] in
	let nfaStartState = "a" in
	let nfaAcceptStates = ["a"] in
	
	-- create your NFA
	let nfa = nfaConstr nfaStates nfaTransitions nfaAlphabet nfaStartState nfaAcceptStates eqString eqchar in

	-- create your Binary Tree
	let btree = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) in
visualize [
	-- accepted by the DFA
	DFA(dfa,"10010100",string2string, char2string,[("s0","start state"),("s3","accept state")]),
	-- not accepted by the DFA
	DFA(dfa,"101110",string2string, char2string,[]),
	-- not accepted by the DFA
	DFA(dfa,"1010001",string2string, char2string,[]),
	Digraph(digraph, char2string,int2string,[]),
	Graph(graph,int2string,string2string,[]),
	BTree(btree, int2string,[(2,"Two"),(3,"Three"),(4,"Four"),(5,"Five")],[]),
	NFA(nfa, "1021", string2string, char2string,[]),
	NFA(nfa, "102", string2string, char2string,[])
]