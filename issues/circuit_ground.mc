include "../src/models/modelVisualizer.mc"
include "String.mc"

--if the ground is not placed in the first series 
-- (which will be drawn at the bottom), it is placed at the top,
-- which gives a circuit with wierd edges and overlaps.

mexpr
let circuit_wrong = Parallel [
    Component ("battery","V",Some 11.0,true),
    Component ("ground","g",Some 0.0,false)
] in

--this is how we would like circuit_ground_wrong to be displayed
let circuit = Parallel [
    Component ("ground","g",Some 0.0,false),
    Component ("battery","V",Some 11.0,true)
] in

visualize [
    Circuit(circuit_wrong,[]),
    Circuit(circuit,[])
]