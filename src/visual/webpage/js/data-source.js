let input = ['1','0','0','0','0','1','1',];
let inputModel = new DFA(
    rankDirection = 'LR', 
 nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, 
 nodes = [
{name: '1', id:'1'},
{name: '2', id:'2'},
{name: '3', id:'3'},
], 
 startID = '1',
endIDs = ['2','3',],
transistions = [
 {from: '1', to: '2', label: '1'},
 {from: '2', to: '3', label: '0'},
] 
 );

