include "../src/model/gen.mc"

mexpr

let alfabeth = ['0','1'] in
let states = ["a","b","c"] in
let transitions = [("a","b",'1'),("b","c",'0'),("c","a",'1')] in
let startState = "a" in
let acceptStates = ["a", "c"] in

let dfa = dfaConstr states transitions alfabeth startState acceptStates (setEqual eqchar) eqchar in
let state2str = lam b. b in
let label2str = (lam b. [b]) in
let model = DFA(dfa, "1011", state2str, label2str) in 
let model2 = DFA(dfa, "1001", state2str, label2str) in 
visualize [model,model2]