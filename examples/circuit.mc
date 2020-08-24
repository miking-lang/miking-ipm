
-- This is an example file for generating and visualizing
-- a circuit model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr


-- create your circuit
let circuit = Parallel [
<<<<<<< HEAD
    Component ("resistor","V1",0.0,true),
    Component ("ground","g",0.0,false)
=======
    Component ("r","V1",11.0,false),
    Component ("ground","g",0.0,true)
>>>>>>> bcc8452... other component types can be defined
] in

-- call function 'visualize' to get visualization code for the circuit
visualize [
<<<<<<< HEAD
<<<<<<< HEAD
	Circuit(circuit)
=======
	Circuit(circuit,[("r","shape=rect","k")])
>>>>>>> 8b44f22... other component types can be defined
=======
	Circuit(circuit,[("r","shape=rect label=\\\"yey\\\"","k")])
>>>>>>> bcc8452... other component types can be defined
]