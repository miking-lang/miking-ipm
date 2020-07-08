let activeStates = ['0','1','denied'];
let input = ['1','1',];
let inputModel = new DFA(
    rankDirection = 'LR', 
 nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, 
 nodes = [
{id: '0', label:'a'},
{id: '1', label:'b'},
{id: '2', label:'c'},
], 
 startID = '0',
acceptedIDs = ['0','2',],
transistions = [
 {from: '0', to: '1', label: '1'},
 {from: '1', to: '2', label: '0'},
 {from: '2', to: '0', label: '1'},
] 
 );

