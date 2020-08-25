-- This is an example file for generating and visualizing
-- a NFA model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"


mexpr
-- Define functions to display your States and Labels and equality checks for States and Labels
let string2string = (lam b. b) in
let char2string = (lam b. [b]) in

-- Defining the components of a NFA
let nfaStates = ["a","b","c","d","e","f"] in
let nfaTransitions = [("a","b",'1'),("b","c",'0'),("c","d",'2'),("c","e",'2'),("d","a",'1'),("e","f",'1')] in
let nfaStartState = "a" in
let nfaAcceptStates = ["a"] in

-- constructing the NFA
let nfa = nfaConstr nfaStates nfaTransitions nfaStartState nfaAcceptStates eqStr eqchar in

-- The input for simulation is given here as the second argument
-- in the constructor.
visualize [
	NFA(nfa, "1021", string2string, char2string,"LR",[]),
	NFA(nfa, "102", string2string, char2string,"LR",[])
]
