-- This file provides functions that generates a JSON object of models defined in model.mc

include "string.mc"
include "map.mc"
include "model.mc"
include "modelDot.mc"

let getDisplayName = lam name. lam displayNames. lam v2s.
    let vertex_display = (find (lam v. 
            match v with (a,b) then 
                setEqual eqchar (v2s a) name
            else false
	    ) displayNames) in
    match vertex_display with Some (a,b) then b else name

-- format vertex
let formatVertex = lam name. lam displayName.
    foldl concat [] ["{\"name\":\"", name, "\", \"displayName\": \"",displayName,"\" }\n"]

-- format edge
let formatEdge = lam from. lam to. lam label.
    foldl concat [] ["{\"from\": \"", from, "\", \"to\": \"" , to, "\", \"label\": \"" , label , "\"}\n"]

-- format vertices
let formatVertices = lam vertices.  lam vertex2str. lam eqv. lam displayNames.
    concat
       (let vertex_string = (vertex2str (head vertices)) in
        let vertex_display = getDisplayName vertex_string displayNames vertex2str in
       foldl concat [] ["{\"name\":\"", vertex_string, "\", \"displayName\": \"",vertex_display,"\" }\n"])
       (foldl (lam output. lam vertex.
        let vertex_string = (vertex2str vertex) in
        let vertex_display = getDisplayName vertex_string displayNames vertex2str in
       strJoin "" [output, ",", (formatVertex vertex_string vertex_display)]
    ) "" (tail vertices))
 
-- format edges and squash edges between the same nodes.
recursive
let formatAndSquashEdges = lam trans. lam v2s. lam eqv.
    if (eqi (length trans) 0) then "" 
    else
    let first = head trans in
    let formatedEdge = concat "," (formatEdge (v2s (first.0)) (v2s (first.1)) (first.2)) in
    if(eqi (length trans) 1) then formatedEdge
    else
        let second = head (tail trans) in
        if (and (eqv (first.0) (second.0)) (eqv (first.1) (second.1))) 
        then formatAndSquashEdges (join [[(first.0,first.1,join [first.2,second.2])], (tail (tail trans))]) v2s eqv
        else join [formatedEdge, formatAndSquashEdges (tail trans) v2s eqv]
end

-- only for head
let formatEdgeHead = lam from. lam to. lam label.
    strJoin "" ["{\"from\": \"", from, "\", \"to\": \"" , to, "\", \"label\": \"" , label , "\"}\n"]

-- format all edges into printable string
let formatEdges = lam edges. lam v2s. lam l2s. lam eqv.
    let edges_string = map (lam x. (x.0,x.1,l2s x.2)) (tail edges) in
    concat (formatEdgeHead (v2s (head edges).0) (v2s (head edges).1) (l2s (head edges).2)) (formatAndSquashEdges edges_string v2s eqv)

-- Formatting the states
let formatStates = lam states. lam state2str. lam eqv. lam displayNames.
    formatVertices states state2str eqv displayNames

-- format transitions into printable string
let formatTransitions = lam trans. lam v2s. lam l2s. lam eqv.
    formatEdges trans v2s l2s eqv
    
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
let nfaVisual = lam dot. lam nfa. lam input. lam s2s. lam l2s. lam nfaType. lam displayNames. lam id.
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
let formatGraph = lam dot. lam nodes. lam edges. lam graphType. lam id.
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
let graphVisual = lam dot. lam model. lam displayNames. lam vertex2str. lam edge2str. lam graphType. lam id.
    let nodes = formatVertices (graphVertices model) vertex2str model.eqv displayNames in
    let edges = formatEdges (graphEdges model) vertex2str edge2str model.eqv in
    formatGraph dot nodes edges graphType id

-- format a tree to JS code for visualizing
let treeVisual = lam dot. lam model. lam v2str. lam displayNames. lam id.
    let eqv = model.eqv in
    let vertices = formatVertices (treeVertices model) v2str eqv displayNames in
    let edges = map (lam e. formatEdge (v2str e.0) (v2str e.1) e.2) (treeEdges model ()) in
    let edges = foldl (lam edges. lam e. strJoin "," [edges, e]) (head edges) (tail edges) in
    formatGraph dot vertices edges "tree" id

-- make all models into string object
let visualize = lam models.
    let ids = mapi (lam i. lam x. i) models in
    let models = zipWith (lam x. lam y. (x,y)) models ids in
    let models = strJoin ",\n" (
        map (lam model_tup.
	    let model = model_tup.0 in
	    let id = model_tup.1 in
	    match model with Digraph(digraph,vertex2str,edge2str,displayNames) then
            let dot = modelGetDot model "LR" in
            graphVisual dot digraph displayNames vertex2str edge2str "digraph" id
        else match model with DFA(dfa,input,state2str,label2str,displayNames) then
            let dot = modelGetDot model "LR" in
            dfaVisual dot dfa input state2str label2str "dfa" displayNames id
        else match model with Graph(graph,vertex2str,edge2str,displayNames) then
            let dot = modelGetDot model "LR" in
            graphVisual dot graph displayNames vertex2str edge2str "graph" id
        else match model with NFA(nfa,input,state2str,label2str,displayNames) then
            let dot = modelGetDot model "LR" in
            nfaVisual dot nfa input state2str label2str "nfa" displayNames id
        else match model with BTree(btree, node2str,displayName) then
            let dot = modelGetDot model "TD" in
            treeVisual dot btree node2str displayName id
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
