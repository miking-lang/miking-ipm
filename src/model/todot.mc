include "model.mc"


let printList = lam list. 
    map (lam x. print x) list

let model2dot = lam edges. lam vertices. lam v2str. lam l2str. lam direction. lam graphType.
    let isGraph = setEqual eqchar "graph" graphType in
    let _ = print (if isGraph then "graph {" else "digraph {") in
    let _ = printList ["rankdir=", direction, ";\n"] in
    let _ = printList ["node [style=filled fillcolor=white shape=circle];"] in
    let _ = map 
        (lam v. 
            let _ = print (v2str v) in
            print " [];") 
        vertices in
    let _ = map
        (lam e. let _ = print (v2str e.0) in
            let _ = print (if isGraph then " -- " else " -> ") in
            let _ = print (v2str e.1) in
            let _ = print "[label=\"" in
            let _ = print (l2str e.2) in
            print "\"];")
        edges in
    let _ = print "}\n" in ()

let nfa2dot = lam edges. lam vertices. lam v2str. lam l2str. lam eq. lam direction. lam startState. lam acceptedStates.
    let _ = print "digraph {" in
    let _ = printList ["rankdir=", direction, ";\n"] in
    let _ = printList ["node [style=filled fillcolor=white shape=circle];"] in
    let _ = map 
        (lam v. 
            let _ = print (v2str v) in
            print (if (any (lam x. eq x v) acceptedStates) then "[shape=doublecircle];" else ";") ) 
        vertices in
    let _ = print "start [fontcolor = white color = white];" in
    let _ = printList ["start -> ", startState, "[label=start];"] in
    let _ = map
        (lam e. let _ = print (v2str e.0) in
            let _ = print " -> " in
            let _ = print (v2str e.1) in
            let _ = print "[label=\"" in
            let _ = print (l2str e.2) in
            print "\"];")
        edges in
    let _ = print "}\n" in ()