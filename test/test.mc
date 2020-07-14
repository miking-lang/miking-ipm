include "../src/model/gen.mc"
let getDfa = lam b. lam c. lam d. lam e.
    {modelType="dfa",
    model=b,
    input=c,
    s2s=d,
    t2s=e
    }
    
mexpr

let alfabeth = ['0','1'] in
let states = ["a","b","c"] in
let transitions = [("a","b",'1'),("a","c",'1'),("b","c",'0'),("c","a",'1')] in
let startState = "a" in
let acceptStates = ["a", "c"] in
let input = "1011" in
let state2string = int2string in
let trans2string = (lam b. [b]) in
let newDfa = {modelType="dfa",model=dfaConstr states transitions alfabeth startState acceptStates (setEqual eqchar) eqchar (lam b. b) (lam b. [b]),input=input} in
let newDigraph = {modelType="digraph",model=digraphAddVertex 1 (digraphEmpty eqi eqi)} in
let output = visualize [newDfa,newDigraph] in
print output