-- This file provides toDot functions for all models defined in model.mc.
include "model.mc"

type dotEdge = {
    from: String,
    to: String,
    label: String,
    delimiter: String,
    extra: String
}

type dotVertex = {
    name: String,
    extra: String
}

-- constructor for dotEdge
let initDotEdge = lam from. lam to. lam label. lam delimiter. lam extra.
    {from = from, to = to, label = label, delimiter = delimiter, extra = extra}

-- constructor for dotVertex
let initDotVertex = lam name. lam extra.
    {name = name, extra = extra}

-- concatenates a list of strings
let concatList = lam list.
    foldl concat [] list

-- formats a dotEdge to dot
let edgeToDot = lam e. lam modelID.
    let quote = match modelID with () then "\"" else "\\\"" in
    let class = match modelID with () then "" else concatList ["class=",quote,"model",(int2string modelID),"edge",quote," ",
                                                              "id=",quote,e.from,e.label,e.to,quote," "] in
    concatList [e.from," ",e.delimiter," ",e.to," [label=",quote,e.label,quote," ",class,e.extra,"];"]

-- formats a dotVertex to dot
let vertexToDot = lam v. lam modelID.
    let quote = match modelID with () then "\"" else "\\\"" in
    let class = match modelID with () then "" else concatList ["class=model",(int2string modelID),"node"," "] in
    concatList [v.name,"[","id=",quote,v.name,quote," ",class,v.extra,"];"]

-- prints a given model in dot syntax
let getDot = lam graphType. lam direction. lam stdVerticesSetting. lam vertices. lam edges. lam id.
    let output = foldl concat [] [[graphType," {","rankdir=",direction,";",
        "node [",stdVerticesSetting,"];"],
        (map (lam v. vertexToDot v id) vertices),
        (map (lam e. edgeToDot e id) edges),
        ["}"]
    ] in 
    foldl concat [] output

-- returns the standard active node setting
let getActiveNodeSetting = lam _.
    " fillcolor=darkgreen fontcolor = white"

-- returns the standard node setting
let getStdNodeSettings = lam _.
    "style=filled fillcolor=white shape=circle"


-- returns a btree in dot.
let btreeGetDot = lam tree. lam node2str. lam direction. lam id. lam vSettings.
    let dotEdges = map (lam e. initDotEdge (node2str e.0) (node2str e.1) "" "->" "") (treeEdges tree ()) in
    let dotVertices = map (lam v. 
        let extra = find (lam x. tree.eqv x.0 v) vSettings in
        initDotVertex (node2str v) (match extra with Some e then e.1 else "")
    ) (treeVertices tree) in
    getDot "digraph" direction (getStdNodeSettings ()) dotVertices dotEdges id

-- returns a graph in dot.
let graphGetDot = lam graph. lam v2str. lam l2str. lam direction. lam id. lam graphType. lam vSettings.
    let delimiter = if ((setEqual eqchar) graphType "graph") then "--" else "->" in
    let dotVertices = map (lam v. 
        let extra = find (lam x. graph.eqv x.0 v) vSettings in
        initDotVertex (v2str v) (match extra with Some e then e.1 else "")
    ) (graphVertices graph) in
    let dotEdges = map (lam e. initDotEdge (v2str e.0) (v2str e.1) (l2str e.2) delimiter "") (graphEdges graph) in
    getDot graphType direction (getStdNodeSettings ()) dotVertices dotEdges id

-- Gets a NFA in dot.
let nfaGetDot = lam nfa. lam v2str. lam l2str. lam direction. lam id. lam vSettings. lam input. lam steps.
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
            let active = (if (lti (negi 1) steps) then 
                if (eqv v currentState)  then getActiveNodeSetting () else ""
            else "") in
            let extra = find (lam x. eqv x.0 v) vSettings in
            let extraSettings = strJoin " " [dbl,active,(match extra with Some e then e.1 else "")] in
            initDotVertex (v2str v) extraSettings)
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
    getDot "digraph" direction (getStdNodeSettings ()) dotVertices dotEdges id


-- converts and prints the given model in dot. vSettings is a seqence of 
-- two element tuples, the first element refers to the name of the vertex, 
-- the second should be a string with custom graphviz settings.
let modelGetDot = lam model. lam id. lam vSettings.
    match model with Graph(graph,v2str,l2str,direction) then
        graphGetDot graph v2str l2str direction id "graph" vSettings
    else match model with Digraph(digraph,v2str,l2str,direction) then
        graphGetDot digraph v2str l2str direction id "digraph" vSettings
    else match model with NFA(nfa,input,state2str,label2str,direction) then
        nfaGetDot nfa state2str label2str direction id vSettings "" (negi 1)
    else match model with DFA(dfa,input,state2str,label2str,direction) then
        nfaGetDot dfa state2str label2str direction id vSettings "" (negi 1)
    else match model with BTree(tree, node2str,direction) then
        btreeGetDot tree node2str direction id vSettings
    else ""

let modelPrintDotSimulateTo = lam model. lam steps. lam vSettings.
    match model with NFA(nfa,input,state2str,label2str,direction) then
        nfaGetDot nfa state2str label2str direction () vSettings input steps
    else match model with DFA(dfa,input,state2str,label2str,direction) then
        nfaGetDot dfa state2str label2str direction () vSettings input steps
    else ""

-- converts and prints the given model in dot.
let modelPrintDot = lam model. lam vSettings.
    print (modelGetDot model () vSettings)