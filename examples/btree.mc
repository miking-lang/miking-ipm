-- This is an example file for generating and visualizing
-- a Binary Tree model

-- You need to source this file in order to visualize models.
include "../src/models/modelVisualizer.mc"



mexpr


-- The input for simulation is given here as the second argument
-- in the constructor.
-- Last argument is a list that maps states to displayNames.
-- The purpose is to visualize a state's name differently if
-- needed. This examples maps the state "s0" to the output name
-- of "start state".
visualize [
	-- accepted by the DFA
	DFA(dfa,"10010100",string2string, char2string,[("s0","start state"),("s3","accept state")]),
	-- not accepted by the DFA
	DFA(dfa,"101110",string2string, char2string, []),
	-- not accepted by the DFA
	DFA(dfa,"1010001",string2string, char2string, [])
	]
