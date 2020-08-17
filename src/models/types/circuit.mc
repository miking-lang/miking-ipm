-- Represents a electrical circuit. A circuit consists of a Series connection, a Parallel connection,
-- or a component (Battery or Resistor). A series or parallel connection then consists of a list of circuits.
-- All components have a name and a value (voltage/resistance).

include "set.mc"
include "char.mc"

type Circuit 
    con Battery : (name,voltage,position) -> Circuit --position (x,y)
    con Resistor : (name,resistance,position) -> Circuit
    con Series : [Circuit] -> Circuit 
    con Parallel : [Circuit] -> Circuit

-- gets the name of component comp
let circGetComponentName = lam comp. 
    match comp with Battery (name,_) then name
    else match comp with Resistor (name, _) then name
    else None ()

-- gets the component with name 'name' from circuit circ
recursive
let circGetComponentByName = lam circ. lam name.
    match circ with Parallel lst then circGetComponentByName lst name
    else match circ with Series lst then circGetComponentByName lst name
    else if (eqi (length circ) 0) then None () 
    else
        let first = (head circ) in 
        let comp_name = circGetComponentName first in
        match comp_name with None () then 
            let first_lst = match first with Series lst then lst 
                else match first with Parallel lst then lst
                else [] in
            let res = find (lam x. let name_comp = (circGetComponentName x) in
                            match name_comp with None () then false else
                            if (setEqual eqchar name) then true else false) first_lst in 
            match res with Some comp then comp
            else circGetComponentByName (tail circ) name
        else if (setEqual eqchar comp_name name) then first else circGetComponentByName (tail circ)
end

-- calculates the total voltage in circuit circ
recursive
let getTotalVoltage = lam circ.
        -- for batteries in series the total voltage is the sum
        let calc_series_voltage = lam lst. foldl (lam volt_con. lam comp.
            match comp with Battery (name, voltage) then 
                addf volt_con voltage 
            else match comp with Series s_circ then addf volt_con (getTotalVoltage comp)
            else match comp with Parallel p_circ then addf volt_con (getTotalVoltage comp)
            else volt_con) 0.0 lst in

        -- for batteries in parallel the total voltage is the same as each battery.
        -- batteries in parallel need to have the same voltage
        let calc_parallel_voltage = lam lst. foldl (lam volt_con. lam comp.
            let v = match comp with Battery (name, voltage) then voltage
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
        match comp with Resistor (name, res) then 
            addf res_comp res
        else match comp with Series c then getTotalResistance comp 
        else match comp with Parallel c then getTotalResistance comp
        else res_comp) 0.0 lst in

    -- for resistors in parallel the total resistance Rt can be calculated by
    -- 1/Rt = 1/R1 + 1/R2 ... 1/Rn
    let calc_parallel_res = lam lst. 
        (let res_con = foldl (lam res_comp. lam comp.
            match comp with Resistor (name, res) then 
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

let headComp = lam circ.
    match circ with Battery (name,_) then circ
    else match circ with Resistor (name,_) then circ
    else
    match circ with Series c then (head c)
    else match circ with Parallel c then (head c)
    else None ()

let tailComp = lam circ.
     match circ with Battery (name,_) then None()
    else match circ with Resistor (name,_) then None()
    else
    match circ with Series c then (tail c)
    else match circ with Parallel c then (tail c)
    else None ()

recursive
let circGetAllComponents = lam circ.
    match tailComp circ with None () then headComp circ
    else snoc (tailComp circ) (headComp circ)
end

recursive
let circGetAllEdges = lam circ.
    match circ with Series c then 
        zipWith (lam a. lam b. 
            let first = match a with Series c_2 then
                circGetAllEdges c_2
                else match a with Battery (name,_,_) then name
                else match a with Resistor (name,_,_) then name
                else None() in
            let snd = match b with Series c_3 then
                circGetAllEdges c_3
                else match b with Battery (name,_,_) then name
                else match b with Resistor (name,_,_) then name
                else None() in
            (first,snd)
        ) (init c) (tail c)
    else None()
end

mexpr
let circ = Series [
            Battery ("V1",11.0,(0,0)),
            Resistor ("R1",1.4,(0,4)),
            Battery ("V2",11.0,(4,4)),
            Resistor ("R2",1.4,(4,0))
        ] in
let _ = print (circGetDot circ (lam x. x)) in
circGetAllEdges circ
