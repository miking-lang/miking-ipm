include "dfa.mc"
include "string.mc"


-- Figuring out if a state is end or not
recursive
let checkEndNode = lam trans. lam state.
    if(eqi (length trans) 0) then true
    else
    let first = head trans in
    let rest = tail trans in
    if (eqi first.0 state) then false
    else checkEndNode rest state
end

-- Parsing all the end states
recursive
let parseAllEndStates = lam states. lam trans. lam output.
    if(eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    if (checkEndNode trans first) then
    let output = strJoin "" [output, "'", (int2string (length states)), "'"] in
    parseAllEndStates rest trans output
    else parseAllEndStates rest trans output
end

-- Formatting the states
recursive
let parseStates = lam states. lam output. lam startState. lam trans.
    if (eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    let parsedFirst = strJoin "" [ "{name: '",
    (int2string first),
    "', id:'",
    (int2string (length states)),
    "'},\n"] in
    parseStates rest (concat output parsedFirst) startState trans
end

-- Find the Starting State ID
recursive
let startID = lam states. lam startState.
    let first = head states in
    let rest = tail states in
    if (eqi startState first) then (strJoin "" ["startID = '", (int2string (length states)), "',\n"])
    else
    startID rest startState
end

-- Formatting transitions
recursive
let parseTransitions = lam trans. lam output.
    if(eqi (length trans) 0) then output
    else
    let first = head trans in
    let rest = tail trans in
    let parsedFirst = [" {from: '", (int2string first.0), "', to: '" ,(int2string first.1) , "', label: '" , [first.2] , "'},\n"] in
    let parsedFirst = strJoin "" parsedFirst in
    parseTransitions rest (concat output parsedFirst)
end
    


-- Parse a DFA to JS code and visualize
let dfaVisual = lam states. lam trans. lam startState.
    let js_code = strJoin "" ["let dfa = new DFA(
    rankDirection = 'LR', \n nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, \n nodes = [\n",
    (parseStates states "" startState trans),
    "], \n ",
    (startID states startState),
    "endIDS = [",
    (parseAllEndStates states trans ""),
    "],\n",
    "transistions = [\n",
    (parseTransitions trans ""),
    "] \n )\n"] in
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
