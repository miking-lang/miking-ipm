include "types/btree.mc"
include "dfa.mc"

-- Represents models that can be visualized and its associated data.
type Model
    con Digraph : (Digraph, vertex2str, edge2str,    displayNames) -> Model
    con DFA     : (DFA, input, state2str, label2str, displayNames) -> Model
    con Graph   : (Graph,  vertex2str, edge2str,     displayNames) -> Model
    con NFA     : (NFA, input, state2str, label2str, displayNames) -> Model
    con BTree   : (BTree,node2str,                   displayNames) -> Model

mexpr
let alfabeth = ['0','1'] in
let states = ["a","b","c"] in
let transitions = [("a","b",'1'),("b","c",'0'),("c","a",'1')] in
let startState = "a" in
let acceptStates = ["a", "c"] in
let dfa = dfaConstr states transitions alfabeth startState acceptStates (setEqual eqchar) eqchar in
let model = DFA(dfa, "1011", lam b. b, lam b. [b],[]) in 
utest match model with DFA(d,i,s2s,t2s,[]) then i else "" with "1011" in
utest match model with DFA(d,i,s2s,t2s,[]) then d.acceptStates else "" with ([(['a']),(['c'])]) in 
()
