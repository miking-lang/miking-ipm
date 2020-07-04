let dfa = new DFA(
    rankDirection = 'LR', 
 nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, 
 nodes = [
{name: '1', id:'5', settings: {fillcolor: 'green'}},
{name: '2', id:'4', settings: {}},
{name: '3', id:'3', settings: {}},
{name: '4', id:'2', settings: {shape: 'doublecircle'}},
{name: '5', id:'1', settings: {shape: 'doublecircle'}},
], 
 transistions = [
 {from: '1', to: '2', label: 'hardcodedatm'},
 {from: '2', to: '3', label: 'hardcodedatm'},
 {from: '3', to: '4', label: 'hardcodedatm'},
] 
 )

