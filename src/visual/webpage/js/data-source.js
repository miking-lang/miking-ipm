let input = ['1','0','0','0','0','1','1',];
let inputModel = new DFA(
    rankDirection = 'LR', 
 nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, 
 nodes = [
{id: '0', label:'1'},
{id: '1', label:'2'},
{id: '2', label:'3'},
{id: '3', label:'4'},
], 
 startID = '0',
acceptedIDs = ['1','2','3',],
transistions = [
 {from: '0', to: '1', label: '1'},
 {from: '1', to: '3', label: '0'},
 {from: '1', to: '2', label: '0'},
] 
 );

