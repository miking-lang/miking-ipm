include "string.mc"
include "map.mc"
include "model.mc"

-- format vertex
let formatVertex = lam name.
    foldl concat [] ["{\"name\":\"", name, "\"},\n"]

-- format edge
let formatEdge = lam from. lam to. lam label.
    foldl concat [] ["{\"from\": \"", from, "\", \"to\": \"" , to, "\", \"label\": \"" , label , "\"},\n"]

-- format vertices
let formatVertices = lam vertices. lam vertex2str.
    foldl (lam output. lam vertex.
        concat output (formatVertex (vertex2str (head vertices)))
    ) "" vertices
 
-- format edges and squash edges between the same nodes.
recursive
let formatAndSquashEdges = lam trans. lam v2s. lam eqv.
    if (eqi (length trans) 0) then "" 
    else
    let first = head trans in
    let formatedEdge = formatEdge (v2s (first.0)) (v2s (first.1)) (first.2) in
    if(eqi (length trans) 1) then formatedEdge
    else
        let second = head (tail trans) in
        if (and (eqv (first.0) (second.0)) (eqv (first.1) (second.1))) 
        then formatAndSquashEdges (join [[(first.0,first.1,join [first.2,second.2])], (tail (tail trans))]) v2s eqv
        else join [formatedEdge, formatAndSquashEdges (tail trans) v2s eqv]
end

-- format all edges into printable string
let formatEdges = lam edges. lam v2s. lam l2s. lam eqv.
    let edges_string = map (lam x. (x.0,x.1,l2s x.2)) edges in
    formatAndSquashEdges edges_string v2s eqv
        
-- Formatting the states
let formatStates = lam states. lam state2str.
    formatVertices states state2str

-- format transitions into printable string
let formatTransitions = lam trans. lam v2s. lam l2s. lam eqv.
    formatEdges trans v2s l2s eqv
    
-- Getting the input path formated
let formatInputPath = lam path. lam state2string.
    foldl (lam output. lam elem.
        foldl concat [] [output,
            "{\"state\": \"",state2string elem.state,
            "\",\"status\": ",int2string elem.status,
            ",\"index\": ",int2string elem.index,"},\n"
        ]
    ) "" path

-- format input-line
let formatInput = lam input. lam label2str.
    foldl (lam output. lam elem.
        foldl concat [] [output,"\"" ,label2str elem, "\","]
    ) "" input

-- Traversing the tree to format the states
recursive
let formatBTreeStates = lam btree. lam n2s. lam output.
    match btree with BTree t then
    formatBTreeStates t n2s ""
    else match btree with Nil () then
    output
    else match btree with Leaf v then foldl concat [] [output, formatVertex (n2s v)]
    else match btree with Node n then
    let output =  foldl concat [] [output, formatVertex (n2s n.0)] in
    let output = formatBTreeStates n.1 n2s output in
    let output = formatBTreeStates n.2 n2s output in
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
        foldl concat [] [output, formatEdge (n2s from) (n2s v) ""]
    else match btree with Node n then
        let output = foldl concat [] [output, formatEdge (n2s from) (n2s n.0) ""] in
        let output = formatBTreeEdges n.1 n2s n.0 output in
        let output = formatBTreeEdges n.2 n2s n.0 output in
        output
    else "Wrong input"
end

-- return a string with n tabs
let tab = lam n. if(lti n 0) then error "Number of tabs can not be smaller than 0" 
    else (unfoldr (lam b. if eqi b n then None () else Some ('\t', addi b 1)) 0)
    
-- add tabs after every \n to string, tab according to brackets ('{','}','[,']')
recursive
let addTabs = lam inpt. lam t.
    if (eqi (length inpt) 0 ) then ""
    else if (eqi (length inpt) 1) then [head inpt]
    else
    let first = head inpt in
    let rest = tail inpt in
    let next = head rest in
    let tabs = (if or (eqchar first '{') (eqchar first '[') then addi t 1
        else if or (eqchar next '}') (eqchar next ']') then subi t 1
        else t) in
    if eqchar first '\n' then concat (concat "\n" (tab tabs)) (addTabs rest tabs) else cons first (addTabs rest tabs)
end

-- (any (lam x. or (eqchar x '{') (eqchar x '[')) first)
-- format NFA to JS code for visualizing
let nfaVisual = lam nfa. lam input. lam s2s. lam l2s. lam nfaType.
    foldl concat [] ["{\n ",
        "\"type\" : \"", nfaType,"\",\n ",
        "\"simulation\" : {\n",
            " \"input\" : [", (formatInput input l2s),"],\n",
            " \"configurations\" : [\n", 
            (formatInputPath (nfaMakeInputPath (negi 1) nfa.startState input nfa) s2s),
            "],\n",
        "},\n ",
        "\"model\" : {\n ",
            "\"states\" : [\n",
            (formatStates (getStates nfa) s2s),
            "],\n ",
            "\"transitions\" : [\n",
            (formatTransitions (getTransitions nfa) s2s l2s (getEqv nfa)),
            "], \n ",
            "\"startState\" : \"", (s2s nfa.startState),"\",\n ",
            "\"acceptedStates\" : [", foldl concat [] (map (lam s. foldl concat [] ["\"", (s2s s), "\","]) nfa.acceptStates),"],\n",
        "}\n",
    "}"
]

let dfaVisual = nfaVisual 

-- format a graph to JS code
let formatGraph = lam nodes. lam edges. lam graphType.
    foldl concat [] ["{\n \"type\" : \"",
	graphType,
	"\",\n \"model\" : {\n \"nodes\" : [\n",
	nodes ,
	"],\n \"edges\" : [\n",
	edges,
	"], \n },\n}"
	]

-- format a graph to JS code for visualizing
let graphVisual = lam model. lam vertex2str. lam edge2str. lam graphType.
    let nodes = formatVertices (graphVertices model) vertex2str in
    let edges = formatEdges (graphEdges model) vertex2str edge2str model.eqv in
    formatGraph nodes edges graphType

-- format a tree to JS code for visualizing
let treeVisual = lam model. lam node2str.
    let nodes = formatBTreeStates model node2str "" in
    let edges = formatBTreeEdges model node2str 0 "" in
    formatGraph nodes edges "tree"

-- make all models into string object
let visualize = lam models.
    let models = strJoin ",\n" (
        map (lam model. 
            match model with Digraph(model,vertex2str,edge2str) then
                graphVisual model vertex2str edge2str "digraph"
            else match model with DFA(model,input,state2str,label2str) then
                dfaVisual model input state2str label2str "dfa"
            else match model with Graph(model,vertex2str,edge2str) then
                graphVisual model vertex2str edge2str "graph"
            else match model with NFA(model,input,state2str,label2str) then
                nfaVisual model input state2str label2str "nfa"
	        else match model with BTree(model, node2str) then
                treeVisual model node2str
            else error "unknown type") models) in
    print (foldl concat [] ["let data = {\"models\": [\n", models, "]\n}\n"])
                        
mexpr
let alfabeth = ['0','1','2'] in
let states = [1,2,3] in
let transitions = [(1,2,'0'),(3,1,'0'),(1,2,'1'),(2,3,'1'),(1,2,'2'),(3,1,'1')] in
let startState = 1 in
let acceptStates = [1] in
let input = "010" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqi eqchar in
let model = DFA(newDfa, input, int2string, lam b. [b]) in
visualize [model]
