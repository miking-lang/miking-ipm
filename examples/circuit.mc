
-- This is an example file for generating and visualizing
-- a circuit model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"

mexpr

-- create your circuit
let circuit = Parallel [
    Component ("r","V1",11.0,false),
    Component ("ground","g",0.0,true),
    Series[
        Component ("ammeter","amp",None(),true),
        Component ("capacitator","c",Some 8.0,true),
        Component ("ground","g",Some 0.0,false)
    ],
    Series [
        Component ("battery","V",Some 11.0,true),
        Parallel [
            Component ("resistor","R1",Some 4.0,true),
            Component ("resistor","R2",Some 1.0,true)
        ],
        Component ("lamp","lamp1",None(),true)
    ]
] in
let simpleCircuit = Parallel [
    Series[
        Component ("ground","g",Some 0.0,false)
    ],
    Series [
        Component ("battery","V",Some 11.0,true),
        Parallel [
            Component ("resistor","R1",Some 4.0,true),
            Component ("resistor","R2",Some 1.0,true)
            
        ]
    ]
] in

let center_width = 2 in
let side_width = 8 in
let side_height = 8 in
let center_height = 2 in

let quote = "\\\"" in
let lampSettings = join ["shape=circle color=black style=filled fillcolor=lightyellow height=0 width=0 margin=0 label=<
        <table BORDER=",quote,"0",quote," CELLBORDER=",quote,"0",quote," CELLSPACING=",quote,"0",quote," CELLPADDING=",quote,"0",quote,"> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("none",side_width,side_height),("black",center_width,side_height),("none",side_width,side_height)],
            "</tr> 
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("black",side_width,center_height),("black",center_width,center_height),("black",side_width,center_height)],
            "</tr>
            <tr>",
                (foldl (lam str. lam x. concat str (makeTDElem x.0 x.1 x.2 quote))) "" 
                    [("none",side_width,side_height), ("black",center_width,side_height),("none",side_width,side_height)],
            "</tr>   
        </table>>"] in

let side_width = 1 in
let center_width = 10 in
let side_height = 5 in
let center_height = 10 in

let capacitatorSettings =  "<canvas id=myCanvas width=300 height=200></canvas>" in

-- call function 'visualize' to get visualization code for the circuit
visualize [
    -- simple circuit
    Circuit(simpleCircuit,[]),
    -- customized circuit
	Circuit(
        circuit,[
            ("ammeter","shape=circle style=filled fillcolor=lightgreen height=0.2 width=0.2 label=\\\"A\\\"",""),
            ("lamp",lampSettings,""),
            ("capacitator",capacitatorSettings,"pF")
        ]
    )
]