
-- This is an example file for generating and visualizing
-- a circuit model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr


-- create your circuit
let circuit = Parallel [
<<<<<<< HEAD
<<<<<<< HEAD
    Component ("resistor","V1",0.0,true),
    Component ("ground","g",0.0,false)
=======
    Component ("r","V1",11.0,false),
    Component ("ground","g",0.0,true)
>>>>>>> bcc8452... other component types can be defined
=======
    Series[
    Component ("ammeter","Afff",None(),true),
    Component ("ground","g",0.0,false)
    ],
    Series [
        Component ("battery","V",11.0,true),
        Component ("resistor","R",4.0,true) 
    ]
>>>>>>> 18e9642... added an example
] in

-- call function 'visualize' to get visualization code for the circuit
visualize [
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
	Circuit(circuit)
=======
	Circuit(circuit,[("r","shape=rect","k")])
>>>>>>> 8b44f22... other component types can be defined
=======
	Circuit(circuit,[("r","shape=rect label=\\\"yey\\\"","k")])
>>>>>>> bcc8452... other component types can be defined
=======
	Circuit(circuit,[("ammeter","shape=circle style=filled fillcolor=lightgreen label=\\\"A\\\"","&Omega; ")])
>>>>>>> 18e9642... added an example
]