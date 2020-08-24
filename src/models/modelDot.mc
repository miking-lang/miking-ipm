-- This file provides toDot functions for all models defined in model.mc.
include "model.mc"

-- constructor for dotEdge
let initDotEdge = lam from. lam to. lam label. lam delimiter. lam eSettings.
    {from = from, to = to, label = label, delimiter = delimiter, eSettings = eSettings}

-- constructor for dotVertex
let initDotVertex = lam name. lam settings.
    {name = name,settings=settings}

-- concatenates a list of strings
let concatList = lam list.
    foldl concat [] list

-- gets the quote
let getQuote = lam id.
    match id with () then "\"" else "\\\""

-- formats a dotEdge to dot
let edgeToDot = lam e. lam modelID.
    let quote = getQuote modelID in
    let class = match modelID with () then "" else concatList ["class=",quote,"model",(int2string modelID),"edge",quote," ",
                                                              "id=",quote,e.from,e.label,e.to,quote," "] in
    concatList [e.from," ",e.delimiter," ",e.to," [label=",quote,e.label,quote," ",class,e.eSettings,"];"]

-- formats a dotVertex to dot
let vertexToDot = lam v. lam modelID.
    let quote = getQuote modelID in
    let class = match modelID with () then "" else concatList ["class=model",(int2string modelID),"node"," "] in
    concatList [v.name,"[","id=",quote,v.name,quote," ",class,v.settings,"];"]

let settingsToDot = lam settings. lam modelID.
    let quote = getQuote modelID in
    foldl (lam output. lam t. concatList [output, t.0,"=",quote,t.1,quote," "]) "" settings

-- utest (settingsToDot [("a")])


-- prints a given model in dot syntax
let getDot = lam graphType. lam direction. lam vertices. lam edges. lam id. lam extra.
    let output = foldl concat [] [[graphType," {\n",extra,"\n","rankdir=",direction,";"],
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
    let delimiter = if ((setEqual eqchar) graphType "graph") then "--" else "->" in
    let dotVertices = map (lam v. 
        let extra = find (lam x. graph.eqv x.0 v) vSettings in
        let settings = concat (match extra with Some e then (settingsToDot e.1 id) else "") "" in
        initDotVertex (v2str v) settings
    ) (graphVertices graph) in
    let dotEdges = map (lam e. initDotEdge (v2str e.0) (v2str e.1) (l2str e.2) delimiter "") (graphEdges graph) in
    getDot graphType direction dotVertices dotEdges id (getStdNodeSettings ())

-- Gets a NFA in dot simulated "steps" steps av the "input" input.
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

-- Gets a NFA in dot.
let nfaGetDot = lam nfa. lam v2str. lam l2str. lam id. lam direction. lam vSettings.
    nfaGetDotSimulate nfa v2str l2str id direction vSettings "" (negi 1)

-- returns a table data element with the given characteristics
let makeTDElem = lam color. lam elem_width. lam elem_height. lam quote.
    foldl concat [] ["<td ",
        "bgcolor=",quote,color,quote,
        " width=",quote,(int2string elem_width),quote,
        " height=",quote,(int2string elem_height),quote,
        "></td>\n"]

let circUnconnectedToDot = lam name. lam quote. lam settings. lam value_str.
    let figName = concat name "fig" in
    foldl concat [] [concatList [figName,"[id=",quote,figName,quote," ","label=",quote,quote,settings.0,"xlabel=",quote,value_str,quote," ","];",
                name,"[id=",quote,name,quote," shape=point style=filled color=black height=0.05 width=0.05",
                "];",
                figName,"--",name,";"]]

-- gets the resistor component in dot
let resistorToDot = lam quote. lam name. lam value. lam custom_settings. lam isConnected.
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
                ("style=filled color=black fillcolor=none shape=rect height=0.1 width=0.3 "," &Omega;") in
    if not (isConnected) then circUnconnectedToDot name quote settings (concat value settings.1) else
    concatList [name,"[id=",quote,name,quote," ",
                "xlabel=",quote,value,settings.1,quote," ",
                settings.0,
                " label=",quote,quote,"];"]

-- gets the battery component in dot
let circBatteryToDot = lam quote. lam name. lam value. lam custom_settings. lam isConnected.
    let side_width = 1 in
    let center_width = 10 in
    let side_height = 5 in
    let center_height = 10 in
    
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
        let setting = foldl concat [] ["shape=none, color=none height=0 width=0 margin=0 label=<
        <table BORDER=",quote,"0",quote," CELLBORDER=",quote,"0",quote," CELLSPACING=",quote,"0",quote," CELLPADDING=",quote,"0",quote,"> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height),("none",center_width,side_height),("none",side_width,side_height)],
            "</tr> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height),("none",center_width,center_height),("black",side_width,side_height)],
            "</tr>
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height), ("none",center_width,side_height),("none",side_width,side_height)],
            "</tr>   
        </table>>"
    ] in (setting,"V") in
    if not (isConnected) then circUnconnectedToDot name quote settings (concat value settings.1) else
    concatList [name,"[id=",quote,name,quote," ",
                        "xlabel=",quote,value,settings.1,quote," ",
                        settings.0,"];"]


-- gets the ground component in dot
let circGroundToDot = lam quote. lam name. lam custom_settings. lam isConnected.
    let width =5 in
    let height = 1 in
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
        let w = foldl concat [] ["shape=none, color=none height=0 width=0 margin=0 label=<
    <table CELLBORDER=",quote,"0",quote," CELLSPACING=",quote,"0",quote," CELLPADDING=",quote,"0",quote," >\n<tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x width height quote))) "" ["black","black","black","black","black"],
        " </tr>\n<tr>",
           makeTDElem "none" width (muli 2 height) quote,
       "</tr>\n<tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x width height quote))) "" ["none","black","black","black","none"],
        "</tr>\n<tr>",
            makeTDElem "none" width (muli 2 height) quote,
        "</tr>\n<tr>",
            (foldl (lam str. lam x. concat str (makeTDElem x width height quote))) "" ["none","none","black","none","none"],
        "</tr>\n</table>> "] in
        (w,"") in
    if not (isConnected) then circUnconnectedToDot name quote settings ""
    else foldl concat [] [name,"[id=",quote,name,quote," ","label=",quote,quote,settings.0," ","];"]

let circOtherToDot = lam quote. lam name. lam value. lam _. lam custom_settings. lam isConnected.
    let value_str = match value with None () then "" else (foldl concat [] [(value)," "]) in
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
        (foldl concat [] ["style=filled fillcolor=white shape=circle label=",quote,quote, " xlabel=",quote,value_str,quote],"") in
    if not (isConnected) then circUnconnectedToDot name quote settings value_str
    else concatList [name,"[id=",quote,name,quote," ",
                "xlabel=",quote,value_str,settings.1,quote," ",
                settings.0,"];"]

<<<<<<< HEAD
<<<<<<< HEAD
let getPointNodeSettings = lam _.
    "shape=point style=filled color=black height=0.03 width=0.03"
=======
=======
-- returns a component in dot.
<<<<<<< HEAD
>>>>>>> 70c36c1... imporved automatic layout for electrical circuits
let componentToDot = lam comp. lam quote.
    match comp with Component (comp_type,name,maybe_value) then
        -- round to two decimals
        let value = match maybe_value with None () then 0.0 else maybe_value in
        let value_str = int2string (roundfi value) in
        match comp_type with "resistor" then
            resistorToDot quote name value_str
        else match comp_type with "battery" then
            circBatteryToDot quote name value_str
        else match comp_type with "ground" then
            circGroundToDot quote name
        else ""
=======
let componentToDot = lam comp. lam quote. lam fig_settings.
    match comp with Component (comp_type,name,maybe_value,isConnected) then
        let figure_setting = 
            let fig = find (lam x. if (setEqual eqchar x.0 comp_type) then true else false) fig_settings in
            match fig with Some (_,setting,unit) then Some (setting,unit) else None() in
        -- round to integer
        let value = match maybe_value with None () then 0.0 else maybe_value in
        let value_str = int2string (roundfi value) in
        match comp_type with "resistor" then
            resistorToDot quote name value_str figure_setting isConnected
        else match comp_type with "battery" then
            circBatteryToDot quote name value_str figure_setting isConnected
        else match comp_type with "ground" then
            circGroundToDot quote name figure_setting isConnected
        else 
            circOtherToDot quote name value_str "unit" figure_setting isConnected
>>>>>>> 8b44f22... other component types can be defined
    else []

<<<<<<< HEAD
>>>>>>> 2e383d7... Refactored functions for component rendering
=======
-- goes through the circuit and returns the edges in dot.
-- the order of the edges returned determines the layout of the circuit
recursive
let circGetDotEdges = lam circ. lam id. lam inClosure.
    let cluStart = lam id. lam dir. concatList ["{rank=same; g",int2string id,dir] in
    let cluEnd = lam id. lam dir. concatList [" -- g",int2string id,dir,";"] in
    match circ with Component (_,name,_) then 
        concat " -- " name
    else match circ with Series circ_lst then
        let content = foldl (lam output. lam elem. concat output (circGetDotEdges elem id true)) "" circ_lst in
        if inClosure then content
        else concatList [cluStart id "L",content,cluEnd id "R","}"]
    else match circ with Parallel circ_lst then
        let depth = mapi (lam i. lam elem. countInnerDepth elem) circ_lst in
        let contentList = mapi (lam i. lam elem. 
            let newId = addi i id in
            let currId = foldl addi newId (slice depth 0 i) in
            let nextId = foldl addi newId (slice depth 0 (addi i 1)) in
            let minLen = if lti currId nextId 
                         then concatList ["[minlen=",int2string (subi nextId currId),"]"] else "" in 
            concatList [if eqi (length circ_lst) (addi i 1) then ""
                        else concatList ["g",int2string currId,"L"," -- g",int2string (addi nextId 1),"L",minLen,
                        " g",int2string currId,"R",cluEnd (addi nextId 1) "R"],
                        cluStart currId "L",circGetDotEdges elem (addi 1 currId) true,cluEnd currId "R","}"]
            ) circ_lst in
        concatList [if inClosure then concatList [cluEnd id "L", "}"] else "",
                    concatList contentList,
                    if inClosure then concatList [cluStart id "R"] else ""]
    else error "Unknown circuit type"
end
>>>>>>> 70c36c1... imporved automatic layout for electrical circuits

-- returns a graph in dot.
let circGetDot = lam circ. lam id.
    let quote = getQuote id in
    let delimiter = "--" in
<<<<<<< HEAD
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
=======
    let components = circGetAllComponents circ in
    let dotComponents = concatList (map (lam c. componentToDot c quote) components) in
    let dotEdges = circGetDotEdges circ 0 false in
    concatList ["graph { concentrate=true; splines=ortho; ranksep=0.7; nodesep=0.5; rankdir=BT;",
                dotComponents,
                "node[shape=point height = 0 width = 0 margin = 0];",
                dotEdges,
                "}"]
>>>>>>> 2e383d7... Refactored functions for component rendering

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
    else match model with Circuit(circuit) then
        circGetDot circuit id
    else ""

let modelPrintDotSimulateTo = lam model. lam steps.
    match model with NFA(nfa,input,state2str,label2str,direction,vSettings) then
        nfaGetDotSimulate nfa state2str label2str () direction vSettings input steps
    else match model with DFA(dfa,input,state2str,label2str,direction,vSettings) then
        nfaGetDotSimulate dfa state2str label2str () direction vSettings input steps
    else ""

-- converts and prints the given model in dot.
let modelPrintDot = lam model.
    print (modelGetDot model ())
