include "string.mc"

type BTree
     con BTree: (BTree) -> BTree
     con Node : (a,BTree,BTree) -> BTree 
     con Leaf : (a) -> BTree
     con Nil : () -> BTree


recursive
let count = lam tree.
    match tree with BTree t then
    count t.0
    else match tree with Node t then
      let left = t.1 in
      let right = t.2 in
      addi t.0 (addi (count left) (count right))
    else match tree with Leaf v then v
    else match tree with Nil _ then 0
    else error "Unknown node"
end



mexpr
let tree = BTree (Node(2, Node(3, Nil () , Leaf 2), Leaf 3), int2string) in
utest count tree  with 10 in ()
