-- Represents a electrical circuit. A circuit consists of a Series connection, a Parallel connection,
-- or a component. A series or parallel connection then consists of a list of circuits.
-- All components in a series or parallel connection are considered to be connected
-- according to the order of the list, 
-- and all parallel/series connections are connected by the first component/components
-- (by order of the list).
-- All components have a type ("battery" "resistor" or "ground"), a name and a value (voltage/resistance/None ()).

include "set.mc"
include "char.mc"

-- (type,name,value) where type is either "resistor", "battery" or "ground"
-- for example ("battery","V1",10.0) is a battery named V1 with value 10 volt

type Circuit
    con Component : (circ_type,name,value,e_in) -> Circuit
    con Series : [Component] -> Circuit 
    con Parallel : [Component] -> Circuit
    con Close : () -> Circuit -- closes the circuit by connecting to the first component

-- gets the name of component comp
let circGetComponentName = lam comp. 
    match comp with Component (_,name,_) then name
    else None ()

-- returns all components in circuit circ
recursive
let circGetAllComponents = lam circ.
    match circ with Component (_,name,_,true) then [circ] 
    else match circ with Component (_,name,_,false) then 
        [circ,Component("point",concat name "_point",None (),true)]
    else match circ with Series circ_lst then 
        foldl (lam lst. lam comp. concat lst (circGetAllComponents comp)) [] circ_lst
    else match circ with Parallel circ_lst then 
        foldl (lam lst. lam comp. concat lst (circGetAllComponents comp)) [] circ_lst
    else []
end

-- creates edges between all elements in from_lst to all elements in to_lst
-- returns a list of tuples (a,b)
let makeEdges = lam from_lst. lam to_lst.
    utest from_lst with [] in
    utest to_lst with [] in
    foldl (lam lst. lam a. 
        concat lst (map (lam b. 
            match a with Component (_,a_name,_,_) then
                match b with Component (_,b_name,_,_) then
                    (a,b)
                else error "edges must be between components"
            else error "edges must be between components"
            ) 
        to_lst)
    ) [] from_lst
    
-- gets the first component (or components in case of a parallel connection) in the circuit
recursive
let circHead = lam circ. 
    match circ with Component (_,name,_,true) then [circ]
    else match circ with Component (_,name,_,false) then 
        [Component("point",concat name "_point",None (),true)]
    else match circ with Series lst then circHead (head lst)
    else match circ with Parallel lst then 
        foldl (lam res. lam elem. concat res (circHead elem)) [] lst
    else []
end

-- gets the last component (or components in case of a parallel connection) in the circuit
recursive
let circLast = lam circ.
   match circ with Component (_,name,_,true) then [circ] 
    else match circ with Component (_,name,_,false) then 
        [Component("point",concat name "_point",None (),1)]
    else match circ with Series lst then circLast (last lst)
    else match circ with Parallel lst then 
        foldl (lam res. lam elem. concat res (circLast elem)) [] lst
    else []
end

-- returns all connections in the circuit as a list of tuples 
-- where (a,b) means that there is a wire from a to b
recursive
let circGetAllEdges = lam circ.
    utest circ with [] in
    match circ with Component (_,name,_,false) then 
        let a = makeEdges [Component("point",concat name "_point",None(),true)] [circ] in
        utest a with [] in
        a
    else match circ with Component (_,name,false) then []
    else match circ with Series circ_lst then
        utest circ_lst with [] in 
        if (eqi (length circ_lst) 0) then []
        else
            let edges = (zipWith (lam a. lam b.
                let from = circLast a in
                let maybe_to = circHead b in
                let to = maybe_to in
                let a_edges = circGetAllEdges a in
                concat (a_edges) (makeEdges from to)
            )(init circ_lst) (tail circ_lst)) in
            
            let point_edges = match last circ_lst with Component (_,name,_,false) then
                                let from_edge = Component("point",concat name "_point",None(),1) in
                                makeEdges [from_edge] [(last circ_lst)]
                            else [] in
            utest point_edges with [] in
            utest edges with [] in
            concat (join edges) point_edges
    else match circ with Parallel circ_lst then
        if (eqi (length circ_lst) 0) then []
        else
            let final_index = subi (length (circ_lst)) 1 in
            join (mapi (lam i. lam comp. 
                let from = circLast comp in 
                let other_components = slice circ_lst (addi 1 i) final_index in
                let to = join (map (lam x. 
                    circHead x
                --replace with compEq
                ) other_components) in
                let from_edges = circGetAllEdges comp in
                let edges = concat (from_edges) (makeEdges from to) in
                if (eqi i 0) then 
                    let from_snd = join (map (lam x. 
                    circLast x
                --replace with compEq
                ) other_components) in
                    let to_snd = from in
                    join [edges,makeEdges from_snd to_snd] 
                else edges
            ) circ_lst)
    else []
end

mexpr
let circ = Series [
            Series [
            Component ("battery","V1",11.0,1),
            Component ("resistor","R3",1.4,1),
            Component ("resistor","R1",1.4,1),
            Component ("battery","V2",11.0,1),
            Component ("resistor","R2",1.4,1)
            ],
            Parallel [
            Component ("battery","V3",0.0,1),
            Component ("resistor", "R4",0.0,1)
            ],
            Series [
                Component("resistor", "r5",0.0,1)
            ],
            Component("ground","g",0.0,1,0)
        ] in ()
