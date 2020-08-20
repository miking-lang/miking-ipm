include "types/btree.mc"
include "types/circuit.mc"
include "dfa.mc"

-- Represents models that can be visualized and its associated data.
type Model
    con Digraph : (Digraph, vertex2str, edge2str,    direction, displayNames) -> Model
    con DFA     : (DFA, input, state2str, label2str, direction, displayNames) -> Model
    con Graph   : (Graph,  vertex2str, edge2str,     direction, displayNames) -> Model
    con NFA     : (NFA, input, state2str, label2str, direction, displayNames) -> Model
    con BTree   : (BTree,node2str,                   direction, displayNames) -> Model
    con Circuit : (Circuit                                         ) -> Model

mexpr
let states = ["a","b","c"] in
let transitions = [("a","b",'1'),("b","c",'0'),("c","a",'1')] in
let startState = "a" in
let acceptStates = ["a", "c"] in
let dfa = dfaConstr states transitions startState acceptStates (setEqual eqchar) eqchar in
let model = DFA(dfa, "1011", lam b. b, lam b. [b],"LR",[]) in 
utest match model with DFA(d,i,s2s,t2s,"LR",[]) then i else "" with "1011" in
utest match model with DFA(d,i,s2s,t2s,"LR",[]) then d.acceptStates else "" with ([(['a']),(['c'])]) in 
()
