-- This file provides functions that generates a JSON object of models defined in model.mc

include "string.mc"
include "map.mc"
include "model.mc"
include "modelDot.mc"

let displayNamesToOptions = lam displayNames. 
    map (lam x. match x with (x1,x2) then (x1, foldl concat [] ["label=\\\"",x2, "\\\""]) else x) displayNames

-- Getting the input path formated
let formatInputPath = lam path. lam state2string.
    concat ((foldl (lam output. lam elem.
            foldl concat [] [output,
            "{\"state\": \"",state2string elem.state,
            "\",\"status\": \"", elem.status, "\"",
            ",\"index\": ",int2string elem.index,"}\n"
    	    ]
	    ) "" [(head path)]))
	    (foldl (lam output. lam elem.
	    foldl concat [] [output,
            ",{\"state\": \"",state2string elem.state,
            "\",\"status\": \"", elem.status, "\"",
            ",\"index\": ",int2string elem.index,"}\n"
	    ]
	    ) "" (tail path))

-- format input-line
let formatInput = lam input. lam label2str.
    concat (strJoin "" ["\"", (label2str (head input)), "\""])
    (foldl (lam output. lam elem.
        foldl concat [] [output,",\"" ,label2str elem, "\""]
    ) "" (tail input))

-- (any (lam x. or (eqchar x '{') (eqchar x '[')) first)
-- format NFA to JS code for visualizing


-- format nfa simulation to JS code
let nfaFormatSimulation = lam nfa. lam input. lam s2s. lam l2s. 
    match input with "" then "" else foldl concat [] 
        ["\"simulation\" : {\n",
            " \"input\" : [", (formatInput input l2s),"],\n",
            " \"configurations\" : [\n", 
            (formatInputPath (nfaMakeInputPath (negi 1) nfa.startState input nfa) s2s),
            "]\n",
        "},\n "]

-- format a model to JS code
let formatModel = lam dot. lam graphType. lam id. lam simulation.
    foldl concat [] [
        "{\n\"type\" : \"",graphType,
        "\",\n \"id\" : ",int2string id,",\n",
        simulation,
        " \"model\" :",
            "\"",dot, "\"\n" ,
        "}\n"
	]

-- format a nfa to JS code for visualizing
let nfaVisual = lam nfa. lam input. lam s2s. lam l2s. lam nfaType. lam displayNames. lam id. lam direction.
    let simulation = nfaFormatSimulation nfa input s2s l2s in
    let dot = nfaGetDot nfa s2s l2s direction id (displayNamesToOptions displayNames) in
    formatModel dot nfaType id simulation

let dfaVisual = nfaVisual 

-- format a graph to JS code for visualizing
let graphVisual = lam graph. lam v2str. lam l2str. lam graphType. lam id. lam displayNames. lam direction.
    let dot = graphGetDot graph v2str l2str direction id graphType (displayNamesToOptions displayNames) in
    formatModel dot graphType id ""

-- format a tree to JS code for visualizing
let treeVisual = lam btree. lam v2str. lam displayNames. lam id. lam direction.
    let dot = btreeGetDot btree v2str direction id (displayNamesToOptions displayNames) in
    formatModel dot "tree" id ""

let circVisual = lam circuit. lam comp2str. lam id.
    let dot = circGetDot circuit comp2str id [] in
    formatModel dot "graph" id ""

-- make all models into string object
let visualize = lam models.
    let ids = mapi (lam i. lam x. i) models in
    let models = zipWith (lam x. lam y. (x,y)) models ids in
    let models = strJoin ",\n" (
        map (lam model_tup.
	    let model = model_tup.0 in
	    let id = model_tup.1 in
	    match model with Digraph(digraph,vertex2str,edge2str,direction,displayNames) then
            graphVisual digraph vertex2str edge2str "digraph" id displayNames direction
        else match model with DFA(dfa,input,state2str,label2str,direction,displayNames) then
            dfaVisual dfa input state2str label2str "dfa" displayNames id direction 
        else match model with Graph(graph,vertex2str,edge2str,direction,displayNames) then
            graphVisual graph vertex2str edge2str  "graph" id displayNames direction
        else match model with NFA(nfa,input,state2str,label2str,direction,displayNames) then
            nfaVisual nfa input state2str label2str "nfa" displayNames id direction
        else match model with BTree(btree, node2str,direction,displayName) then
            treeVisual btree node2str displayName id direction
        else match model with Circuit(circuit, comp2str) then
            circVisual circuit comp2str id
        else error "unknown type") models
    ) in
    print (foldl concat [] ["{\"models\": [\n", models, "]\n}\n"])
                        
mexpr
let states = [1,2,3] in
let transitions = [(1,2,'0'),(3,1,'0'),(1,2,'1'),(2,3,'1'),(1,2,'2'),(3,1,'1')] in
let startState = 1 in
let acceptStates = [1] in
let input = "010" in
let newDfa = dfaConstr states transitions startState acceptStates eqi eqchar in
let model = DFA(newDfa, input, int2string, lam b. [b],"LR",[]) in
visualize [model]
