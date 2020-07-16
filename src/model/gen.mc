include "string.mc"
include "map.mc"
include "dfa.mc"
include "model.mc"
include "nfa.mc"
include "btree.mc"

-- Formatting the vertices
recursive
let formatVertices = lam vertices. lam vertex2str. lam output.
    if (eqi (length vertices) 0) then output
    else
    let first = head vertices in
    let rest = tail vertices in
    let formatdFirst = strJoin "" [
    "{\"name\":\"",
    (vertex2str first),
    "\"},\n"] in
    formatVertices rest vertex2str (concat output formatdFirst)
end

-- format edges and squash edges between the same nodes.
recursive
let formatAndSquashEdges = lam trans. lam v2s. lam eqv.
    if (eqi (length trans) 0) then "" else
    let first = head trans in
    let formatdFirst = ["{\"from\": \"", (v2s (first.0)), "\", \"to\": \"" ,(v2s (first.1)) , "\", \"label\": \"" , (first.2) , "\"},\n"] in
    if(eqi (length trans) 1) then
    strJoin "" formatdFirst
    else
    let second = head (tail trans) in
    if (and (eqv (first.0) (second.0)) (eqv (first.1) (second.1))) then formatAndSquashEdges (join [[(first.0,first.1,join [first.2,second.2])], (tail (tail trans))]) v2s eqv
    else 
    join [strJoin "" formatdFirst, formatAndSquashEdges (tail trans) v2s eqv]
end

-- format all edges into printable string
let formatEdges = lam edges. lam v2s. lam l2s. lam eqv.
        let edges_string = map (lam x. (x.0,x.1,l2s x.2)) edges in
        formatAndSquashEdges edges_string v2s eqv
        
-- Formatting the states
let formatStates = lam states. lam state2str.
    formatVertices states state2str ""

-- format transitions into printable string
let formatTransitions = lam trans. lam v2s. lam l2s. lam eqv.
    formatEdges trans v2s l2s eqv

    
-- Getting the input path formatd
recursive
let formatInputPath = lam path. lam output. lam state2string.
    if(eqi (length path) 0) then output
    else
    let first = head path in
    let rest = tail path in
    formatInputPath rest (strJoin "" [output,"\"",(state2string first),"\"", ","]) state2string
end

-- Traversing the tree to format the states
recursive
let formatBTreeStates = lam btree. lam n2s. lam output.
    match btree with BTree t then
    formatBTreeStates t n2s ""
    else match btree with Nil () then
    output
    else match btree with Leaf v then strJoin "" [output, "{\"name\":\"", (n2s v), "\"},\n"]
    else match btree with Node n then
    let output =  strJoin "" [output, "{\"name\":\"", (n2s n.0), "\"},\n"] in
    let output = formatBTreeStates n.1 n2s output in
    let output = formatBTreeStates n.2 n2s output in
    output
    else "Error, incorrect binary tree"
end

-- Traversing the tree to format the transitions (edges)
recursive
let formatBTreeEdges = lam btree. lam n2s. lam from. lam output.
    match btree with BTree t then
    (
    match t with Node n then
    let output = formatBTreeEdges n.1 n2s n.0 "" in
    formatBTreeEdges n.2 n2s n.0 output
    else ""
    )
    else match btree with Nil () then
    output
    else match btree with Leaf v then
    strJoin "" [output, " {\"from\": \"", (n2s from), "\", \"to\": \"" ,(n2s v) , "\"},\n"]
    else match btree with Node n then
    let output = strJoin "" [output, " {\"from\": \"", (n2s from) , "\", \"to\": \"" , (n2s n.0) , "\"},\n"] in
    let output = formatBTreeEdges n.1 n2s n.0 output in
    let output = formatBTreeEdges n.2 n2s n.0 output in
    output
    
    else "Wrong input"
end


-- Formatting the states
let formatStates = lam states. lam state2str.
    formatVertices states state2str ""

-- format edges and squash edges between the same nodes.
recursive
let formatAndSquashEdges = lam trans. lam v2s. lam eqv.
    if (eqi (length trans) 0) then "" else
    let first = head trans in
    let formatdFirst = ["{\"from\": \"", (v2s (first.0)), "\", \"to\": \"" ,(v2s (first.1)) , "\", \"label\": \"" , (first.2) , "\"},\n"] in
    if(eqi (length trans) 1) then
    strJoin "" formatdFirst
    else
    let second = head (tail trans) in
    if (and (eqv (first.0) (second.0)) (eqv (first.1) (second.1))) then formatAndSquashEdges (join [[(first.0,first.1,join [first.2,second.2])], (tail (tail trans))]) v2s eqv
    else 
    join [strJoin "" formatdFirst, formatAndSquashEdges (tail trans) v2s eqv]
end

-- format all edges into printable string
let formatEdges = lam edges. lam v2s. lam l2s. lam eqv.
        let edges_string = map (lam x. (x.0,x.1,l2s x.2)) edges in
        formatAndSquashEdges edges_string v2s eqv

-- format transitions into printable string
let formatTransitions = lam trans. lam v2s. lam l2s. lam eqv.
    formatEdges trans v2s l2s eqv
    
-- Getting the input path formatd
recursive
let formatInputPath = lam path. lam output. lam state2string.
    if(eqi (length path) 0) then output
    else
    let first = head path in
    let rest = tail path in
    formatInputPath rest (strJoin "" [output,"\"",(state2string first),"\"", ","]) state2string
end

-- Format input-line
recursive
let formatInput = lam input. lam output. lam label2str.
    if(eqi (length input) 0) then output
    else
    let first = head input in
    let rest = tail input in
    let output = strJoin "" [output,"\"" ,(label2str first) , "\","] in
    formatInput rest output label2str
end


-- return a string with n tabs
let tab = lam n. if(lti n 0) then error "Number of tabs can not be smaller than 0" 
    else strJoin "" (unfoldr (lam b. if eqi b n then None () else Some ("\t", addi b 1)) 0)

	   
-- add tabs after every \n to string, tab according to brackets ('{','}','[,']')
recursive
let addTabs = lam inpt. lam t.
    if (eqi (length inpt) 0 ) then ""
    else if (eqi (length inpt) 1) then inpt
    else
    let first = head inpt in
    let snd = head (tail inpt) in
    let rest = tail inpt in
    if (eqchar first '\n') then 
        if or (eqchar snd '}') (eqchar snd ']') then concat (strJoin "" [[first],tab (subi t 1)]) (addTabs rest t) 
        else concat (strJoin "" [[first],tab t]) (addTabs rest t) 
    else if or (eqchar (first) '{') (eqchar first '[') then concat [first] (addTabs rest (addi t 1))
    else if (or (eqchar (first) '}') (eqchar (first) ']')) then concat [first] (addTabs rest (subi t 1)) 
    else concat [first] (addTabs rest t) 
end

-- Format a DFA to JS code and visualize
let dfaVisual = lam model. lam input. lam state2str. lam label2str.
    let dfa = model in
    let transitions = dfaTransitions dfa in
    let js_code = strJoin "" [
        "{\n",
	"\"type\" : \"dfa\",\n",
	"\"simulation\" : {\n",
	"\"input\" : [", (formatInput input "" label2str),"],\n",
        "\"configurations\" : [", (formatInputPath (makeInputPath input dfa dfa.startState) "" state2str), "],\n",
        "\"state\" : ","\"",dfaAcceptedInput input dfa,"\"", ",\n",
        "},\n",
        "\"model\" : {\n",
        "\"states\" : [\n",formatStates (dfaStates dfa) state2str,"],\n",
        "\"transitions\" : [\n", (formatTransitions transitions state2str label2str (dfaGetEqv dfa)) ,"], \n",
        "\"startID\" : \"", (state2str dfa.startState) , "\",\n",
        "\"acceptedIDs\" : [",(strJoin "" (map (lam s. strJoin "" ["\"", (state2str s), "\","]) dfa.acceptStates)),"],\n",
        "}\n",
        "},\n"
    ] in
    js_code

-- Format a digraph to JS code and visualize
let digraphVisual = lam model. lam state2str. lam label2str.
    let digraph = model in
    let edges = digraphEdges digraph in
    strJoin "" [
    "{\n",
        "\"type\" : \"","digraph","\",\n",
        "\"model\" : {\n",
            "\"nodes\" : [\n",(formatVertices (digraphVertices digraph) state2str "" ) ,"],\n",
            "\"edges\" : [\n", (formatEdges (digraphEdges digraph) state2str label2str digraph.eqv), "], \n",
        "},\n",
    "\n},\n"]


-- Format a graph to JS code and visualize
let graphVisual = lam model. lam state2str. lam label2str.
    let graph = model in
    let edges = graphEdges graph in
    strJoin "" [
    "{\n",
        "\"type\" : \"","graph","\",\n",
        "\"model\" : {\n",
            "\"nodes\" : [\n",(formatVertices (graphVertices graph) state2str "" ) ,"],\n",
            "\"edges\" : [\n", (formatEdges (graphEdges graph) state2str label2str graph.eqv), "], \n",
        "},\n",
    "\n},\n"]


-- Format NFA to JS code for visualizing
let nfaVisual = lam model. lam input. lam s2s. lam l2s.
    let nfa = model in
    let first = strJoin "" ["{\n", "\"type\" : \"nfa\",\n"] in
    let js_code = strJoin "" [
        first,
	"\"model\" : {\n",
	"\"states\" : [\n",
	(formatStates (nfaStates nfa) s2s),
	"],\n",
	"\"transitions\" : [\n", (formatTransitions (nfaTransitions nfa) s2s l2s (nfaGetEqv nfa)) ,
	"], \n",
	(strJoin "" ["\"startID\" : \"", (s2s nfa.startState) , "\",\n"]),
    	"\"acceptedIDs\" : [",
    (strJoin "" (map (lam s. strJoin "" ["\"", (s2s s), "\","]) nfa.acceptStates)),
    "],\n}\n},\n"] in
    js_code


-- Format Tree to JS code for visualizing
let btreeVisual = lam model. lam n2s.
     let btree = model in
     let snd = strJoin "" [ "\"type\" : \"btree\",\n"] in
     let first = strJoin "" [ "{\n"] in
     let js_code = strJoin "" [
     first,
     snd,
     "\"model\" : {\n",
     "\"nodes\" : [\n",(formatBTreeStates btree n2s "") ,"],\n",
     "\"edges\" : [\n", (formatBTreeEdges btree n2s 0 "") ,
     "], \n",
     "}\n},\n"
     ] in
     js_code
    



-- make all models into string object
let visualize = lam models.
    let models = strJoin "" (
        map (lam model. 
            match model with Digraph(model,vertex2str,edge2str) then
                digraphVisual model vertex2str edge2str
            else match model with DFA(model,input,state2str,label2str) then
                dfaVisual model input state2str label2str
            else match model with Graph(model,vertex2str,edge2str) then
                graphVisual model vertex2str edge2str
                -- change the name of the function above
            else match model with NFA(model,input,state2str,label2str) then
                nfaVisual model input state2str label2str
	    else match model with BTree(model, node2str) then
	    	 btreeVisual model node2str
            else error "unknown type") models) in
    print (addTabs (strJoin "" ["let data = {\n",
                        "\t\"models\": [\n",
                        models,
                        "]\n}\n"]) 0)
                        
mexpr
let alfabeth = ['0','1','2'] in
let states = [1,2,3] in
let transitions = [(1,2,'0'),(3,1,'0'),(1,2,'1'),(2,3,'1'),(1,2,'2'),(3,1,'1')] in
let startState = 1 in
let acceptStates = [1] in
let input = "010" in
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqi eqchar in
let model = DFA(newDfa, input, int2string, (lam b. [b])) in
visualize [model]
