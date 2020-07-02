include "../miking/stdlib/digraph.mc"

type DFA = { 
             states : [a],
             transitions: [(a,a,b)],
             alfabeth: [a],
             startState: a,
             acceptStates: [a]
            }

-- check that all labels for transitions are in the alfabeth
let dfaCheckLabels = lam trans. lam alf. lam eq.
    all (lam x. (any (lam y. eq x.2 y) alf)) trans

recursive
let dfaAddAllTransitions = lam trans. lam g.
    if (eqi (length trans) 0) then g
    else 
    let first = head trans in
    let rest = tail trans in
    dfaAddAllTransitions rest (digraphAddEdge first.0 first.1 first.2 g)
end

recursive
let dfaAddAllStates = lam s. lam g.
    if (eqi (length s) 0) then g
    else 
    let first = head s in
    let rest = tail s in
    dfaAddAllStates rest (digraphAddVertex first g)
end

let dfaInit = lam s. lam trans. lam eqv. lam eql.lam alf. lam startS. lam accS. 
    if and (dfaCheckLabels trans alf eql) (and (setIsSubsetEq eqv accS s) (setIsSubsetEq eqv startS s)) then
        let emptyDigraph = digraphEmpty eqv eql in
        let transitions = dfaAddAllTransitions trans (dfaAddAllStates s emptyDigraph) in
        {
        states = s,
        transitions = trans,
        alfabeth = alf,
        startState = startS,
        acceptStates = accS
        }
    -- TODO - give more information on what went wrong
    else error "Something went wrong"

-- TODO - add utests
