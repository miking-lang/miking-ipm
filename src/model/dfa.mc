include "graph.mc"
include "char.mc"
include "map.mc"
include "string.mc"

-- Represents a deterministic finite automaton.
-- Equality and print functions are required for the states (eqv,s2s) and labels (eql,l2s) for the 
-- construct function (dfaConstr).

-- States are represented by a vertex in a directed graph. They are unique integers, there cannot be two states whose value of the
-- equality function is true.

-- transitions are represented as edges in a directed graph (digraph), where the vertices are states
-- All labels for the transitions are chars. All labels between two states also has to be unique. 

type DFA = {
             graph: Digraph,
             alfabeth: [a],
             startState: a,
             acceptStates: [a],
	     s2s: a ->_ ->_ -> String,
	     l2s: a ->_ ->_ -> String
            }
-- get equality function for states
let dfaGetEqv = lam dfa.
    dfa.graph.eqv

-- get equality functions for labels
let dfaGetEql = lam dfa.
    dfa.graph.eql

-- get all states in dfa
let dfaGetStates = lam dfa.
    digraphVertices dfa.graph

-- get all transitions in dfa
let dfaGetTransitions = lam dfa.
    digraphEdges dfa.graph


-- check for specific duplicate label
recursive
let checkSpecificDuplicate = lam trans. lam rest. lam eqv. lam eql.
    if(eqi (length rest) 0) then false
    else
    let first = head rest in
    let rest = tail rest in
    if(and (eqv first.0 trans.0) (eql first.2 trans.2)) then true
    else checkSpecificDuplicate trans rest eqv eql
end

-- check for duplicate labels
recursive
let checkDuplicateLabels = lam trans. lam eqv. lam eql.
    if(eqi (length trans) 1) then (false, (0,0))
    else
    let first = head trans in
    let rest = tail trans in
    if(checkSpecificDuplicate first rest eqv eql) then (true, (first.0, first.2))
    else
    checkDuplicateLabels rest eqv eql
end

-- check that all labels for transitions are in the alfabeth
let dfaCheckLabels = lam graph. lam alf. lam eql.
    all (lam x. (any (lam y. eql x.2 y) alf)) graph

-- check that values are accaptable for the DFA
let dfaCheckValues = lam trans. lam s. lam alf. lam eqv. lam eql. lam accS. lam startS.
    if not (dfaCheckLabels trans alf eql) then error "Some labels are not in the defined alfabeth" else
        if not (setIsSubsetEq eqv accS s) then error "Some accepted states do not exist" else 
        if not (setMem eqv startS s) then error "The start state does not exist"
        else
	let err = checkDuplicateLabels trans eqv eql in
	if(err.0) then error (strJoin "" ["There are duplicate labels for same state outgoing transition at: STATE ", (int2string (err.1).0), ", LABEL ", [(err.1).1]])
	else true

-- States are represented by vertices in a directed graph
let dfaAddState =  lam dfa. lam state.{
        graph = (digraphAddVertex {data = state, id = (length (dfaGetStates dfa))} dfa.graph),
        alfabeth = dfa.alfabeth,
        startState = dfa.startState,
        acceptStates = dfa.acceptStates,
	s2s = dfa.s2s,
	l2s = dfa.l2s
    }


-- maps a state to its id in dfa.states
recursive
let stateID = lam state. lam dfa. lam states.
    if(eqi (length states) 0) then (negi 1)
    else
    let first = head states in --{data: x, id: 1}
    -- state = x
    -- first = {data: x, id: 1}
    let rest = tail states in
    if((dfaGetEqv dfa) {data = state} {data = first.data}) then first.id
    else
    stateID state dfa rest
    
end


-- Transitions between two states are represented by edges between vertices
let dfaAddTransition = lam dfa. lam trans.
    let state1 = stateID trans.0 dfa (dfaGetStates dfa) in
    let state2 = stateID trans.1 dfa (dfaGetStates dfa) in
    {
        graph = (digraphAddEdge {data = trans.0, id = state1} {data = trans.1, id = state2} trans.2 dfa.graph),
        alfabeth = dfa.alfabeth,
        startState = dfa.startState,
        acceptStates = dfa.acceptStates,
	s2s= dfa.s2s,
	l2s= dfa.l2s
    }


-- add the startState (from dfa.startState) as a {name=_,id=_}
let getStartStateID =  lam initDfa.
{
	graph = initDfa.graph,
	alfabeth = initDfa.alfabeth,
	startState = {data = initDfa.startState, id = stateID initDfa.startState initDfa (dfaGetStates initDfa)},
	acceptStates = initDfa.acceptStates,
	s2s = initDfa.s2s,
	l2s = initDfa.l2s
}
-- add the accepted states (from dfa.acceptStates) as a list of {name=_,id=_}
let getAcceptedStatesID = lam initDfa.
{
    graph = initDfa.graph,
    alfabeth = initDfa.alfabeth,
    startState = initDfa.startState,
    acceptStates = map (lam s. {data = s, id = (stateID s initDfa (dfaGetStates initDfa))}) initDfa.acceptStates,
    s2s = initDfa.s2s,
    l2s = initDfa.l2s
}

-- equality function for states. If s1 and s2 have the same data they are considered to be equal.
let fun_eqv = lam eqv. lam s1. lam s2.
    if(eqv s1.data s2.data) then true
    else false
    
-- constructor for DFA
let dfaConstr = lam s. lam trans. lam alf. lam startS. lam accS. lam eqv. lam eql. lam s2s. lam l2s.
    let eqv1 = fun_eqv eqv in
    if dfaCheckValues trans s alf eqv eql accS startS then
        let emptyDigraph = digraphEmpty eqv1 eql in
        let initDfa = {
        graph = emptyDigraph,
        alfabeth = alf,
        startState = startS,
        acceptStates = accS,
	s2s = s2s,
	l2s = l2s
        } in
        getAcceptedStatesID (getStartStateID (foldl dfaAddTransition (foldl dfaAddState initDfa s) trans))
	else {}

-- returns true if state s is a accapted state in the dfa
let isAcceptedState = lam s. lam dfa. 
    setMem dfa.graph.eqv s dfa.acceptStates

-- check if there is a transition with label lbl from state s
let stateHasTransition = lam s. lam trans. lam lbl.
    let neighbors = digraphEdgesFrom s trans in
    --check if lbl is a label in the neighbors list
    setMem trans.eql lbl (map (lam x. x.2) neighbors)

-- get next state from state s with label lbl. Throws error if no transition is found
let nextState = lam from. lam graph. lam lbl.
    let neighbors = digraphEdgesFrom from graph in
    let nxt = find (lam x. graph.eql x.2 lbl) neighbors in
    match nxt with Some t then
    -- The transition contains (from,to,label). Take out 'to' state
    t.1
    else error "No transition was found"

-- goes through the dfa, one char of the input at a time. Returns a list of states
recursive
let makeInputPath = lam inpt. lam dfa. lam currentState.
    let graph = dfa.graph in
    if (eqi (length inpt) 0) then 
        if (isAcceptedState currentState dfa) then [currentState.id,1]
        else [currentState.id,(negi 1)]
    else 
    let first = head inpt in
    let rest = tail inpt in 
    -- check if transition exists. If yes, go to next state
    if stateHasTransition currentState graph first then
        join [[currentState.id],makeInputPath rest dfa (nextState currentState graph first)]
    else [currentState.id,0]
end

-- -1 = not accepted
-- 0 = stuck
-- 1 = accepted

mexpr
let alfabeth = ['0','1'] in
let states = [0,1,2] in
let transitions = [(0,1,'1'),(1,1,'1'),(1,2,'0'),(2,2,'0'),(2,1,'1')] in
let startState = 0 in
let acceptStates = [2] in 
let newDfa = dfaConstr states transitions alfabeth startState acceptStates eqi eqchar int2string (lam b. [b]) in
--utest setEqual eqchar alfabeth newDfa.alfabeth with true in
--utest eqi startState newDfa.startState with true in
--utest setEqual eqi acceptStates newDfa.acceptStates with true in
--utest (digraphHasVertices (dfaGetStates newDfa) newDfa.graph) with true --in
--utest (digraphHasEdges transitions newDfa.graph) with true in
--utest dfaCheckLabels transitions alfabeth with true in
--utest dfaCheckLabels [(1,2,'2')] alfabeth with false in
--utest (digraphHasEdges [(1,2,'1')] (dfaAddTransition newDfa (1,2,'1')).g--raph) with true in
--utest (digraphHasVertex 7 (dfaAddState newDfa 7).graph) with true in
--utest isAcceptedState 2 newDfa with true in
--utest isAcceptedState 3 newDfa with false in
--utest nextState 1 newDfa.graph '0' with 2 in
utest makeInputPath "1010" newDfa newDfa.startState with [0,1,2,1,2,1] in
utest makeInputPath "1011" newDfa newDfa.startState with [0,1,2,1,1,negi 1] in
utest makeInputPath "010" newDfa newDfa.startState with [0,0] in
utest makeInputPath "10" newDfa newDfa.startState with [0,1,2,1] in
utest makeInputPath "00000000111111110000" newDfa newDfa.startState with [0,0] in
utest makeInputPath "" newDfa newDfa.startState with [0,negi 1] in
()
