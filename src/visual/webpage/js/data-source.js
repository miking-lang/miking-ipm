let data = {
		"models": [
		{
			"type" : "dfa",
			"simulation" : {
				"input" : ["1","0","1","1",],
				"configurations" : ["a","b","c","a","b",],
				"state" : "not accepted",
			},
			"model" : {
				"states" : [
					{"name":"a"},
					{"name":"b"},
					{"name":"c"},
				],
				"transitions" : [
					{"from": "a", "to": "b", "label": "130"},
					{"from": "b", "to": "c", "label": "0"},
					{"from": "c", "to": "a", "label": "012"},
				], 
				"startID" : "a",
				"acceptedIDs" : ["a","c",],
			}
		},
		{
			"type" : "digraph",
			"model" : {
				"nodes" : [
					{"name":"E"},
					{"name":"D"},
					{"name":"C"},
					{"name":"B"},
					{"name":"A"},
				],
				"edges" : [
					{"from": "E", "to": "D", "label": "2"},
					{"from": "C", "to": "E", "label": "5"},
					{"from": "C", "to": "D", "label": "5"},
					{"from": "B", "to": "D", "label": "4"},
					{"from": "B", "to": "C", "label": "2"},
					{"from": "A", "to": "C", "label": "5"},
					{"from": "A", "to": "B", "label": "2"},
				], 
			},
			
		},
		{
			"type" : "graph",
			"model" : {
				"nodes" : [
					{"name":"4"},
					{"name":"3"},
					{"name":"2"},
					{"name":"1"},
				],
				"edges" : [
					{"from": "4", "to": "3", "label": ""},
					{"from": "3", "to": "1", "label": ""},
					{"from": "3", "to": "2", "label": ""},
					{"from": "2", "to": "1", "label": ""},
				], 
			},
			
		},
		{
			"type" : "btree",
			"model" : {
				"nodes" : [
					{"name":"2"},
					{"name":"3"},
					{"name":"4"},
					{"name":"5"},
				],
				"edges" : [
					 {"from": "2", "to": "3"},
					 {"from": "3", "to": "4"},
					 {"from": "2", "to": "5"},
				], 
			}
		},
		{
			"type" : "nfa",
			"model" : {
				"states" : [
					{"name":"a"},
					{"name":"b"},
					{"name":"c"},
				],
				"transitions" : [
					{"from": "a", "to": "b", "label": "130"},
					{"from": "b", "to": "c", "label": "0"},
					{"from": "c", "to": "a", "label": "012"},
				], 
				"startID" : "a",
				"acceptedIDs" : ["a","c",],
			}
		},
	]
}

