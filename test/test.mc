include "../src/model/gen.mc"
let getDfa = lam b. lam c. lam d. lam e.
    {modelType="dfa",
    model=b,
    input=c,
    s2s=d,
    t2s=e
    }

mexpr

let alfabeth = ['0','1','2','3'] in
let states = ["a","b","c"] in
let transitions = [("c","a",'0'),("a","b",'1'),("b","c",'0'),("c","a",'1'),("a","b",'3'),("c","a",'2'),("a","b",'0')] in
let startState = "a" in
let acceptStates = ["a", "c"] in
let input = "1011" in
let state2string = int2string in
let trans2string = (lam b. [b]) in
let newDfa = {modelType="dfa",model=dfaConstr states transitions alfabeth startState acceptStates (setEqual eqchar) eqchar (lam b. b) (lam b. [b]),input=input} in
let newDigraph = {modelType="digraph",model=digraphAddEdge '1' '2' 'a' (digraphAddEdge '2' '2' 'k' (digraphAddEdge '1' '2' 'z' (digraphAddVertex '1' (digraphAddVertex '2' (digraphEmpty eqchar eqchar))))),v2s = (lam b. [b]), l2s = (lam b. [b])} in
let newGraph = {modelType="graph",model=graphAddEdge '1' '2' 'a' (graphAddEdge '1' '2' 'b' (graphAddVertex '1' (graphAddVertex '2' (graphEmpty eqchar eqchar)))),v2s = (lam b. [b]), l2s = (lam b. [b])} in
let output = visualize [newGraph,newDigraph, newDfa] in
print output
