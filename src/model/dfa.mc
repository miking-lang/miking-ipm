include "../../stdlib/digraph.mc"

-- according to the defenition of a DFA
type DFA = { 
             states : [a],
             transitions: [(a,a,b)],
             alfabeth: [a],
             startState: a,
             acceptStates: [a]
            }

-- check that all labels for transitions are in the alfabet<h
let dfaCheckLabels = lam trans. lam alf. lam eq.
    all (lam x. (any (lam y. eq x.2 y) alf)) trans

-- add multiple vertices to the graph g
recursive
let dfaAddAllVertices = lam v. lam g.
    if (eqi (length v) 0) then g
    else 
    let first = head v in
    let rest = tail v in
    dfaAddAllVertices rest (digraphAddVertex first g)
end

-- add multiple edges
recursive
let dfaAddAllEdges = lam e. lam g.
    if (eqi (length e) 0) then g
    else 
    let first = head e in
    let rest = tail e in
    dfaAddAllEdges rest (digraphAddEdge first.0 first.1 first.2 g)
end

-- check that values are accaptable for the DFA
let dfaCheckValues = lam trans. lam s. lam alf. lam eqv. lam eql. lam accS. lam startS.
    if not (dfaCheckLabels trans alf eql) then error "Some labels are not in the defined alfabeth" else
        if not (setIsSubsetEq eqv accS s) then error "Some accepted states do not exist" else 
        if not (setMem eqv startS s) then error "The start state does not exist"
        else true
        

-- constructor for DFA
let dfaConstr = lam s. lam trans. lam eqv. lam eql. lam alf. lam startS. lam accS. 
    if dfaCheckValues trans s alf eqv eql accS startS then
        let emptyDigraph = digraphEmpty eqv eql in
        let transitions = dfaAddAllEdges trans (dfaAddAllVertices s emptyDigraph) in
        {
        states = s,
        transitions = transitions,
        alfabeth = alf,
        startState = startS,
        acceptStates = accS
        }
    else {}

-- Transitions between two states are represented by edges between vertices
let dfaAddTransition = lam trans. lam dfa. {
        states = dfa.states,
        transitions = (digraphAddEdge trans.0 trans.1 trans.2 dfa.transitions),
        alfabeth = dfa.alfabeth,
        startState = dfa.startState,
        acceptStates = dfa.acceptStates
    }

-- States are represented by vertices in a directed graph
let dfaAddState = lam state. lam dfa. {
        states = snoc dfa.states state,
        transitions = (digraphAddVertex state dfa.transitions),
        alfabeth = dfa.alfabeth,
        startState = dfa.startState,
        acceptStates = dfa.acceptStates
    }

mexpr
let l1 = gensym() in
let l2 = gensym() in
let alfabeth = [l1] in
let states = [1,2,3] in
let transitions = [(1,2,l1),(2,3,l1)] in
let startState = 1 in
let acceptStates = [2,1] in 
let newDigraph = dfaAddAllVertices states (digraphEmpty eqi eqs) in
let newDfa = dfaConstr states transitions eqi eqs alfabeth startState acceptStates in
utest setEqual eqi states newDfa.states with true in
utest setEqual eqs alfabeth newDfa.alfabeth with true in
utest eqi startState newDfa.startState with true in
utest setEqual eqi acceptStates newDfa.acceptStates with true in
utest (digraphHasVertices states newDfa.transitions) with true in
utest (digraphHasEdges transitions newDfa.transitions) with true in
utest dfaCheckLabels transitions alfabeth eqs with true in
utest dfaCheckLabels [(1,2,l1),(1,2,l2)] alfabeth eqs with false in
utest (digraphHasEdges [(1,3,l1)] (dfaAddTransition (1,3,l1) newDfa).transitions) with true in
utest setEqual eqi [1,2,3,7] (dfaAddState 7 newDfa).states with true in
utest (digraphHasVertex 7 (dfaAddState 7 newDfa).transitions) with true in
()
