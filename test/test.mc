include "../src/model/gen.mc"

mexpr

let alfabeth = ['0','1'] in
let states = ['a','b','c'] in
let transitions = [('a','b','1'),('b','c','0'),('c','a','1')] in
let startState = 'a' in
let acceptStates = ['a', 'c'] in
let input = "11" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqchar eqchar (lam b. [b]) (lam b. [b]) in
let output = dfaVisual newDfa input in
print output
