include "dfa.mc"
include "string.mc"
include "map.mc"



-- Parsing all the accepted states
recursive
let parseAcceptedStates = lam aStates. lam output. lam map.
    if(eqi (length aStates) 0) then output
    else
    let first = head aStates in
    let rest = tail aStates in
    let output = strJoin "" [output, "'", (int2string (mapLookup eqi first map)) , "',"] in
    parseAcceptedStates rest output map
end

-- Formatting the states
recursive
let parseStates = lam states. lam startState. lam trans. lam map. lam output.
    if (eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    let parsedFirst = strJoin "" [ "{id: '",
    (int2string (mapLookup eqi first map)),
    "', label:'",
    (int2string first),
    "'},\n"] in
    parseStates rest startState trans map (concat output parsedFirst)
end

-- Find the Starting State ID
recursive
let startID = lam states. lam startState. lam map.
    let first = head states in
    let rest = tail states in
    if (eqi startState first) then (strJoin "" ["startID = '", (int2string (mapLookup eqi first map)), "',\n"])
    else
    startID rest startState map
end

-- Formatting transitions
recursive
let parseTransitions = lam trans. lam output. lam map.
    if(eqi (length trans) 0) then output
    else
    let first = head trans in
    let rest = tail trans in
    let parsedFirst = [" {from: '", (int2string (mapLookup eqi first.0 map)), "', to: '" ,(int2string (mapLookup eqi first.1 map)) , "', label: '" , [first.2] , "'},\n"] in
    let parsedFirst = strJoin "" parsedFirst in
    parseTransitions rest (concat output parsedFirst) map
end

-- Parse input-line
recursive
let parseInput = lam input. lam output. lam index.
    if(eqi (length input) index) then output
    else
    let char = get input index in
    let output = strJoin "" [output,"'" , [char] , "',"] in

parseInput input output (addi index 1)
end

-- Parse a DFA to JS code and visualize
let dfaVisual = lam dfa. lam input.
    let mapId = statesGenId (getStates dfa) 0 [] in
    let js_code = strJoin "" [
    "let input = [",
    (parseInput input "" 0),
    "];\n",
    "let inputModel = new DFA(
    rankDirection = 'LR', \n nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, \n nodes = [\n",
    (parseStates (getStates dfa) dfa.startState (getTransitions dfa) mapId ""),
    "], \n ",
    (startID (getStates dfa) dfa.startState mapId),
    "endIDs = [",
    (parseAcceptedStates dfa.acceptStates "" mapId),
    "],\n",
    "transistions = [\n",
    (parseTransitions (getTransitions dfa) "" mapId),
    "] \n );\n"] in
    js_code


--Didn't figure out function overloading
--If there is no input
let dfaVisualNoInput = lam dfa.
    dfaVisual dfa ""

mexpr
let alfabeth = ['1','2'] in
let states = [1,2,3] in
let transitions = [(1,2,'1'),(2,3,'2')] in
let startState = 1 in
let acceptStates = [2,3] in
let input = "01001" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates in
let output = dfaVisual newDfa input in
print output

