let data = {"models": [
{
 "type" : "tree",
 "model" : {
 "nodes" : [
{"name":"2", "displayName": "root" },
{"name":"3", "displayName": "node" },
{"name":"4", "displayName": "leaf" },
{"name":"5", "displayName": "node" },
],
 "edges" : [
{"from": "2", "to": "3", "label": ""},
{"from": "3", "to": "4", "label": ""},
{"from": "2", "to": "5", "label": ""},
], 
 },
},
{
 "type" : "nfa",
 "simulation" : {
 "input" : ["1","0","2","1",],
 "configurations" : [
{"state": "a","status": "","index": -1},
{"state": "b","status": "","index": 0},
{"state": "c","status": "","index": 1},
{"state": "d","status": "","index": 2},
{"state": "a","status": "accepted","index": 3},
],
},
 "model" : {
 "states" : [
{"name":"a", "displayName": "start" },
{"name":"b", "displayName": "b" },
{"name":"c", "displayName": "c" },
{"name":"d", "displayName": "d" },
{"name":"e", "displayName": "e" },
{"name":"f", "displayName": "f" },
],
 "transitions" : [
{"from": "a", "to": "b", "label": "1"},
{"from": "b", "to": "c", "label": "0"},
{"from": "c", "to": "d", "label": "2"},
{"from": "c", "to": "e", "label": "2"},
{"from": "d", "to": "a", "label": "1"},
{"from": "e", "to": "f", "label": "1"},
], 
 "startState" : "a",
 "acceptedStates" : ["a",],
}
},
{
 "type" : "nfa",
 "simulation" : {
 "input" : ["1","0","1","2","1",],
 "configurations" : [
{"state": "a","status": "","index": -1},
{"state": "b","status": "","index": 0},
{"state": "c","status": "stuck","index": 1},
],
},
 "model" : {
 "states" : [
{"name":"a", "displayName": "a" },
{"name":"b", "displayName": "b" },
{"name":"c", "displayName": "c" },
{"name":"d", "displayName": "d" },
{"name":"e", "displayName": "e" },
{"name":"f", "displayName": "f" },
],
 "transitions" : [
{"from": "a", "to": "b", "label": "1"},
{"from": "b", "to": "c", "label": "0"},
{"from": "c", "to": "d", "label": "2"},
{"from": "c", "to": "e", "label": "2"},
{"from": "d", "to": "a", "label": "1"},
{"from": "e", "to": "f", "label": "1"},
], 
 "startState" : "a",
 "acceptedStates" : ["a",],
}
}]
}

