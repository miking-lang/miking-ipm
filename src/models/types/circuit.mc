-- Represents a electrical circuit. A circuit consists of a Series connection, a Parallel connection,
-- or a component (Battery or Resistor). A series or parallel connection then consists of a list of circuits.
-- All components have a name and a value (voltage/resistance).

include "set.mc"
include "char.mc"

-- (type,name,value) where type is either "resistor" or "battery"
-- for example ("battery","V1",10.0) is a battery named V1 with value 10 volt

type Circuit
    con Component : (circ_type,name,value) -> Circuit
    con Series : [Component] -> Circuit 
    con Parallel : [Component] -> Circuit

-- gets the name of component comp
let circGetComponentName = lam comp. 
    match comp with Component (_,name,_) then name
    else None ()

-- gets the component with name 'name' from circuit circ
recursive
let circGetComponentByName = lam circ. lam name.
    match circ with Component (_,comp_name,_) then 
        if (setEqual eqchar name comp_name) then circ
        else None()
    else 
        let lst = match circ with Parallel p_circ then 
                    p_circ
                else match circ with Series s_circ then
                    s_circ
                else [] in
    foldl (lam res. lam comp. 
        match res with None() then
            circGetComponentByName comp name
        else res
    ) (None ()) lst
end

-- calculates the total voltage in circuit circ
recursive
let getTotalVoltage = lam circ.
        -- for batteries in series the total voltage is the sum
        let calc_series_voltage = lam lst. foldl (lam volt_con. lam comp.
            match comp with Component ("battery",name, voltage) then 
                addf volt_con voltage 
            else match comp with Series s_circ then addf volt_con (getTotalVoltage comp)
            else match comp with Parallel p_circ then addf volt_con (getTotalVoltage comp)
            else volt_con) 0.0 lst in

        -- for batteries in parallel the total voltage is the same as each battery.
        -- batteries in parallel need to have the same voltage
        let calc_parallel_voltage = lam lst. foldl (lam volt_con. lam comp.
            let v = match comp with Component ("battery",name, voltage) then voltage
                    else match comp with Series s_circ then getTotalVoltage comp
                    else match comp with Parallel p_circ then getTotalVoltage comp
                    else volt_con in
            match volt_con with None() then v
            else if (eqf volt_con v) then v
            else error "Batteries in parallel need to have the same voltage"
            ) (None ()) lst in

        match circ with Parallel p_lst then calc_parallel_voltage p_lst
        else match circ with Series s_lst then calc_series_voltage s_lst
        else 0.0
end

-- -- calculates the total resistance in circuit circ
recursive
let getTotalResistance = lam circ.
    -- for resistors in series the total resistance is the sum
    let calc_series_res = lam lst. foldl (lam res_comp. lam comp. 
        match comp with Component ("resistor",name, res) then 
            addf res_comp res
        else match comp with Series c then getTotalResistance comp 
        else match comp with Parallel c then getTotalResistance comp
        else res_comp) 0.0 lst in

    -- for resistors in parallel the total resistance Rt can be calculated by
    -- 1/Rt = 1/R1 + 1/R2 ... 1/Rn
    let calc_parallel_res = lam lst. 
        (let res_con = foldl (lam res_comp. lam comp.
            match comp with Component ("resistor",name, res) then 
                addf (divf 1.0 res) res_comp
            else match comp with Series c then addf (divf 1.0 (getTotalResistance comp)) res_comp
            else match comp with Parallel c then addf (divf 1.0 (getTotalResistance comp)) res_comp
            else res_comp) 0.0 lst in
            divf 1.0 res_con) in

    match circ with Series lst then
        calc_series_res lst
    else match circ with Parallel lst then
        calc_parallel_res lst
    else 0
end

-- calculates the total current in circuit circ
let getTotalCurrent = lam circ.
    let voltage = getTotalVoltage circ in
    let resistance = getTotalResistance circ in
    -- I = V/R 
    divf voltage resistance

recursive
let circGetAllComponents = lam circ.
    match circ with Component c then [circ] 
    else match circ with Series circ_lst then 
        foldl (lam lst. lam comp. concat lst (circGetAllComponents comp)) [] circ_lst
    else match circ with Parallel circ_lst then 
        foldl (lam lst. lam comp. concat lst (circGetAllComponents comp)) [] circ_lst
    else []
end

let makeEdges = lam from_lst. lam to_lst.
    foldl (lam lst. lam a. 
        concat lst (map (lam b. 
            match a with Component (_,a_name,_) then
                match b with Component (_,b_name,_) then
                    (a_name,b_name)
                else error "edges must be between components"
            else error "edges must be between components"
            ) 
        to_lst)
    ) [] from_lst
    
recursive
let circHead = lam circ. 
    match circ with Component c then [circ] else
    match circ with Series lst then circHead (head lst)
    else match circ with Parallel lst then 
        foldl (lam res. lam elem. concat res (circHead elem)) [] lst
    else []
end

recursive
let circLast= lam circ. 
    match circ with Component c then [circ] else
    match circ with Series lst then circLast (last lst)
    else match circ with Parallel lst then 
        foldl (lam res. lam elem. concat res (circLast elem)) [] lst
    else []
end

recursive
let circGetAllEdges = lam circ.
    match circ with Component (_,name,_) then []
    else match circ with Series circ_lst then
        if (eqi (length circ_lst) 0) then []
        else
            let k = (zipWith (lam a. lam b.
                let from = circLast a in
                let to = circHead b in
                let a_edges = circGetAllEdges a in
                let b_edges = circGetAllEdges b in
                concat (a_edges) (makeEdges from to)
            )(init circ_lst) (tail circ_lst)) in
            join (concat k [])
    else []
end

mexpr
let circ = Series [
            Series [
            Component ("battery","V1",11.0),
            Component ("resistor","R3",1.4),
            Component ("resistor","R1",1.4),
            Component ("battery","V2",11.0),
            Component ("resistor","R2",1.4)
            ],
            Parallel [
            Component ("battery","V3",0.0),
            Component ("resistor", "R4",0.0)
            ],
            Series [
                Component("resistor", "r5",0.0)
            ]
        ] in
let edges = circGetAllEdges circ in
utest edges with [] in
let _ = map (lam x. 
    utest x with [] in
    match x with (a,b) then
        
        let _ = print a in
        let _ = print "," in
        let _ = print b in
        print "\n"
    else print "no match") edges in ()
--utest (circGetAllComponents circ) with "" in
--utest circLast circ with [] in
--utest circGetAllEdges circ with [] in 

