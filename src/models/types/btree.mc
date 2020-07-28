include "string.mc"

type BTree
    con BTree : (BTree) -> BTree
    con Node  : (a,BTree,BTree) -> BTree 
    con Leaf  : (a) -> BTree
    con Nil   : () -> BTree

recursive
let btreeEdgesPrintDot = lam tree. lam from. lam node2str.
    match from with None () then
        match tree with Node n then
            let _ = btreeEdgesPrintDot n.1 n.0 node2str in
            let _ = btreeEdgesPrintDot n.2 n.0 node2str in ()
        else "" 
    else match tree with Node n then
        let _ = map (lam x. print x) [(node2str from), "->" ,(node2str n.0),"\n"] in 
        let _ = btreeEdgesPrintDot n.1 n.0 node2str in
        let _ = btreeEdgesPrintDot n.2 n.0 node2str in ()
    else match tree with Nil () then ""
    else match tree with Leaf v then
        let _ = map (lam x. print x) [(node2str from), "->" ,(node2str v),"\n"] in ()
    else ""
end

let btreePrintDot = lam tree. lam node2str.
    let _ = print "digraph {" in 
    let _  = btreeEdgesPrintDot tree (None()) node2str in 
    let _ = print "} " in
    ()

mexpr
let tree = BTree(Node(2, Nil (), Leaf 3)) in
utest match tree with BTree t then t else 1 with Node(2, Nil (), Leaf 3) in
utest match tree with BTree Node t then t.0 else (negi 100) with 2 in
utest match tree with BTree Node t then t.1 else (negi 100) with Nil () in
utest match tree with BTree Node t then t.2 else (negi 100) with Leaf 3 in ()