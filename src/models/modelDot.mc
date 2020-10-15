-- This file provides toDot functions for all models defined in model.mc.
include "model.mc"
include "types/circuit/circCompDot.mc"

-- constructor for dotEdge
let initDotEdge = lam from. lam to. lam label. lam delimiter. lam eSettings.
    {from=from, to=to, label=label, delimiter=delimiter, eSettings=eSettings}

-- constructor for dotVertex
let initDotVertex = lam name. lam settings.
    {name=name, settings=settings}

-- returns the correct formatted quote. If an id is passed, 
-- the quote is returned in JSON format, and in dot otherwise. 
let getQuote = lam id.
    match id with () then "\"" else "\\\""

utest getQuote () with "\""
utest getQuote 1 with "\\\""

-- formats a dotEdge to dot.
let edgeToDot = lam e. lam modelID.
    let quote = getQuote modelID in
    let class = match modelID with () then "" else join ["class=",quote,"model",(int2string modelID),"edge",quote," ",
                                                              "id=",quote,e.from,e.label,e.to,quote," "] in
    join [e.from," ",e.delimiter," ",e.to," [label=",quote,e.label,quote," ",class,e.eSettings,"];"]

utest edgeToDot (initDotEdge "a" "b" "c" "--" "") () with "a -- b [label=\"c\" ];"
utest edgeToDot (initDotEdge "a" "b" "c" "--" "") 1  with "a -- b [label=\\\"c\\\" class=\\\"model1edge\\\" id=\\\"acb\\\" ];"
utest edgeToDot (initDotEdge "a" "b" "c" "--" "color=\"green\"") () with "a -- b [label=\"c\" color=\"green\"];"

-- formats a dotVertex to dot.
let vertexToDot = lam v. lam modelID.
    let quote = getQuote modelID in
    let class = match modelID with () then "" else join ["class=",quote,"model",(int2string modelID),"node",quote," "] in
    join [v.name,"[","id=",quote,v.name,quote," ",class,v.settings,"];"]

utest vertexToDot (initDotVertex "a" "") () with "a[id=\"a\" ];"
utest vertexToDot (initDotVertex "a" "") 1  with "a[id=\\\"a\\\" class=\\\"model1node\\\" ];"
utest vertexToDot (initDotVertex "a" "color=\"green\"") () with "a[id=\"a\" color=\"green\"];"

-- formats vSettings to dot.
let settingsToDot = lam settings. lam modelID.
    let quote = getQuote modelID in
    strJoin " " (map (lam t. join [t.0,"=",quote,t.1,quote]) settings)

utest settingsToDot [] () with ""
utest settingsToDot [("label","start"),("color","green")] () with "label=\"start\" color=\"green\" "
utest settingsToDot [("label","start"),("color","green")] 1  with "label=\\\"start\\\" color=\\\"green\\\" "

-- prints a given model in dot syntax
let getDot = lam graphType. lam direction. lam vertices. lam edges. lam id. lam extra.
    join [
        graphType," {\n",extra,"\n","rankdir=",direction,";",
        join (map (lam v. vertexToDot v id) vertices),
        join (map (lam e. edgeToDot e id) edges),
        "}"
    ]

-- returns the standard active node setting
let getActiveNodeSetting = lam _.
    " fillcolor=darkgreen fontcolor = white"

-- returns the standard node setting
let getStdNodeSettings = lam _.
    "node [style=filled fillcolor=white shape=circle];"


-- returns a btree in dot.
let btreeGetDot = lam tree. lam node2str. lam id. lam direction. lam vSettings.
    let dotEdges = map (lam e. initDotEdge (node2str e.0) (node2str e.1) "" "->" "") (treeEdges tree ()) in
    let dotVertices = map (lam v. 
        let extra = find (lam x. tree.eqv x.0 v) vSettings in
        let settings = concat (match extra with Some e then (settingsToDot e.1 id) else "") "" in
        initDotVertex (node2str v) settings
    ) (treeVertices tree) in
    getDot "digraph" direction dotVertices dotEdges id (getStdNodeSettings ())

-- returns a graph in dot.
let graphGetDot = lam graph. lam v2str. lam l2str. lam id. lam direction. lam graphType. lam vSettings.
    let delimiter = if (eqString graphType "graph") then "--" else "->" in
    let dotVertices = map (lam v. 
        let extra = find (lam x. graph.eqv x.0 v) vSettings in
        let settings = concat (match extra with Some e then (settingsToDot e.1 id) else "") "" in
        initDotVertex (v2str v) settings
    ) (graphVertices graph) in
    let dotEdges = map (lam e. initDotEdge (v2str e.0) (v2str e.1) (l2str e.2) delimiter "") (graphEdges graph) in
    getDot graphType direction dotVertices dotEdges id (getStdNodeSettings ())

-- returns a NFA in dot simulated "steps" steps av the "input" input.
let nfaGetDotSimulate = lam nfa. lam v2str. lam l2str. lam id. lam direction. lam vSettings. lam input. lam steps.
    let eqv = nfaGetEqv nfa in
    let path = (if (lti (negi 0) steps) then slice (nfaMakeEdgeInputPath nfa.startState input nfa) 0 steps
        else []) in
    let currentState = if (eqi steps 0) then nfa.startState
        else if (lti steps 0) then None()
        else (last path).1 in 
    let finalEdge = if (lti steps 1) then None() 
        else last path in
    let dotVertices = join [[initDotVertex "start" "style=invis"],
        map (lam v. 
            let dbl = if (any (lam x. eqv x v) nfa.acceptStates) then "shape=doublecircle" else "" in
            let settings = (if (lti (negi 1) steps) then 
                if (eqv v currentState) then getActiveNodeSetting () else "" 
            else "") in
            let extra = find (lam x. eqv x.0 v) vSettings in
            let extraSettings = strJoin " " [dbl,(match extra with Some e then (settingsToDot e.1 id) else "")] in
            initDotVertex (v2str v) (strJoin " " [extraSettings,settings]))
        (nfaStates nfa)] in
    let startEdgeStyle = if (eqi 0 steps) then "color=darkgreen" else "" in
    let eqEdge = (lam a. lam b. and (eqv a.0 b.0) (eqv a.1 b.1)) in
    let dotEdges = join [[initDotEdge "start" nfa.startState "start" "->" startEdgeStyle],
        map (lam e. 
            let extra = if (lti 0 steps) then 
                if (eqEdge (e.0,e.1) finalEdge) then "color=darkgreen"
                else "" 
            else "" in
            initDotEdge (v2str e.0) (v2str e.1) (l2str e.2) "->" extra)
        (nfaTransitions nfa)] in
    getDot "digraph" direction dotVertices dotEdges id (getStdNodeSettings ())

-- returns a NFA in dot.
let nfaGetDot = lam nfa. lam v2str. lam l2str. lam id. lam direction. lam vSettings.
    nfaGetDotSimulate nfa v2str l2str id direction vSettings "" (negi 1)

-- goes through the circuit and returns the edges in dot.
-- the order of the edges returned determines the layout of the circuit
recursive
let circGetDotEdges = lam circ. lam id. lam inClosure.
    let cluStart = lam id. lam dir. join ["{rank=same; g",int2string id,dir] in
    let cluEnd = lam id. lam dir. join [" -- g",int2string id,dir,";"] in
    match circ with Component (_,name,_) then 
        concat " -- " name
    else match circ with Series circ_lst then
        let content = foldl (lam output. lam elem. concat output (circGetDotEdges elem id true)) "" circ_lst in
        if inClosure then content
        else join [cluStart id "L",content,cluEnd id "R","}"]
    else match circ with Parallel circ_lst then
        let depth = mapi (lam i. lam elem. countInnerDepth elem) circ_lst in
        let contentList = mapi (lam i. lam elem. 
            let newId = addi i id in
            let currId = foldl addi newId (slice depth 0 i) in
            let nextId = foldl addi newId (slice depth 0 (addi i 1)) in
            let minLen = if lti currId nextId 
                         then join ["[minlen=",int2string (subi nextId currId),"]"] else "" in 
            join [if eqi (length circ_lst) (addi i 1) then ""
                        else join ["g",int2string currId,"L"," -- g",int2string (addi nextId 1),"L",minLen,
                        " g",int2string currId,"R",cluEnd (addi nextId 1) "R"],
                        cluStart currId "L",circGetDotEdges elem (addi 1 currId) true,cluEnd currId "R","}"]
            ) circ_lst in
        join [if inClosure then join [cluEnd id "L", "}"] else "",
                    join contentList,
                    if inClosure then join [cluStart id "R"] else ""]
    else error "Unknown circuit type"
end

-- returns a graph in dot.
let circGetDot = lam circ. lam id. lam fig_settings.
    let quote = getQuote id in
    let delimiter = "--" in
    let components = circGetAllComponents circ in
    let dotComponents = join (map (lam c. componentToDot c quote fig_settings) components) in
    let dotEdges = circGetDotEdges circ 0 false in
    join ["graph { concentrate=true; splines=ortho; ranksep=0.7; nodesep=0.5; rankdir=BT;",
                dotComponents,
                "node[shape=point height = 0 width = 0 margin = 0];",
                dotEdges,
                "}"]

-- converts the given model in dot. vSettings is a seqence of 
-- two element tuples, the first element refers to the name of the vertex, 
-- the second should be a string with custom graphviz settings.
let modelGetDot = lam model. lam id.
    match model with Graph(graph,v2str,l2str,direction,vSettings) then
        graphGetDot graph v2str l2str id direction "graph" vSettings
    else match model with Digraph(digraph,v2str,l2str,direction,vSettings) then
        graphGetDot digraph v2str l2str id direction "digraph" vSettings
    else match model with NFA(nfa,input,state2str,label2str,direction,vSettings) then
        nfaGetDot nfa state2str label2str id direction vSettings
    else match model with DFA(dfa,input,state2str,label2str,direction,vSettings) then
        nfaGetDot dfa state2str label2str id direction vSettings
    else match model with BTree(tree, node2str,direction,vSettings) then
        btreeGetDot tree node2str id direction vSettings
    else match model with Circuit(circuit,fig_settings) then
        circGetDot circuit id fig_settings
    else ""

-- prints a model in dot simulated "steps" steps av the "input" input. 
let modelPrintDotSimulateTo = lam model. lam steps.
    match model with NFA(nfa,input,state2str,label2str,direction,vSettings) then
        print nfaGetDotSimulate nfa state2str label2str () direction vSettings input steps
    else match model with DFA(dfa,input,state2str,label2str,direction,vSettings) then
        print nfaGetDotSimulate dfa state2str label2str () direction vSettings input steps
    else error "unsupported model type"

-- converts and prints the given model in dot.
let modelPrintDot = lam model.
    print (modelGetDot model ())