include "string.mc"

type BTree
    con BTree : (BTree) -> BTree
    con Node  : (a,BTree,BTree) -> BTree 
    con Leaf  : (a) -> BTree
    con Nil   : () -> BTree

mexpr
let tree = BTree(Node(2, Nil (), Leaf 3)) in
utest match tree with BTree t then t else 1 with Node(2, Nil (), Leaf 3) in
utest match tree with BTree Node t then t.0 else (negi 100) with 2 in
utest match tree with BTree Node t then t.1 else (negi 100) with Nil () in
utest match tree with BTree Node t then t.2 else (negi 100) with Leaf 3 in ()