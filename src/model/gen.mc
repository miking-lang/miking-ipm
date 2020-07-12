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
    let parsedFirst = strJoin "" [ "\t\t\t\t\t{\"id\": \"",
    (int2string first.id),
    "\", \"label\":\"",
    (dfa.s2s first.data),
    "\"},\n"] in
    parseStates rest startState dfa (concat output parsedFirst)
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

let eqTrans = lam eq. lam l. lam r. if and (eq (l.0).id (r.0).id) (eq (l.1).id (r.1).id) then true else false
let compTrans = lam trans. lam l. lam r. 
    let l0 = (muli (muli 2 (length trans)) (l.0).id) in
    let l1 = (muli (length trans) (l.1).id) in
    let l2 = string2int (l.2) in
    let r0 = (muli (muli 2 (length trans)) (r.0).id) in
    let r1 = (muli (length trans) (r.1).id) in
    let r2 = string2int (r.2) in
    let first = addi l0 (addi l1 (if (lti r2 l2) then 1 else 0)) in
    let snd = addi r0 (addi r1 (if (lti l2 r2) then 1 else 0)) in
    subi first snd

-- parse transitions and squash transitions between the same states.
recursive
let parseTransitions = lam trans.
    if (eqi (length trans) 0) then "" else
    if(eqi (length trans) 1) then
    let first = head trans in
    let parsedFirst = [" \t\t\t\t\t{\"from\": \"", (int2string (first.0).id), "\", \"to\": \"" ,(int2string (first.1).id) , "\", \"label\": \"" , (first.2) , "\"},\n"] in
    strJoin "" parsedFirst
    else
    let first = head trans in
    let second = head (tail trans) in
    if (eqTrans eqi first second) then parseTransitions (join [[(first.0,first.1,join [first.2,second.2])], (tail (tail trans))])
    else 
    let parsedFirst = [" \t\t\t\t\t{\"from\": \"", (int2string (first.0).id), "\", \"to\": \"" ,(int2string (first.1).id) , "\", \"label\": \"" , (first.2) , "\"},\n"] in
    let parsedFirst = strJoin "" parsedFirst in
    join [parsedFirst, parseTransitions (tail trans)]
end

-- Getting the input path parsed
recursive
let parseInputPath = lam path. lam output.
    if(eqi (length path) 0) then output
    else
    let first = head path in
    let rest = tail path in
    if (eqi (length rest) 0 ) then
        let statusOutput = concat output "],\n \t\t\t\t\"status\":" in
        if(eqi first (negi 1)) then (concat statusOutput "\"not accepted\"")
        else
        if(eqi first 0) then (concat statusOutput "\"stuck\"")
        else (concat statusOutput "\"accepted\"")
    else
    parseInputPath rest (strJoin "" [output,"\"",(int2string first),"\"", ","])
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

-- Parse a DFA to JS code and visualize
let dfaVisual = lam model.
    let dfa = model.model in
    let input = model.input in
    let transitions = map (lam x. (x.0,x.1,dfa.l2s x.2)) (dfaGetTransitions dfa) in
    let js_code = strJoin "" [
    "\t\t{\n",
    "\t\t\t\"type\" : \"dfa\",\n",
    "\t\t\t\"simulation\" : {\n",
    "\t\t\t\t\"input\" : [",
    (parseInput input "" dfa),
    "],\n",
    "\t\t\t\t\"configurations\" : [",
    (parseInputPath (makeInputPath input dfa dfa.startState) ""),
    ",\n",
    "\t\t\t},\n",
    "\t\t\t\"model\" : {\n",
    "\t\t\t\t\"states\" : [\n",parseStates (dfaGetStates dfa) dfa.startState dfa "" ,"\t\t\t\t],\n",
    "\t\t\t\t\"transitions\" : [\n", (parseTransitions (sort (compTrans transitions) transitions)) ,
    "\t\t\t\t], \n",
    (strJoin "" ["\t\t\t\t\"startID\" : \"", (int2string dfa.startState.id) , "\",\n"]),
    "\t\t\t\t\"acceptedIDs\" : [",
    (strJoin "" (map (lam s. strJoin "" ["\"", (int2string s.id), "\","]) dfa.acceptStates)),
    "],\n\t\t\t}\n\t\t},\n\t"] in
    js_code

let visualize = lam models.
    let models = strJoin "" (map dfaVisual models) in
    let h = strJoin "" [
    "let data = {\n",
    "\t\"models\": [\n",
    models, 
    "]\n}\n"] in
    h

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
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqi eqi int2string int2string in
let output = dfaVisual newDfa input in
print output
