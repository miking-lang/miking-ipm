include "string.mc"
include "map.mc"
include "dfa.mc"




-- Formatting the states
recursive
let parseStates = lam states. lam startState. lam trans. lam dfa. lam output. 
    if (eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    let parsedFirst = strJoin "" [ "{id: '",
    (int2string first.id),
    "', label:'",
    (dfa.s2s first.data),
    "'},\n"] in
    parseStates rest startState trans dfa (concat output parsedFirst)
end

-- Find the Starting State ID
recursive
let startID = lam states. lam startState. lam dfa.
    let first = head states in
    let rest = tail states in
    if (dfa.eqs startState first) then (strJoin "" ["startID = '", (int2string first.id) , "',\n"])
    else
    startID rest startState dfa
end

-- Formatting transitions
recursive
let parseTransitions = lam trans. lam dfa. lam output.
    if(eqi (length trans) 0) then output
    else
    let first = head trans in
    let rest = tail trans in
    let parsedFirst = [" {from: '", (int2string (first.0).id), "', to: '" ,(int2string (first.1).id) , "', label: '" , (dfa.l2s first.2) , "'},\n"] in
    let parsedFirst = strJoin "" parsedFirst in
    parseTransitions rest dfa (concat output parsedFirst)
end

-- Getting the input path parsed
recursive
let parseInputPath = lam path. lam output.
    if(eqi (length path) 0) then output
    else
    let first = head path in
    let rest = tail path in
    if(eqi first (negi 2)) then (concat output "'not accepted'")
    else
    if(eqi first (negi 3)) then (concat output "'denied'")
    else
    parseInputPath rest (strJoin "" [output,"'",(int2string first),"'", ","])
    
end

-- Parse input-line
recursive
let parseInput = lam input. lam output. lam dfa.
    if(eqi (length input) 0) then output
    else
    let first = head input in
    let rest = tail input in
    let output = strJoin "" [output,"'" ,(dfa.l2s first) , "',"] in
    parseInput rest output dfa
end

-- Parse a DFA to JS code and visualize
let dfaVisual = lam dfa. lam input.
    let js_code = strJoin "" [
    "let activeStates = [",
    (parseInputPath (makeInputPath input dfa dfa.startState) ""),
    "];\n",
    "let input = [",
    (parseInput input "" dfa),
    "];\n",
    "let inputModel = new DFA(
    rankDirection = 'LR', \n nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, \n nodes = [\n",
    (parseStates (dfaGetStates dfa) dfa.startState (dfaGetTransitions dfa) dfa ""),
    "], \n ",
    (strJoin "" ["startID = '", (int2string dfa.startState.id) , "',\n"]),
    "acceptedIDs = [",
    (strJoin "" (map (lam s. strJoin "" ["'", (int2string s.id), "',"]) dfa.acceptStates)),
    "],\n",
    "transistions = [\n",
    (parseTransitions (dfaGetTransitions dfa) dfa ""),
    "] \n );\n"] in
    js_code


let dfaVisualNoInput = lam dfa.
    dfaVisual dfa ""

mexpr
let alfabeth = ['0','1'] in
let states = [1,2,3] in
let transitions = [(1,2,'0'),(2,3,'1'),(3,1,'0')] in
let startState = 1 in
let acceptStates = [1] in
let input = "010" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqi eqchar int2string (lam b. [b]) in
let output = dfaVisual newDfa input in
print output

