include "src/model/gen.mc"

mexpr
let l1 = gensym() in
let l2 = gensym() in
let alfabeth = [l1] in
let states = [1,2,3,4,5] in
let transitions = [(1,2,l1),(2,3,l1),(3,4,l1)] in
let startState = 1 in
let acceptStates = [2,3] in 
let newDigraph = dfaAddAllStates states (digraphEmpty eqi eqs) in
let newDfa = dfaConstr states transitions eqi eqs alfabeth startState acceptStates in
let output = dfaVisual states transitions startState in
print output
