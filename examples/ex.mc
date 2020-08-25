
-- This is an example file for generating and visualizing
-- a circuit model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"

mexpr

-- create your circuit
let circuit = Parallel [
    Series[
        Component ("insulator","ins1",Some 8.0,true),
        Component ("defaultSettings","ins2",Some 4.0,false)
    ],
    Series [
        Component ("battery","V",Some 11.0,true),
        Component ("resistor","R1",Some 4.0,true),
        Component ("assembly","assembly1",None(),true)
    ]
] in

-- call function 'visualize' to get visualization code for the circuit
visualize [
    -- customized circuit
    Circuit(
        circuit,[
            ("assembly","shape=assembly label=\\\"\\\"",""),
            ("insulator","shape=insulator label=\\\"\\\"","pF")
        ]
    )
]