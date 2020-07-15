include "string.mc"
include "map.mc"
include "dfa.mc"
include "model.mc"

-- Formatting the states
recursive
let parseStates = lam states. lam startState. lam dfa. lam output. lam state2str.
    if (eqi (length states) 0) then output
    else
    let first = head states in
    let rest = tail states in
    let parsedFirst = strJoin "" [
    "\t\t\t\t\t{\"name\":\"",
    (state2str first),
    "\"},\n"] in
    parseStates rest startState dfa (concat output parsedFirst) state2str
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
let parseTransitions = lam trans. lam dfa. lam state2str.
    if (eqi (length trans) 0) then "" else
    let first = head trans in
    let parsedFirst = [" \t\t\t\t\t{\"from\": \"", (state2str (first.0)), "\", \"to\": \"" ,(state2str (first.1)) , "\", \"label\": \"" , (first.2) , "\"},\n"] in
    if(eqi (length trans) 1) then
    strJoin "" parsedFirst
    else
    let second = head (tail trans) in
    if (eqTrans (dfaGetEqv dfa) first second) then parseTransitions (join [[(first.0,first.1,join [first.2,second.2])], (tail (tail trans))]) dfa state2str
    else 
    join [strJoin "" parsedFirst, parseTransitions (tail trans) dfa state2str]
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
let parseInput = lam input. lam output. lam dfa. lam label2str.
    if(eqi (length input) 0) then output
    else
    let first = head input in
    let rest = tail input in
    let output = strJoin "" [output,"\"" ,(label2str first) , "\","] in
    parseInput rest output dfa label2str
end

let tab = lam n. strJoin "" (unfoldr (lam b. if eqi b n then None () else Some ("\t", addi b 1)) 0)

-- Parse a DFA to JS code and visualize
let dfaVisual = lam dfa. lam input. lam state2str. lam label2str.
    let transitions = map (lam x. (x.0,x.1,label2str x.2)) (dfaTransitions dfa) in
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
    (parseInput input "" dfa label2str),
    "],\n",
    "\t\t\t\t\"configurations\" : [",
    (parseInputPath (makeInputPath input dfa dfa.startState) "" state2str),
    "],\n",
    "\t\t\t\t\"state\" : ",
    "\"",dfaAcceptedInput input dfa,"\"",
    ",\n\t\t\t},\n",
    "\t\t\t\"model\" : {\n",
    "\t\t\t\t\"states\" : [\n",parseStates (dfaStates dfa) dfa.startState dfa "" state2str ,"\t\t\t\t],\n",
    "\t\t\t\t\"transitions\" : [\n", (parseTransitions transitions dfa state2str) ,
    "\t\t\t\t], \n",
    (strJoin "" ["\t\t\t\t\"startID\" : \"", (state2str dfa.startState) , "\",\n"]),
    "\t\t\t\t\"acceptedIDs\" : [",
    (strJoin "" (map (lam s. strJoin "" ["\"", (state2str s), "\","]) dfa.acceptStates)),
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


let visualize = lam models.
    let models = strJoin "" (
        map (lam model. 
            match model with Digraph(model,vertex2str,edge2str) then
                digraphVisual model vertex2str edge2str
            else match model with DFA(model,input,state2str,label2str) then
                dfaVisual model input state2str label2str
            else match model with Graph(model,vertex2str,edge2str) then
                digraphVisual model vertex2str edge2str
                -- change the name of the function above
            else match model with NFA(model,input,state2str,label2str) then
                dfaVisual model input state2str label2str
                -- change the name of the function above
            else error "unknown type") models) in
    print (strJoin "" ["let data = {\n",
                        "\t\"models\": [\n",
                        models,
                        "]\n}\n"])

mexpr

let alfabeth = [0,1,2] in
let states = [1,2,3] in
let transitions = [(1,2,0),(3,1,0),(1,2,1),(2,3,1),(1,2,2),(3,1,1)] in
let startState = 1 in
let acceptStates = [1] in
let input = [0,1,0] in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqi eqi in
let model = DFA(newDfa, input, int2string, int2string) in
let output = visualize [model] in
print output
