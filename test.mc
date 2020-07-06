include "src/model/gen.mc"

mexpr
let alfabeth = ['1', '0'] in
let states = [1,2,3,4,5,6] in
let transitions = [(1,2,'1')] in
let startState = 1 in
let acceptStates = [2,3] in
let input = "1000011" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates in
let output = dfaVisual states transitions startState input in
print output
