let input = ['1','0','0','0','0','1','1',];
let inputModel = new DFA(
    rankDirection = 'LR', 
 nodeSettings = {style: 'filled', fillcolor: 'white', shape: 'circle'}, 
 nodes = [
{name: '1', id:'6'},
{name: '2', id:'5'},
{name: '3', id:'4'},
{name: '4', id:'3'},
{name: '5', id:'2'},
{name: '6', id:'1'},
], 
 startID = '6',
endIDs = ['5','4','3','2','1',],
transistions = [
 {from: '1', to: '2', label: '1'},
] 
 );
