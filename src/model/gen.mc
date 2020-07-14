include "string.mc"
include "map.mc"
include "dfa.mc"

-- Formatting the states
recursive
let parseStates = lam states. lam startState. lam dfa. lam output. 
    if (eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    let parsedFirst = strJoin "" [
    "{\"name\":\"",
    (dfa.s2s first),
    "\"},\n"] in
    parseStates rest startState dfa (concat output parsedFirst)
end

let parseVertices = lam vertices. lam v2s.
        strJoin ""(map (lam x. strJoin "" [
            "{\"id\": \"",
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
    let parsedFirst = ["{\"from\": \"", (dfa.s2s (first.0)), "\", \"to\": \"" ,(dfa.s2s (first.1)) , "\", \"label\": \"" , (first.2) , "\"},\n"] in
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

recursive
let fixTabs = lam inpt. lam t.
    if (eqi (length inpt) 0 ) then ""
    else if (eqi (length inpt) 1) then inpt
    else
    let first = head inpt in
    let snd = head (tail inpt) in
    let rest = tail inpt in
    if (eqchar first '\n') then 
        if or (eqchar snd '}') (eqchar snd ']') then concat (strJoin "" [[first],tab (subi t 1)]) (fixTabs rest t) 
        else concat (strJoin "" [[first],tab t]) (fixTabs rest t) 
    else if or (eqchar (first) '{') (eqchar first '[') then concat [first] (fixTabs rest (addi t 1))
    else if (or (eqchar (first) '}') (eqchar (first) ']')) then concat [first] (fixTabs rest (subi t 1)) 
    else concat [first] (fixTabs rest t) 
end

-- Parse a DFA to JS code and visualize
let dfaVisual = lam model.
    let dfa = model.model in
    let input = model.input in
    let transitions = map (lam x. (x.0,x.1,dfa.l2s x.2)) (dfaTransitions dfa) in
    let js_code = strJoin "" ["\n",
        "{\n",
        "\"type\" : \"dfa\",\n",
        "\"simulation\" : {\n",
        "\"input\" : [",
        (parseInput input "" dfa),
        "],\n",
        "\"configurations\" : [",
        (parseInputPath (makeInputPath input dfa dfa.startState) "" dfa.s2s),
        "],\n",
        "\"state\" : ",
        "\"",dfaAcceptedInput input dfa,"\"",
        ",\n",
        "},\n",
        "\"model\" : {\n",
        "\"states\" : [\n",parseStates (dfaStates dfa) dfa.startState dfa "" ,"],\n",
        "\"transitions\" : [\n", (parseTransitions transitions dfa) ,
        "], \n",
        (strJoin "" ["\"startID\" : \"", (dfa.s2s dfa.startState) , "\",\n"]),
        "\"acceptedIDs\" : [",(strJoin "" (map (lam s. strJoin "" ["\"", (dfa.s2s s), "\","]) dfa.acceptStates)),
        "],\n",
        "}\n",
        "},\n"
    ] in
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

let visualize = lam models.
    let models = strJoin "" (map (lam x. if(setEqual eqchar x.modelType "dfa") then dfaVisual x else digraphVisual x) models) in
    fixTabs (strJoin "" [
    "let data = {\n",
    "\t\"models\": [\n",
    models, 
    "]\n}\n"]) 0

--Didn't figure out function overloading
--If there is no input
let dfaVisualNoInput = lam dfa.
    dfaVisual dfa ""

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