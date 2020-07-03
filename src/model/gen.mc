include "dfa.mc"
include "../../stdlib/string.mc"


-- Parse states
recursive
let parseStates = lam states. lam output.
    if (eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    let parsedFirst = concat "{name: '" (int2string first) in
    let parsedFirst = concat parsedFirst "', id:'" in
    let parsedFirst = concat parsedFirst (int2string (length states)) in
    let parsedFirst = concat parsedFirst "', settings: {}},\n" in
    parseStates rest (concat output parsedFirst)
end

recursive
let parseTransitions = lam trans. lam output.
    if(eqi (length trans) 0) then output
    else
    let first = head trans in
    let rest = tail trans in
    let parsedFirst = concat " {from: '" (int2string first.0) in
    let parsedFirst = concat parsedFirst "', to: '" in
    let parsedFirst = concat parsedFirst (int2string first.1) in
    let parsedFirst = concat parsedFirst "', label: '" in
    let parsedFirst = concat parsedFirst "hardcodedatm" in
    let parsedFirst = concat parsedFirst "'},\n" in
    parseTransitions rest (concat output parsedFirst)
end
    


-- Parse a DFA to JS code and visualize
let dfaVisual = lam states. lam trans. lam startState.
    let js_code = "let dfa = new DFA(
    rankDirection = 'LR',
    nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'},
    nodes = [\n" in
    let js_code = concat js_code (parseStates states "") in
    let js_code = concat js_code "}
   ], 
   transistions = [\n" in
   let js_code = concat js_code (parseTransitions trans "") in
   let js_code = concat js_code  "] \n )\n" in
   js_code






mexpr
let l1 = gensym() in
let l2 = gensym() in
let alfabeth = [l1] in
let states = [1,2,3] in
let transitions = [(1,2,l1),(2,3,l1)] in
let startState = 1 in
let acceptStates = [2,3] in 
let newDigraph = dfaAddAllStates states (digraphEmpty eqi eqs) in
let newDfa = dfaConstr states transitions eqi eqs alfabeth startState acceptStates in
let output = dfaVisual states transitions startState in
print output


