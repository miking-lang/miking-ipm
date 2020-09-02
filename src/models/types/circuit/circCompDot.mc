include "string.mc"
include "set.mc"

-- returns a table data element with the given characteristics
let makeTDElem = lam color. lam elem_width. lam elem_height. lam quote.
    join ["<td ",
        "bgcolor=",quote,color,quote,
        " width=",quote,(int2string elem_width),quote,
        " height=",quote,(int2string elem_height),quote,
        "></td>\n"]

utest makeTDElem "green" 1 2 "\"" with "<td bgcolor=\"green\" width=\"1\" height=\"2\"></td>\n"

-- returns a node in dot.
let nodeToDot = lam name. lam quote. lam settings.
    join [name,"[id=",quote,name,quote," ",settings,"];"]

-- formats a components to dot.
let formatComponentToDot = lam name. lam quote. lam settings. lam isConnected.
    let figName = (concat name "fig") in
    if isConnected then nodeToDot name quote settings 
    else join [nodeToDot figName quote settings,
                    nodeToDot name quote "shape=point style=filled color=black height=0.05 width=0.05",
                    figName,"--",name,";"]

-- returns the resistor component in dot.
let circResistorToDot = lam quote. lam name. lam value. lam custom_settings. lam isConnected.
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
                ("style=filled color=black fillcolor=none shape=rect height=0.1 width=0.3 "," &Omega;") in
    let dotSettings = join [" xlabel=",quote,value,settings.1,quote," ",settings.0," label=",quote,quote] in
    formatComponentToDot name quote dotSettings isConnected


-- returns the battery component in dot.
let circBatteryToDot = lam quote. lam name. lam value. lam custom_settings. lam isConnected.
    let side_width = 1 in
    let center_width = 10 in
    let side_height = 5 in
    let center_height = 10 in
    
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
        let setting = join ["shape=none, color=none height=0 width=0 margin=0 label=<
        <table BORDER=",quote,"0",quote," CELLBORDER=",quote,"0",quote," CELLSPACING=",quote,"0",quote," CELLPADDING=",quote,"0",quote,"> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [
                        ("black",side_width,side_height),
                    ("none",center_width,side_height),
                    ("none",(addi side_width 1),side_height)],
            "</tr> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height),("none",center_width,center_height),("black",(addi side_width 1),side_height)],
            "</tr>
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,side_height), ("none",center_width,side_height),("none",(addi side_width 1),side_height)],
            "</tr>   
        </table>>"
    ] in (setting,"V") in
    formatComponentToDot name quote (join ["xlabel=",quote,value,settings.1,quote," ",settings.0]) isConnected

-- returns the ground component in dot.
let circGroundToDot = lam quote. lam name. lam custom_settings. lam isConnected.
    let width =5 in
    let height = 1 in
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
        (join ["shape=none, color=none height=0 width=0 margin=0 label=<
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
        "</tr>\n</table>> "]
        ,"") in
    formatComponentToDot name quote (join ["label=",quote,quote,settings.0]) isConnected

-- returns a custom component in dot.
let circOtherToDot = lam quote. lam name. lam value. lam _. lam custom_settings. lam isConnected.
    let settings = match custom_settings with Some (setting,unit) then (setting,unit) else
        (join ["style=filled fillcolor=white shape=circle label=",quote,quote, " xlabel=",quote,value,quote]," ") in
    let value_str = match value with "" then "" else (join [value," ",settings.1," "]) in
    formatComponentToDot name quote (join ["xlabel=",quote,value_str,quote," ",settings.0]) isConnected

-- returns a component in dot.
let componentToDot = lam comp. lam quote. lam fig_settings.
    match comp with Component (comp_type,name,maybe_value,isConnected) then
        let figure_setting = 
            let fig = find (lam x. eqstr x.0 comp_type) fig_settings in
            match fig with Some (_,setting,unit) then Some (setting,unit) else None() in
        -- round to integer
        let value_str = match maybe_value with Some v then int2string (roundfi v) else "" in

        match comp_type with "resistor" then
            circResistorToDot quote name value_str figure_setting isConnected
        else match comp_type with "battery" then
            circBatteryToDot quote name value_str figure_setting isConnected
        else match comp_type with "ground" then
            circGroundToDot quote name figure_setting isConnected
        else 
            circOtherToDot quote name value_str "unit" figure_setting isConnected
    else []