/**
* Initializes the DFA object. 
* This file was automatically generated by src/visual/boot.js.
*/
let input = ["0", "0", "1", "0", "1", "1", "1", "0"]
let inputModel = new DFA(
    rankDirection = "LR",
    nodeSettings = {style: "filled", fillcolor: "white", shape: "circle"},
    startID = "n1",
    endIDs = ["n6"],
    nodes = [
        {name: "A", id:"n1"},
        {name: "B", id:"n2"},
        {name: "C", id:"n3"},
        {name: "D", id:"n4"},
        {name: "E", id:"n5"},
        {name: "F", id:"n6"}
    ], 
    transistions = [
        {from: "A", to: "B", label: "0"},
        {from: "A", to: "C", label: "1"},
        {from: "B", to: "B", label: "0"},
        {from: "B", to: "C", label: "1"},
        {from: "C", to: "D", label: "0"},
        {from: "C", to: "E", label: "1"},
        {from: "D", to: "B", label: "1"},
        {from: "E", to: "F", label: "0"}
    ]
)