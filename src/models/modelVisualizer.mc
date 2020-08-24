-- This file provides functions that generates a JSON object of models defined in model.mc

include "string.mc"
include "model.mc"
include "modelDot.mc"

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
let nfaVisual = lam nfa. lam input. lam s2s. lam l2s. lam nfaType. lam id. lam direction. lam vSettings.
    let simulation = nfaFormatSimulation nfa input s2s l2s in
    let dot = nfaGetDot nfa s2s l2s id direction vSettings in
    formatModel dot nfaType id simulation

let dfaVisual = nfaVisual 

-- format a graph to JS code for visualizing
let graphVisual = lam graph. lam v2str. lam l2str. lam graphType. lam id. lam direction. lam vSettings.
    let dot = graphGetDot graph v2str l2str id direction graphType vSettings in
    formatModel dot graphType id ""

-- format a tree to JS code for visualizing
let treeVisual = lam btree. lam v2str. lam id. lam direction. lam vSettings.
    let dot = btreeGetDot btree v2str id direction vSettings in
    formatModel dot "tree" id ""

-- format a circuit to JS code for visualizing
let circVisual = lam circuit. lam id.
    let dot = circGetDot circuit id in
    formatModel dot "circuit" id ""

let formatWithId = lam model. lam id.
    match model with Digraph(digraph,vertex2str,edge2str,direction,vSettings) then
        graphVisual digraph vertex2str edge2str "digraph" id direction vSettings
    else match model with DFA(dfa,input,state2str,label2str,direction,vSettings) then
        dfaVisual dfa input state2str label2str "dfa" id direction vSettings
    else match model with Graph(graph,vertex2str,edge2str,direction,vSettings) then
        graphVisual graph vertex2str edge2str  "graph" id direction vSettings
    else match model with NFA(nfa,input,state2str,label2str,direction,vSettings) then
        nfaVisual nfa input state2str label2str "nfa" id direction vSettings
    else match model with BTree(btree, node2str,direction,vSettings) then
        treeVisual btree node2str id direction vSettings
    else match model with Circuit(circuit) then
        circVisual circuit id
    else error "Unknown model type"

-- format a list of models into a string representation for visualization
let formatModels = lam models.
    let ids = mapi const models in
    let formattedModels = zipWith formatWithId models ids in
    join ["{\"models\": [\n", strJoin ",\n" formattedModels, "]\n}\n"]

let visualize = compose print formatModels
