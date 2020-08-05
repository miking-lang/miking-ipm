include "string.mc"
include "map.mc"
include "model.mc"


let getDisplayName = lam name. lam displayNames. lam v2s.
    let vertex_display = (find (lam v. 
            match v with (a,b) then 
                if setEqual eqchar (v2s a) name then true
                else false
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

-- Traversing the tree to format the states
recursive
let formatBTreeStates = lam btree. lam n2s. lam output. lam displayNames.
    match btree with BTree t then
        formatBTreeStates t n2s "" displayNames
    else match btree with Nil () then
        output
    else match btree with Leaf v then
    if(setEqual eqchar output "") then
    formatVertex (n2s v) (getDisplayName (n2s v) displayNames n2s)
    else
    strJoin "," [output, formatVertex (n2s v) (getDisplayName (n2s v) displayNames n2s)]
    else match btree with Node n then
        if (setEqual eqchar "" output) then
	let output = formatVertex (n2s n.0) (getDisplayName (n2s n.0) displayNames n2s) in 
        let output = formatBTreeStates n.1 n2s output displayNames in 
        let output = formatBTreeStates n.2 n2s output displayNames in
        output
	else
        let output =  strJoin "," [output, formatVertex (n2s n.0) (getDisplayName (n2s n.0) displayNames n2s)] in
        let output = formatBTreeStates n.1 n2s output displayNames in 
        let output = formatBTreeStates n.2 n2s output displayNames in
        output
    else "Error, incorrect binary tree"
end

-- Traversing the tree to format the transitions (edges)
recursive
let formatBTreeEdges = lam btree. lam n2s. lam from. lam output.
    match btree with BTree t then
        match t with Node n then
            let output = formatBTreeEdges n.1 n2s n.0 "" in
            formatBTreeEdges n.2 n2s n.0 output
        else ""
    else match btree with Nil () then
        output
    else match btree with Leaf v then
    	 if (setEqual eqchar "" output) then
	 formatEdge (n2s from) (n2s v)
	 else
	 strJoin "," [output , formatEdge (n2s from) (n2s v) ""]	
    else match btree with Node n then
    	 if(setEqual eqchar "" output) then
        let output = formatEdge (n2s from) (n2s n.0) "" in
        let output = formatBTreeEdges n.1 n2s n.0 output in
        let output = formatBTreeEdges n.2 n2s n.0 output in
        output
	else
	let output = strJoin "," [output, formatEdge (n2s from) (n2s n.0) ""] in
        let output = formatBTreeEdges n.1 n2s n.0 output in
        let output = formatBTreeEdges n.2 n2s n.0 output in
        output

    else "Wrong input"
end

-- (any (lam x. or (eqchar x '{') (eqchar x '[')) first)
-- format NFA to JS code for visualizing
let nfaVisual = lam nfa. lam input. lam s2s. lam l2s. lam nfaType. lam displayNames. lam id.
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
        "\"model\" : {\n ",
            "\"states\" : [\n",
            (formatStates (getStates nfa) s2s (getEqv nfa) displayNames),
            "],\n ",
            "\"transitions\" : [\n",
            (formatTransitions (getTransitions nfa) s2s l2s (getEqv nfa)),
            "], \n ",
            "\"startState\" : \"", (s2s nfa.startState),"\",\n ",
            "\"acceptedStates\" : [",
	    (strJoin "" ["\"", (s2s (head nfa.acceptStates)), "\""]),
	    foldl concat [] (map (lam s. foldl concat [] [",\"", (s2s s), "\""]) (tail nfa.acceptStates)),"]\n",
        "}\n",
    "}"
]

let dfaVisual = nfaVisual 

-- format a graph to JS code
let formatGraph = lam nodes. lam edges. lam graphType. lam id.
    foldl concat [] ["{\n\"type\" : \"",
	graphType,
	"\",\n \"id\" : ",
	int2string id,
	",\n",
	" \"model\" : {\n \"nodes\" : [\n",
	nodes ,
	"],\n \"edges\" : [\n",
	edges,
	"] \n }\n}"
	]

-- format a graph to JS code for visualizing
let graphVisual = lam model. lam displayNames. lam vertex2str. lam edge2str. lam graphType. lam id.
    let nodes = formatVertices (graphVertices model) vertex2str model.eqv displayNames in
    let edges = formatEdges (graphEdges model) vertex2str edge2str model.eqv in
    formatGraph nodes edges graphType id

-- format a tree to JS code for visualizing
let treeVisual = lam model. lam node2str. lam displayNames. lam id.
    let nodes = formatBTreeStates model node2str "" displayNames in
    let edges = formatBTreeEdges model node2str "" displayNames in 
    formatGraph nodes edges "tree" id

-- make all models into string object
let visualize = lam models.
    let ids = mapi (lam i. lam x. i) models in
    let models = zipWith (lam x. lam y. (x,y)) models ids in
    let models = strJoin ",\n" (
        map (lam model_tup.
	    let model = model_tup.0 in
	    let id = model_tup.1 in
	    match model with Digraph(model,vertex2str,edge2str,displayNames) then
                graphVisual model displayNames vertex2str edge2str "digraph" id
	    else match model with Digraph(model,vertex2str,edge2str) then
                graphVisual model [] vertex2str edge2str "digraph" id
            else match model with DFA(model,input,state2str,label2str,displayNames) then
                dfaVisual model input state2str label2str "dfa" displayNames id
            else match model with DFA(model,input,state2str,label2str) then
                dfaVisual model input state2str label2str "dfa" [] id
            else match model with Graph(model,vertex2str,edge2str,displayNames) then
                graphVisual model displayNames vertex2str edge2str "graph" id
            else match model with Graph(model,vertex2str,edge2str) then
                graphVisual model [] vertex2str edge2str "graph" id
            else match model with NFA(model,input,state2str,label2str,displayNames) then
                nfaVisual model input state2str label2str "nfa" displayNames id
            else match model with NFA(model,input,state2str,label2str) then
                nfaVisual model input state2str label2str "nfa" [] id
            else match model with BTree(model, node2str,displayName) then
                treeVisual model node2str displayName id
	        else match model with BTree(model, node2str) then
                treeVisual model node2str [] id
            else error "unknown type") models) in
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
