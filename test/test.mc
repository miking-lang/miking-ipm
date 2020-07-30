include "../src/models/modelVisualizer.mc"

mexpr
	let string2string = (lam b. b) in
	let eqString = setEqual eqchar in
	let char2string = (lam b. [b]) in

	-- create your DFA
	let alfabeth = ['0','1'] in
	let states = [
		{name="s0",displayName="start state"},
    {name="s1",displayName=""},
    {name="s2",displayName=""},
		{name="s3",displayName="accepted state"}] in
	let transitions = [
	("s0","s1",'1'),
	("s1","s1",'1'),
	("s1","s2",'0'),
	("s2","s1",'1'),
	("s2","s3",'0'),
  ("s3","s1",'1')
	] in

	let startState = "s0" in
	let acceptStates = ["s3"] in

	let dfa = dfaConstr states transitions alfabeth startState acceptStates eqString eqchar in

	visualize [
		-- accepted by the DFA
    DFA(dfa,"10010100",string2string, char2string),
    -- not accepted by the DFA
    DFA(dfa,"101110",string2string, char2string),
    -- not accepted by the DFA
    DFA(dfa,"1010001",string2string, char2string)
	] 
