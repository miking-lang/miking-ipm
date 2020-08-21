
-- This is an example file for generating and visualizing
-- a circuit model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr


-- create your circuit
let circuit = Parallel [
    Component ("battery","V1",11.0,true),
    Series[
    Component ("battery","V3",1.0,true),
    Component ("resistor", "R4",7.0,true),
    Component("resistor","r1",0.0,true),
    Component ("ground","gr",None(),false)
    ]
] in

-- call function 'visualize' to get visualization code for the circuit
visualize [
	Circuit(circuit)
]