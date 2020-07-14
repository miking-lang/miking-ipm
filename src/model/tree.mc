
type Tree
     con Node : (Tree,Tree) -> Tree 
     con Leaf : (a) -> Tree 

recursive
let count = lam tree.
    match tree with Node t then
      let left = t.0 in
      let right = t.1 in
      addi (count left) (count right)
    else match tree with Leaf v then v
    else error "Unknown node"
end

mexpr
let tree = Node(Node(Leaf 4, Leaf 2), Leaf 3) in
utest count tree with 9 in ()
