

include "../src/models/modelVisualizer.mc"
include "String.mc"

-- Here the series connection will be drawn on the same line,
-- while the ground will have its own line.
-- we would want the components to be divided evenly between these lines

mexpr
let circuit_wrong = Parallel [
    Component ("ground","g",Some 0.0,false),
    Series [
        Component ("battery","V1",Some 11.0,true),
        Component ("ammeter","amp1",None(),true),
        Component ("capacitator","c1",Some 8.0,true),
        Parallel [
            Component ("resistor","R1",Some 4.0,true),
            Component ("resistor","R2",Some 1.0,true)
        ],
        Component ("battery","V2",Some 11.0,true),
        Component ("ammeter","amp2",None(),true),
        Component ("capacitator","c2",Some 8.0,true),
        Component ("resistor","R3",Some 4.0,true),
        Component ("resistor","R4",Some 1.0,true)
    ]
] in

-- this is how we would like circuit_long_wrong to be displayed
-- (we would probably also want to use the edges on the sides as well as
-- the top and bottom in the future.)
let circuit = Parallel [
    Series [
        Component ("ground","g",Some 0.0,false),
        Component ("resistor","R4",Some 1.0,true),
        Component ("resistor","R3",Some 4.0,true),
        Component ("ammeter","amp2",None(),true),
        Component ("capacitator","c2",Some 8.0,true)
    ],
    Series [
        Component ("battery","V1",Some 11.0,true),
        Component ("ammeter","amp1",None(),true),
        Component ("capacitator","c1",Some 8.0,true),
        Parallel [
            Component ("resistor","R1",Some 4.0,true),
            Component ("resistor","R2",Some 1.0,true)
        ],
        Component ("battery","V2",Some 11.0,true)
    ]
] in

visualize [
    Circuit(circuit_wrong,[]),
    Circuit(circuit,[])
]