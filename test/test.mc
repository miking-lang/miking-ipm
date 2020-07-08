include "../src/model/gen.mc"

mexpr
let alfabeth = ['1', '0'] in
let states = [1,2,3,4] in
let transitions = [(1,2,'1'),(2,4,'0'),(2,3,'0')] in
let startState = 1 in
let acceptStates = [2,3,4] in
let input = "1000011" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates in
let output = dfaVisual newDfa input in
print output
