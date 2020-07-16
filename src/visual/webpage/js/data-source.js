let data = {
		"models": [
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
	]
}

