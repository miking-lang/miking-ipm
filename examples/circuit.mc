
-- This is an example file for generating and visualizing
-- a circuit model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr


-- create your circuit
let circuit = Series [
    Series [
    Component ("battery","V1",11.0),
    Component ("resistor","R3",3.0)
    ],
    Parallel [
    Component ("battery","V3",1.0),
    Component ("resistor", "R4",7.0)
    ],
    Component("ground","g",(None ())),
    Component("battery","V6",14.0),
    Close ()
] in

-- call function 'visualize' to get visualization code for the circuit
visualize [
	Circuit(circuit)
]