-- Represents a state. Meant for use with DFA

-- It is formed of the state type which is user-defined and two functions: one for printing the state and one for equality checks.


type STATE = {
     state2tring: fun_2string,
     eqs: fun_eq,
     state: [a]
     }

-- constructor for a transition
let stateConstr = lam s. lam feq. lam f2s.
    let initState = {
    state2string = f2s,
    eqs = feq,
    state = s
    } in
    initState

let getStatesToString = lam s.
    s.state2string

let getEqStates = lam s.
    s.eqs

let getStates = lam s.
    s.state
