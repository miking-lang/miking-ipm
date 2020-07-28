include "types/btree.mc"
include "types/dfa.mc"
include "types/nfa.mc"

-- Represents models that can be visualized and its associated data.
-- Also provides toDot functions for all types defined below
type Model
    con Digraph : (Digraph,    vertex2str, edge2str ) -> Model
    con DFA     : (DFA, input, state2str,  label2str) -> Model
    con Graph   : (Graph,      vertex2str, edge2str ) -> Model
    con NFA     : (NFA, input, state2str,  label2str) -> Model
    con BTree   : (BTree, node2str) -> Model

let printList = lam list. 
    map (lam x. print x) list

let graphPrintDot = lam graph. lam v2str. lam l2str. lam direction.
    let edges = graphEdges graph in
    let vertices = graphVertices graph in
    let _ = print "graph {" in
    let _ = printList ["rankdir=", direction, ";\n"] in
    let _ = printList ["node [style=filled fillcolor=white shape=circle];"] in
    let _ = map 
        (lam v. 
            let _ = print (v2str v) in
            print " [];") 
        vertices in
    let _ = map
        (lam e. let _ = print (v2str e.0) in
            let _ = print " -- " in
            let _ = print (v2str e.1) in
            let _ = print "[label=\"" in
            let _ = print (l2str e.2) in
            print "\"];")
        edges in
    let _ = print "}\n" in ()

let modelPrintDot = lam model. lam direction.
    match model with Graph(graph,v2str,l2str) then
        graphPrintDot graph v2str l2str direction
    else match model with Digraph(digraph,v2str,l2str) then 
        -- Direction not working atm.
        digraphPrintDot digraph v2str l2str
    else match model with NFA(nfa,input,state2str,label2str) then
        nfaPrintDot nfa state2str label2str direction
    else match model with DFA(dfa,input,state2str,label2str) then
        dfaPrintDot dfa state2str label2str direction
    else match model with BTree(tree, node2str) then
        match tree with BTree(t) then
            -- Direction not working atm.
            let _ = btreePrintDot t node2str in
            ()
        else "" 
    else ""

mexpr
let alfabeth = ['0','1'] in
let states = ["a","b","c"] in
let transitions = [("a","b",'1'),("b","c",'0'),("c","a",'1')] in
let startState = "a" in
let acceptStates = ["a", "c"] in
let dfa = dfaConstr states transitions alfabeth startState acceptStates (setEqual eqchar) eqchar in
let model = DFA(dfa, "1011", lam b. b, lam b. [b]) in 
utest match model with DFA(d,i,s2s,t2s) then i else "" with "1011" in
utest match model with DFA(d,i,s2s,t2s) then d.acceptStates else "" with ([(['a']),(['c'])]) in 
()
