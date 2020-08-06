let data = {
    "models" : [
        {
            "type" : "graph",
            "model" : {
                "nodes" : [
                    {"id":"1", "label": "A"},
                    {"id":"2", "label": "B"},
                    {"id":"3", "label": "C"},
                    {"id":"4", "label": "D"},
                    {"id":"5", "label": "E"}
                ],
                "edges" : [
                    {"from": "1", "to": "2", "label": "0"},
                    {"from": "1", "to": "3", "label": "1"},
                    {"from": "2", "to": "2", "label": "0"},
                    {"from": "2", "to": "3", "label": "1"},
                    {"from": "3", "to": "4", "label": "0"},
                    {"from": "3", "to": "5", "label": "1"},
                    {"from": "4", "to": "2", "label": "1"}
                ]
            }
        },
        {
            "type" : "dfa",
            "simulation":{
                "input" : ["0", "1"],
                "configurations" : ["1", "2", "3"],
                "status" : "stuck"
            },
            "model" : {
                "states" : [
                    {"id":"1", "label": "A"},
                    {"id":"2", "label": "B"},
                    {"id":"3", "label": "C"},
                    {"id":"4", "label": "D"},
                    {"id":"5", "label": "E"}
                ],
                "acceptedIDs" : ["5"],
                "startID" : "1",
                "transitions" : [
                    {"from": "1", "to": "2", "label": "0"},
                    {"from": "1", "to": "3", "label": "1"},
                    {"from": "2", "to": "2", "label": "0"},
                    {"from": "2", "to": "3", "label": "1"},
                    {"from": "3", "to": "4", "label": "0"},
                    {"from": "3", "to": "5", "label": "1"},
                    {"from": "4", "to": "2", "label": "1"}
                ]
            }
        }
    ]
}