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
					{"name":"3"},
					{"name":"2"},
					{"name":"1"},
				],
				"edges" : [
					{"from": "1", "to": "2", "label": "0"},
				], 
			},
			
		},
		{
			"type" : "graph",
			"model" : {
				"nodes" : [
					{"name":"2"},
					{"name":"1"},
				],
				"edges" : [
					{"from": "2", "to": "1", "label": "3"},
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
	]
}

