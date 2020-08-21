-- This file provides toDot functions for all models defined in model.mc.
include "model.mc"

-- constructor for dotEdge
let initDotEdge = lam from. lam to. lam label. lam delimiter. lam extra.
    {from = from, to = to, label = label, delimiter = delimiter, extra = extra}

-- constructor for dotVertex
let initDotVertex = lam name. lam extra. lam settings.
    {name = name, extra = extra,settings=settings}

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
    concatList ["node[",v.settings,"];",v.name,"[","id=",quote,v.name,quote," ",class,v.extra,"];"]

let edgeToSubgraph = lam lst. lam modelID.
    foldl (lam str. lam x. concat str (foldl concat [] [["subgraph {\n",
    "rank=same;",
    vertexToDot x.1 modelID,
    vertexToDot x.0 modelID,
    "\n};"
    ]])) "" lst

-- prints a given model in dot syntax
let getDot = lam graphType. lam direction. lam vertices. lam edges. lam id. lam extra. lam subgraphs.
    let output = foldl concat [] [[graphType," {\n",extra,"\n","rankdir=",direction,";"],
        edgeToSubgraph subgraphs id,
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
        initDotVertex (node2str v) (match extra with Some e then e.1 else "") (getStdNodeSettings ())
    ) (treeVertices tree) in
    getDot "digraph" direction dotVertices dotEdges id "" []

-- returns a graph in dot.
let graphGetDot = lam graph. lam v2str. lam l2str. lam direction. lam id. lam graphType. lam vSettings.
    let delimiter = if ((setEqual eqchar) graphType "graph") then "--" else "->" in
    let dotVertices = map (lam v. 
        let extra = find (lam x. graph.eqv x.0 v) vSettings in
        initDotVertex (v2str v) (match extra with Some e then e.1 else "") (getStdNodeSettings ())
    ) (graphVertices graph) in
    let dotEdges = map (lam e. initDotEdge (v2str e.0) (v2str e.1) (l2str e.2) delimiter "") (graphEdges graph) in
    getDot graphType direction dotVertices dotEdges id "" []

-- Gets a NFA in dot simulated "steps" steps av the "input" input.
let nfaGetDotSimulate = lam nfa. lam v2str. lam l2str. lam direction. lam id. lam vSettings. lam input. lam steps.
    let eqv = nfaGetEqv nfa in
    let path = (if (lti (negi 0) steps) then slice (nfaMakeEdgeInputPath nfa.startState input nfa) 0 steps
        else []) in
    let currentState = if (eqi steps 0) then nfa.startState
        else if (lti steps 0) then None()
        else (last path).1 in 
    let finalEdge = if (lti steps 1) then None() 
        else last path in
    let dotVertices = join [[initDotVertex "start" "style=invis" (getStdNodeSettings ())],
        map (lam v. 
            let dbl = if (any (lam x. eqv x v) nfa.acceptStates) then "shape=doublecircle" else "" in
            let settings = (if (lti (negi 1) steps) then 
                if (eqv v currentState)  then getActiveNodeSetting () else getStdNodeSettings ()
            else "") in
            let extra = find (lam x. eqv x.0 v) vSettings in
            let extraSettings = strJoin " " [dbl,(match extra with Some e then e.1 else "")] in
            initDotVertex (v2str v) extraSettings settings)
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
    getDot "digraph" direction dotVertices dotEdges id "" []

-- Gets a NFA in dot.
let nfaGetDot = lam nfa. lam v2str. lam l2str. lam direction. lam id. lam vSettings.
    nfaGetDotSimulate nfa v2str l2str direction id vSettings "" (negi 1)

let makeTDElem = lam color. lam elem_width. lam elem_height.
        foldl concat [] ["<td ",
            "bgcolor=\\\"", color,"\\\" ",
            "width = \\\"",(int2string elem_width),"\\\" ",
            " height=\\\"",(int2string elem_height),"\\\"",
            "></td>\n"]

-- returns the standard node setting
let getBatteryNodeSettings = lam _.
    let side_width = 1 in
    let center_width = 10 in
    let side_height = 5 in
    let center_height = 10 in
    foldl concat [] ["shape=none, color=none height=0 width=0 margin=0 label=<
    <table BORDER=\\\"0\\\" CELLBORDER=\\\"0\\\" CELLSPACING=\\\"0\\\" CELLPADDING=\\\"0\\\"> 
        <tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2))) "" 
                [("black",side_width,side_height),("none",center_width,side_height),("none",side_width,side_height)],
        "</tr> 
        <tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2))) "" 
                [("black",side_width,side_height),("none",center_width,center_height),("black",side_width,side_height)],
        "</tr>
        <tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2))) "" 
                [("black",side_width,side_height), ("none",center_width,side_height),("none",side_width,side_height)],
        "</tr>   
     </table>>"]

-- returns the standard node setting
let getGroundNodeSettings = lam _.
    let width =5 in
    let height = 1 in
    foldl concat [] ["shape=none, color=none height=0 width=0 margin=0 label=<
    <table CELLBORDER=\\\"0\\\" CELLSPACING=\\\"0\\\" CELLPADDING=\\\"0\\\" >\n<tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x width height))) "" ["black","black","black","black","black"],
        " </tr>\n<tr>",
           makeTDElem "none" width (muli 2 height),
       "</tr>\n<tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x width height))) "" ["none","black","black","black","none"],
        "</tr>\n<tr>",
            makeTDElem "none" width (muli 2 height),
        "</tr>\n<tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x width height))) "" ["none","none","black","none","none"],
        "</tr>\n</table>> "]

-- returns the standard node setting
let getResistorNodeSettings = lam _.
    "style=filled color=black fillcolor=none shape=rect height=0.1 width=0.3 label=\\\"\\\""

let getPointNodeSettings = lam _.
    "shape=point style=filled color=black height=0.03 width=0.03"

-- returns a graph in dot.
let circGetDot = lam circ. lam id. lam vSettings.
    let delimiter = "--" in
    let components = circGetAllComponents circ in 
    let dotVertices = join (map (lam c. 
        match c with Component (comp_type,name,maybe_value,_) then
            -- round to two decimals
            let value = match maybe_value with None () then 0.0 else maybe_value in
            let value_str = int2string (roundfi value) in
            --utest value_str with "" in
            if (setEqual eqchar comp_type "resistor") then
                [initDotVertex name (foldl concat [] ["xlabel=\\\"" ,value_str," &Omega;\\\""]) (getResistorNodeSettings ())]
            else if (setEqual eqchar comp_type "battery") then
                [initDotVertex name (foldl concat [] ["xlabel=\\\"",value_str," V\\\""]) (getBatteryNodeSettings ())]
            else if (setEqual eqchar comp_type "ground") then
                [initDotVertex name "" (getGroundNodeSettings ())]
            else [initDotVertex name "" (getPointNodeSettings ())]
        else []
    ) components) in
    --let groundComp = (filter (lam x. match x with Component("ground",name,value) then true else false) components) in
    --let groundEdges = map (lam x. 
    --    let name = circGetComponentName x in
    --    let from = match (find (lam x. setEqual eqchar x.name name) dotVertices) with 
    --        Some e then e else (None ()) in
    --    let to = match (find (lam x. setEqual eqchar x.name (concat name "fig" )) dotVertices) with
    --        Some e then e else (None ()) in
    --    (from,to)
    --) groundComp in
    let edges = concat (circGetAllEdges circ) [] in
    let dotEdges = concat (map (lam e.
            utest e with [] in
            let from = circGetComponentName e.0 in
            let to = circGetComponentName e.1 in
            initDotEdge from to "" delimiter ""
            ) edges) []--(map (lam e.
                --initDotEdge (e.0).name (e.1).name "" delimiter ""
            --) groundEdges
            --)
             in
    --let dotSubgraphs = groundEdges in
    getDot "graph" "LR" dotVertices dotEdges id "graph [ nodesep=\\\"0.8\\\" ];\nsplines=ortho; " []

-- converts the given model in dot. vSettings is a seqence of 
-- two element tuples, the first element refers to the name of the vertex, 
-- the second should be a string with custom graphviz settings.
let modelGetDot = lam model. lam id. lam vSettings.
    match model with Graph(graph,v2str,l2str,direction) then
        graphGetDot graph v2str l2str direction id "graph" vSettings
    else match model with Digraph(digraph,v2str,l2str,direction) then
        graphGetDot digraph v2str l2str direction id "digraph" vSettings
    else match model with NFA(nfa,input,state2str,label2str,direction) then
        nfaGetDot nfa state2str label2str direction id vSettings
    else match model with DFA(dfa,input,state2str,label2str,direction) then
        nfaGetDot dfa state2str label2str direction id vSettings
    else match model with BTree(tree, node2str,direction) then
        btreeGetDot tree node2str direction id vSettings
    else match model with Circuit(circuit) then
        circGetDot circuit id vSettings
    else ""

let modelPrintDotSimulateTo = lam model. lam steps. lam vSettings.
    match model with NFA(nfa,input,state2str,label2str,direction) then
        nfaGetDotSimulate nfa state2str label2str direction () vSettings input steps
    else match model with DFA(dfa,input,state2str,label2str,direction) then
        nfaGetDotSimulate dfa state2str label2str direction () vSettings input steps
    else ""

-- converts and prints the given model in dot.
let modelPrintDot = lam model. lam vSettings.
    print (modelGetDot model () vSettings)
