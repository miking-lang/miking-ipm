include "../src/model/gen.mc"

mexpr
let string2string = (lam b. b) in
let eqString = setEqual eqchar in
let char2string = (lam b. [b]) in

-- create your DFA
let alfabeth = ['0','1'] in
let states = ["s0","s1","s2"] in
let transitions = [
  ("s0","s1",'1'),
  ("s1","s1",'1'),
  ("s1","s2",'0'),
  ("s2","s1",'1'),
  ("s2","s2",'0')
] in

let startState = "s0" in
let acceptStates = ["s2"] in

let dfa = dfaConstr states transitions alfabeth startState acceptStates eqString eqchar in

visualize [
    -- accepted by the DFA
    DFA(dfa,"1000",string2string, char2string),
    -- accepted by the DFA
    DFA(dfa,"101110",string2string, char2string),
    -- not accepted by the DFA
    DFA(dfa,"1010001",string2string, char2string)
]