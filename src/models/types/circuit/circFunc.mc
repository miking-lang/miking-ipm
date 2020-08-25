let circCompEq = lam a. lam b. 
    match a with Component (circ_type,name,value) then
        match b with Component (circ_type,name,value) then true 
        else false
    else 
        match a with Parallel p_lst then
            match b with Parallel p_lst then true
            else false
        else
            match a with Series s_lst then
                match b with Series s_lst then true 
                else false
            else false

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