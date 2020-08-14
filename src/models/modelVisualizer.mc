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
let nfaVisual = lam nfa. lam input. lam s2s. lam l2s. lam nfaType. lam displayNames. lam id.
    let dot = nfaGetDot nfa s2s l2s "LR" (displayNamesToOptions displayNames) in
    foldl concat [] ["{\n ",
        "\"type\" : \"", nfaType,"\",\n ",
	"\"id\" : ",
	int2string id,
	",\n",
        "\"simulation\" : {\n",
            " \"input\" : [", (formatInput input l2s),"],\n",
            " \"configurations\" : [\n", 
            (formatInputPath (nfaMakeInputPath (negi 1) nfa.startState input nfa) s2s),
            "]\n",
        "},\n ",
        "\"model\" :",
            "\"",dot,"\"\n",
    "}"
]

let dfaVisual = nfaVisual 

-- format a graph to JS code
let formatGraph = lam dot. lam graphType. lam id.
    foldl concat [] ["{\n\"type\" : \"",
        graphType,
        "\",\n \"id\" : ",
        int2string id,
        ",\n",
        " \"model\" :",
            "\"",dot, "\"\n" ,
        "}\n"
	]

-- format a graph to JS code for visualizing
let graphVisual = lam graph. lam v2str. lam l2str. lam graphType. lam id. lam displayNames.
    let dot = graphGetDot graph  v2str l2str "LR" graphType (displayNamesToOptions displayNames) in
    formatGraph dot graphType id

-- format a tree to JS code for visualizing
let treeVisual = lam btree. lam v2str. lam displayNames. lam id.
    let dot = btreeGetDot btree v2str "TD" (displayNamesToOptions displayNames) in
    formatGraph dot "tree" id

-- make all models into string object
let visualize = lam models.
    let ids = mapi (lam i. lam x. i) models in
    let models = zipWith (lam x. lam y. (x,y)) models ids in
    let models = strJoin ",\n" (
        map (lam model_tup.
	    let model = model_tup.0 in
	    let id = model_tup.1 in
	    match model with Digraph(digraph,vertex2str,edge2str,displayNames) then
            graphVisual digraph vertex2str edge2str "digraph" id displayNames
        else match model with DFA(dfa,input,state2str,label2str,displayNames) then
            dfaVisual dfa input state2str label2str "dfa" displayNames id
        else match model with Graph(graph,vertex2str,edge2str,displayNames) then
            graphVisual graph vertex2str edge2str  "graph" id displayNames
        else match model with NFA(nfa,input,state2str,label2str,displayNames) then
            nfaVisual nfa input state2str label2str "nfa" displayNames id
        else match model with BTree(btree, node2str,displayName) then
            treeVisual btree node2str displayName id
        else error "unknown type") models
    ) in
    print (foldl concat [] ["{\"models\": [\n", models, "]\n}\n"])
                        
mexpr
let alfabeth = ['0','1','2'] in
let states = [1,2,3] in
let transitions = [(1,2,'0'),(3,1,'0'),(1,2,'1'),(2,3,'1'),(1,2,'2'),(3,1,'1')] in
let startState = 1 in
let acceptStates = [1] in
let input = "010" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqi eqchar in
let model = DFA(newDfa, input, int2string, lam b. [b],[]) in
visualize [model]