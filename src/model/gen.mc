include "string.mc"
include "map.mc"
include "dfa.mc"
include "nfa.mc"
include "btree.mc"

-- Formatting the states
recursive
let parseStates = lam states. lam startState. lam dfa. lam output. 
    if (eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    let parsedFirst = strJoin "" [
    "\t\t\t\t\t{\"name\":\"",
    (dfa.s2s first),
    "\"},\n"] in
    parseStates rest startState dfa (concat output parsedFirst)
end


-- Traversing the tree to format the states
recursive
let parseBTreeStates = lam btree. lam n2s. lam output.
    match btree with BTree t then
    parseBTreeStates t.0 t.1 ""
    else match btree with Nil () then
    output
    else match btree with Leaf v then strJoin "" [output, "\t\t\t\t\t{\"name\":\"", (n2s v), "\"},\n"]
    else match btree with Node n then
    let output =  strJoin "" [output, "\t\t\t\t\t{\"name\":\"", (n2s n.0), "\"},\n"] in
    let output = parseBTreeStates n.1 n2s output in
    let output = parseBTreeStates n.2 n2s output in
    output
    else "Error, incorrect binary tree"
end

-- Traversing the tree to format the transitions (edges)
recursive
let parseBTreeEdges = lam btree. lam n2s. lam from. lam output.
    match btree with BTree t then
    (
    match t.0 with Node n then
    let output = parseBTreeEdges n.1 t.1 n.0 "" in
    parseBTreeEdges n.2 t.1 n.0 output
    else ""
    )
    else match btree with Nil () then
    output
    else match btree with Leaf v then
    strJoin "" [output, " \t\t\t\t\t{\"from\": \"", (n2s from), "\", \"to\": \"" ,(n2s v) , "\"},\n"]
    else match btree with Node n then
    let output = strJoin "" [output, " \t\t\t\t\t{\"from\": \"", (n2s from) , "\", \"to\": \"" , (n2s n.0) , "\"},\n"] in
    let output = parseBTreeEdges n.1 n2s n.0 output in
    let output = parseBTreeEdges n.2 n2s n.0 output in
    output
    
    else "Wrong input"
end


let parseVertices = lam vertices. lam v2s.
        strJoin ""(map (lam x. strJoin "" [
            "\t\t\t\t\t{\"id\": \"",
            int2string 0 -- placeholder id
            ,",",
            "\", \"label\":\"",
            v2s x,
            "\"},\n"
        ]) vertices)

-- Find the Starting State ID
recursive
let startID = lam states. lam startState. lam dfa.
    let first = head states in
    let rest = tail states in
    if (dfa.eqs startState first) then (strJoin "" ["startID = '", (int2string first.id) , "',\n"])
    else
    startID rest startState dfa
end

let eqTrans = lam eq. lam l. lam r. if and (eq (l.0) (r.0)) (eq (l.1) (r.1)) then true else false
let compTrans = lam trans. lam l. lam r. 
    let l0 = (muli (muli 2 (length trans)) (l.0)) in
    let l1 = (muli (length trans) (l.1)) in
    let l2 = string2int (l.2) in
    let r0 = (muli (muli 2 (length trans)) (r.0)) in
    let r1 = (muli (length trans) (r.1)) in
    let r2 = string2int (r.2) in
    let first = addi l0 (addi l1 (if (lti r2 l2) then 1 else 0)) in
    let snd = addi r0 (addi r1 (if (lti l2 r2) then 1 else 0)) in
    subi first snd

-- parse transitions and squash transitions between the same states.
recursive
let parseTransitions = lam trans. lam dfa.
    if (eqi (length trans) 0) then "" else
    let first = head trans in
    let parsedFirst = [" \t\t\t\t\t{\"from\": \"", (dfa.s2s (first.0)), "\", \"to\": \"" ,(dfa.s2s (first.1)) , "\", \"label\": \"" , (first.2) , "\"},\n"] in
    if(eqi (length trans) 1) then
    strJoin "" parsedFirst
    else
    let second = head (tail trans) in
    if (eqTrans (dfaGetEqv dfa) first second) then parseTransitions (join [[(first.0,first.1,join [first.2,second.2])], (tail (tail trans))]) dfa
    else 
    join [strJoin "" parsedFirst, parseTransitions (tail trans) dfa]
end

-- Getting the input path parsed
recursive
let parseInputPath = lam path. lam output. lam state2string.
    if(eqi (length path) 0) then output
    else
    let first = head path in
    let rest = tail path in
    parseInputPath rest (strJoin "" [output,"\"",(state2string first),"\"", ","]) state2string
end

-- Parse input-line
recursive
let parseInput = lam input. lam output. lam dfa.
    if(eqi (length input) 0) then output
    else
    let first = head input in
    let rest = tail input in
    let output = strJoin "" [output,"\"" ,(dfa.l2s first) , "\","] in
    parseInput rest output dfa
end


let tab = lam n. strJoin "" (unfoldr (lam b. if eqi b n then None () else Some ("\t", addi b 1)) 0)
    


-- Parse a DFA to JS code and visualize
let dfaVisual = lam model.
    let dfa = model.model in
    let input = model.input in
    let transitions = map (lam x. (x.0,x.1,dfa.l2s x.2)) (dfaTransitions dfa) in
    let tabCount = 2 in
    let first = strJoin "" [tab tabCount,
    "{\n"] in
    let tabCount = addi 1 tabCount in
    let snd = strJoin "" [tab tabCount,"\"type\" : \"dfa\",\n",
    tab tabCount,"\"simulation\" : {\n"] in
    let js_code = strJoin "" [
        first,
    snd,
    "\t\t\t\t\"input\" : [",
    (parseInput input "" dfa),
    "],\n",
    "\t\t\t\t\"configurations\" : [",
    (parseInputPath (makeInputPath input dfa dfa.startState) "" dfa.s2s),
    "],\n",
    "\t\t\t\t\"state\" : ",
    "\"",dfaAcceptedInput input dfa,"\"",
    ",\n\t\t\t},\n",
    "\t\t\t\"model\" : {\n",
    "\t\t\t\t\"states\" : [\n",parseStates (dfaStates dfa) dfa.startState dfa "" ,"\t\t\t\t],\n",
    "\t\t\t\t\"transitions\" : [\n", (parseTransitions transitions dfa) ,
    "\t\t\t\t], \n",
    (strJoin "" ["\t\t\t\t\"startID\" : \"", (dfa.s2s dfa.startState) , "\",\n"]),
    "\t\t\t\t\"acceptedIDs\" : [",
    (strJoin "" (map (lam s. strJoin "" ["\"", (dfa.s2s s), "\","]) dfa.acceptStates)),
    "],\n\t\t\t}\n\t\t},\n\t"] in
    js_code

let digraphVisual = lam model.
    let digraph = model.model in
    let edges = digraphEdges digraph in
    strJoin "" [
    "\t{\n",
    "\t\t\t\"type\" : \"digraph\",\n",
    "\t\t\t\"model\" : {\n",
    "\t\t\t\t\"states\" : [\n[",(parseVertices (digraphVertices digraph) int2string) ,"\n\t\t\t\t],\n",
    "\t\t\t},\n",
    "],\n\t\t},\n\t"]

-- Format NFA to JS code for visualizing
let nfaVisual = lam model.
    let nfa = model.model in
    let input = model.input in
    let transitions = map (lam x. (x.0,x.1,nfa.l2s x.2)) (nfaTransitions nfa) in
    let tabCount = 3 in
    let snd = strJoin "" [tab 3,"\"type\" : \"nfa\",\n"] in
    let first = strJoin "" [tab (subi tabCount 1),
    "{\n"] in
    let tabCount = addi 1 tabCount in
    let js_code = strJoin "" [
        first,
	snd,
	"\t\t\t\"model\" : {\n",
	"\t\t\t\t\"states\" : [\n",parseStates (nfaStates nfa) nfa.startState nfa "" ,"\t\t\t\t],\n",
	"\t\t\t\t\"transitions\" : [\n", (parseTransitions transitions nfa) ,
	"\t\t\t\t], \n",
	(strJoin "" ["\t\t\t\t\"startID\" : \"", (nfa.s2s nfa.startState) , "\",\n"]),
    	"\t\t\t\t\"acceptedIDs\" : [",
    (strJoin "" (map (lam s. strJoin "" ["\"", (nfa.s2s s), "\","]) nfa.acceptStates)),
    "],\n\t\t\t}\n\t\t},\n\t"] in
    js_code

-- Format graph to JS code for visualizing
let graphVisual = lam model.
    "TODO - create this method"

-- Format Tree to JS code for visualizing
let btreeVisual = lam model.
     let btree = model.model in
     let tabCount = 3 in
     let snd = strJoin "" [tab 3, "\"type\" : \"btree\",\n"] in
     let first = strJoin "" [tab 2, "{\n"] in
     let tabCount = addi 1 tabCount in
     let js_code = strJoin "" [
     first,
     snd,
     "\t\t\t\"model\" : {\n",
     "\t\t\t\t\"nodes\" : [\n",(parseBTreeStates btree "" "") ,"\t\t\t\t],\n",
     "\t\t\t\t\"edges\" : [\n", (parseBTreeEdges btree "" 0 "") ,
     "\t\t\t\t], \n",
     "\n\t\t\t}\n\t\t},\n\t"
     ] in
     js_code
    


let visualize = lam models.
    let models = strJoin "" (map (lam x.
    if(setEqual eqchar x.modelType "dfa") then dfaVisual x else
    if(setEqual eqchar x.modelType "digraph") then digraphVisual x else
    if(setEqual eqchar x.modelType "nfa") then nfaVisual x else
    if(setEqual eqchar x.modelType "btree") then btreeVisual x else
    if(setEqual eqchar x.modelType "graph") then graphVisual x else
    "") models) in
    strJoin "" [
    "let data = {\n",
    "\t\"models\": [\n",
    models, 
    "]\n}\n"]


mexpr

let alfabeth = [0,1,2] in
let states = [1,2,3] in
let transitions = [(1,2,0),(3,1,0),(1,2,1),(2,3,1),(1,2,2),(3,1,1)] in
let startState = 1 in
let acceptStates = [1] in
let input = [0,1,0] in
let newDfa = {modelType="dfa",model=dfaConstr states transitions alfabeth startState acceptStates eqi eqi int2string int2string,input=input} in
let output = visualize [newDfa] in
print output
