include "../../stdlib/digraph.mc"
include "../../stdlib/char.mc"

-- according to the defenition of a DFA
type DFA = { 
             states : [a],
             transitions: Digraph,
             alfabeth: [a],
             startState: a,
             acceptStates: [a]
            }

-- check that all labels for transitions are in the alfabeth
let dfaCheckLabels = lam trans. lam alf.
    all (lam x. (any (lam y. eqchar x.2 y) alf)) trans

-- check that values are accaptable for the DFA
let dfaCheckValues = lam trans. lam s. lam alf. lam eqv. lam eql. lam accS. lam startS.
    if not (dfaCheckLabels trans alf) then error "Some labels are not in the defined alfabeth" else
        if not (setIsSubsetEq eqv accS s) then error "Some accepted states do not exist" else 
        if not (setMem eqv startS s) then error "The start state does not exist"
        else true

-- States are represented by vertices in a directed graph
let dfaAddState = lam state. lam dfa. {
        states = snoc dfa.states state,
        transitions = (digraphAddVertex state dfa.transitions),
        alfabeth = dfa.alfabeth,
        startState = dfa.startState,
        acceptStates = dfa.acceptStates
    }


-- add multiple vertices to the graph g
recursive
let dfaAddAllStates = lam v. lam dfa.
    if (eqi (length v) 0) then dfa
    else 
    let first = head v in
    let rest = tail v in
    dfaAddAllStates rest (dfaAddState first dfa)
end

-- Transitions between two states are represented by edges between vertices
let dfaAddTransition = lam trans. lam dfa. {
        states = dfa.states,
        transitions = (digraphAddEdge trans.0 trans.1 trans.2 dfa.transitions),
        alfabeth = dfa.alfabeth,
        startState = dfa.startState,
        acceptStates = dfa.acceptStates
    }

-- add multiple edges
recursive
let dfaAddAllTransitions = lam v. lam dfa.
    if (eqi (length v) 0) then dfa
    else 
    let first = head v in
    let rest = tail v in
    dfaAddAllTransitions rest (dfaAddTransition first dfa)
end

-- constructor for DFA
let dfaConstr = lam s. lam trans. lam alf. lam startS. lam accS. 
    -- equality functions for states (eqv) and labels (eql)
    let eqv = eqi in
    let eql = eqchar in
    if dfaCheckValues trans s alf eqv eql accS startS then
        let emptyDigraph = digraphEmpty eqv eql in
        let initDfa = {
        states = [],
        transitions = emptyDigraph,
        alfabeth = alf,
        startState = startS,
        acceptStates = accS
        } in
        dfaAddAllTransitions trans (dfaAddAllStates s initDfa)
    else {}

-- returns true if state s is a accapted state in the dfa
let isAcceptedState = lam s. lam dfa. 
    setMem dfa.transitions.eqv s dfa.acceptStates

-- check if there is a transition with label lbl from state s
let stateHasTransition = lam s. lam trans. lam lbl.
    let neighbors = digraphEdgesFrom s trans in
    --check if lbl is a label in the neighbors list
    setMem trans.eql lbl (map (lam x. x.2) neighbors)

-- get next state from state s with label lbl. Throws error if no transition is found
let nextState = lam from. lam trans. lam lbl.
    let neighbors = digraphEdgesFrom from trans in
    let nxt = find (lam x. trans.eql x.2 lbl) neighbors in
    match nxt with Some t then
    -- The transition contains (from,to,label). Take out 'to' state
    t.1
    else error "No transition was found"

-- goes through the dfa, one char of the input at a time
recursive
let checkAcceptedInput = lam inpt. lam dfa. lam currentState.
    let trans = dfa.transitions in
    if (eqi (length inpt) 0) then setMem trans.eqv currentState dfa.acceptStates 
    else 
    let first = head inpt in
    let rest = tail inpt in 
    -- check if transition exists. If yes, go to next state
    if stateHasTransition currentState trans first then
        checkAcceptedInput rest dfa (nextState currentState trans first)
    else false
end

mexpr
let alfabeth = ['0','1'] in
let states = [0,1,2] in
let transitions = [(0,1,'1'),(1,1,'1'),(1,2,'0'),(2,2,'0'),(2,1,'1')] in
let startState = 0 in
let acceptStates = [2] in 
let newDfa = dfaConstr states transitions alfabeth startState acceptStates in
utest setEqual eqi states newDfa.states with true in
utest setEqual eqchar alfabeth newDfa.alfabeth with true in
utest eqi startState newDfa.startState with true in
utest setEqual eqi acceptStates newDfa.acceptStates with true in
utest (digraphHasVertices states newDfa.transitions) with true in
utest (digraphHasEdges transitions newDfa.transitions) with true in
utest dfaCheckLabels transitions alfabeth with true in
utest dfaCheckLabels [(1,2,'2')] alfabeth with false in
utest (digraphHasEdges [(1,2,'1')] (dfaAddTransition (1,2,'1') newDfa).transitions) with true in
utest setEqual eqi [0,1,2,7] (dfaAddState 7 newDfa).states with true in
utest (digraphHasVertex 7 (dfaAddState 7 newDfa).transitions) with true in
utest isAcceptedState 2 newDfa with true in
utest isAcceptedState 3 newDfa with false in
utest nextState 1 newDfa.transitions '0' with 2 in
utest checkAcceptedInput "1010" newDfa newDfa.startState with true in
utest checkAcceptedInput "1011" newDfa newDfa.startState with false in
utest checkAcceptedInput "010" newDfa newDfa.startState with false in
utest checkAcceptedInput "10" newDfa newDfa.startState with true in
utest checkAcceptedInput "00000000111111110000" newDfa newDfa.startState with false in
()







