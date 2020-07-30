include "../src/models/modelVisualizer.mc"

mexpr 
  let string2string = (lam x. x) in
  let char2string = (lam x. [x]) in
	let stringEq = setEqual eqchar in
  
	let nfaAlphabet = ['0','1','2','3'] in
	let nfaStates = ["a","b","c","d","e","f"] in
	let nfaTransitions = [("a","b",'1'),("b","c",'0'),("c","d",'2'),("c","e",'2'),("d","a",'1'),("e","f",'1')] in
	let nfaStartState = "a" in
	let nfaAcceptStates = ["a"] in
	
	-- create your NFA
	let nfa = nfaConstr nfaStates nfaTransitions nfaAlphabet nfaStartState nfaAcceptStates stringEq eqchar in


	-- create your Binary Tree
	let btree = BTree (Node(2, Node(3, Nil (), Leaf 4), Leaf 5)) in

	visualize [
    BTree(btree, int2string,[(2,"root"),(3,"node"),(5,"node"),(4,"leaf")]),
    NFA(nfa, "1021", string2string, char2string,[("a","start")]),
    NFA(nfa, "102", string2string, char2string)
	]