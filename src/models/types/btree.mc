type BTreeModel
    con Node  : (a,BTree,BTree) -> BTree 
    con Leaf  : (a) -> BTree
    con Nil   : () -> BTree

type BTree = {
    tree: BTreeModel,
    eqv: a -> a -> Bool
}

-- checks if the defined tree is well formed.
recursive
let checkTreeStructure = lam tree.
    match tree with Node t then
        let _ = checkTreeStructure t.1 in checkTreeStructure t.2
    else match tree with Leaf v then ()
    else match tree with Nil n then ()
    else error "Something is wrong in the tree definition."
end

-- constructor for the BTree
let btreeConstr = lam tree. lam eqv.
    let _ = checkTreeStructure tree in
    {tree = tree, eqv = eqv}

-- get all edges of the BTree in correct render order.
recursive
let treeEdges = lam tree. lam from.
    match tree with {tree=t,eqv=_} then treeEdges t from
    else match tree with Node n then
        join [match from with () then [] else [(from,n.0,"")], 
            treeEdges n.1 n.0,
            treeEdges n.2 n.0]
    else match tree with Leaf v then [(from,v,"")]
    else []
end

-- get all vertices of the BTree in correct render order.
recursive
let treeVertices = lam tree.
    match tree with {tree=t,eqv=_} then treeVertices t
    else match tree with Node t then
        join [[t.0], 
        treeVertices t.1,
        treeVertices t.2]
    else match tree with Leaf v then [v]
    else []
end

mexpr
let treeModel = Node(2, Nil (), Leaf 3) in
let tree = btreeConstr treeModel eqi in
utest match treeModel with Node t then t.0 else (negi 100) with 2 in
utest match treeModel with Node t then t.1 else (negi 100) with Nil () in
utest match treeModel with Node t then t.2 else (negi 100) with Leaf 3 in
utest checkTreeStructure treeModel with () in
utest treeEdges tree () with [(2,3,"")] in
utest treeVertices tree with [2,3] in ()