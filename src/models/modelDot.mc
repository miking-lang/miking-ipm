-- This file provides toDot functions for all models defined in model.mc.
include "model.mc"

-- constructor for dotEdge
let initDotEdge = lam from. lam to. lam label. lam delimiter. lam extra.
    {from = from, to = to, label = label, delimiter = delimiter, extra = extra}

-- constructor for dotVertex
let initDotVertex = lam name. lam extra. lam nodeType. lam settings.
    {name = name, extra = extra,nodeType=nodeType,settings=settings}

-- concatenates a list of strings
let concatList = lam list.
    foldl concat [] list

-- formats a dotEdge to dot
let edgeToDot = lam e. lam modelID.
    let class = match modelID with () then "" else concatList ["class=model",(int2string modelID),"edge"] in
    concatList [e.from," ",e.delimiter," ",e.to," [label=\\\"",e.label,"\\\" ",
                                                  "id=",e.from,e.label,e.to," ",
                                                  class," ",e.extra,"];"]

-- formats a dotVertex to dot
let vertexToDot = lam v. lam modelID.
    let class = match modelID with () then "" else concatList ["class=model",(int2string modelID),v.nodeType] in
    concatList ["node[",v.settings,"]; ",v.name,"[","id=",v.name," ",class," ",v.extra,"];"]

-- prints a given model in dot syntax
let getDot = lam graphType. lam direction. lam stdVerticesSetting. lam vertices. lam edges. lam id.
    let output = foldl concat [] [[graphType," {","rankdir=",direction,";"],
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
        initDotVertex (node2str v) (match extra with Some e then e.1 else "") "node" (getStdNodeSettings ())
    ) (treeVertices tree) in
    getDot "digraph" direction (getStdNodeSettings ()) dotVertices dotEdges id

-- returns a graph in dot.
let graphGetDot = lam graph. lam v2str. lam l2str. lam direction. lam id. lam graphType. lam vSettings.
    let delimiter = if ((setEqual eqchar) graphType "graph") then "--" else "->" in
    let dotVertices = map (lam v. 
        let extra = find (lam x. graph.eqv x.0 v) vSettings in
        initDotVertex (v2str v) (match extra with Some e then e.1 else "") "node" (getStdNodeSettings ())
    ) (graphVertices graph) in
    let dotEdges = map (lam e. initDotEdge (v2str e.0) (v2str e.1) (l2str e.2) "" delimiter "") (graphEdges graph) in
    getDot graphType direction (getStdNodeSettings ()) dotVertices dotEdges id

-- Gets a NFA in dot.
let nfaGetDotSimulate = lam nfa. lam v2str. lam l2str. lam direction. lam id. lam vSettings. lam input. lam steps.
    let eqv = nfaGetEqv nfa in
    let path = (if (lti (negi 0) steps) then slice (nfaMakeEdgeInputPath nfa.startState input nfa) 0 steps
        else []) in
    let currentState = if (eqi steps 0) then nfa.startState
        else if (lti steps 0) then None()
        else (last path).1 in 
    let finalEdge = if (lti steps 1) then None() 
        else last path in
    let dotVertices = join [[initDotVertex "start" "style=invis" "node" (getStdNodeSettings ())],
        map (lam v. 
            let dbl = if (any (lam x. eqv x v) nfa.acceptStates) then "shape=doublecircle" else "" in
            let settings = (if (lti (negi 1) steps) then 
                if (eqv v currentState)  then getActiveNodeSetting () else getStdNodeSettings ()
            else "") in
            let extra = find (lam x. eqv x.0 v) vSettings in
            let extraSettings = strJoin " " [dbl,(match extra with Some e then e.1 else "")] in
            initDotVertex (v2str v) extraSettings "node" settings)
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

-- Gets a NFA in dot.
let nfaGetDot = lam nfa. lam v2str. lam l2str. lam direction. lam id. lam vSettings.
    nfaGetDotSimulate nfa v2str l2str direction id vSettings "" (negi 1)


-- returns the standard node setting
let getBatteryNodeSettings = lam _.
    "style=filled fillcolor=white shape=rect"

-- returns the standard node setting
let getResistorNodeSettings = lam _.
    "style=filled fillcolor=white shape=diamond"

-- returns a graph in dot.
let circGetDot = lam circ. lam comp2str. lam id. lam vSettings.
    let delimiter = "->" in
    let dotVertices = map (lam c. 
        match c with Component (comp_type,name,value) then
            if (setEqual eqchar comp_type "resistor") then
                initDotVertex (comp2str name) "" comp_type (getResistorNodeSettings ())
            else initDotVertex (comp2str name) "" comp_type (getBatteryNodeSettings ())
        else ""
    ) (circGetAllComponents circ) in
    let dotEdges = map (lam e. initDotEdge (comp2str e.0) (comp2str e.1) "" delimiter "") (circGetAllEdges circ) in
    utest dotEdges with [] in
    getDot "digraph" "LR" (getResistorNodeSettings ()) dotVertices dotEdges id

-- converts the given model in dot. vSettings is a seqence of 
-- two element tuples, the first element refers to the name of the vertex, 
-- the second should be a string with custom graphviz settings.
let modelGetDotWithOptions = lam model. lam direction. lam id. lam vSettings.
    match model with Graph(graph,v2str,l2str) then
        graphGetDot graph v2str l2str direction id "graph" vSettings
    else match model with Digraph(digraph,v2str,l2str) then
        graphGetDot digraph v2str l2str direction id "digraph" vSettings
    else match model with NFA(nfa,input,state2str,label2str) then
        nfaGetDot nfa state2str label2str direction id vSettings
    else match model with DFA(dfa,input,state2str,label2str) then
        nfaGetDot dfa state2str label2str direction id vSettings
    else match model with BTree(tree, node2str) then
        btreeGetDot tree node2str direction id vSettings
    else ""

let modelGetDotSimulateTo = lam model. lam steps. lam direction. lam vSettings.
    match model with NFA(nfa,input,state2str,label2str) then
        nfaGetDotSimulate nfa state2str label2str direction 0 vSettings input steps
    else match model with DFA(dfa,input,state2str,label2str) then
        nfaGetDotSimulate dfa state2str label2str direction 0 vSettings input steps
    else ""

-- converts and prints the given model in dot.
let modelGetDot = lam model. lam direction.
    modelGetDotWithOptions model direction 0 []
