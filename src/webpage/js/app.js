function render() {
    ws = new WebSocket('ws://localhost' + (location.port ? ':'+location.port:'') + '/ws');
    ws.onmessage = function(x) {
		let dataModels = JSON.parse(x.data);
		if (dataModels.models) {
			document.getElementById("app").innerHTML = "";
			const root = document.body.querySelector("#app");
			// Maps over all models in the generated output.
			
			dataModels.models.map((model, idx) => {
				// Creates a root element for the model and add it to the root of the application.
				let modelRoot = document.createElement(`div`);
				modelRoot.className = "container";
				root.appendChild(modelRoot);
				// Creates the controller for the specified model if the type is supported.
				["tree", "graph", "digraph", "nfa", "dfa"].includes(model.type)
					? model.simulation 
						? new NFAController(model,modelRoot) 
						: new ModelController(model,modelRoot)
					: model.type === "circuit"
						? new CircuitController(model,modelRoot)
						: modelRoot.innerHTML = `<div class="warning">Unsopported model type</div>`;
				}
			)
		} else {
			document.getElementById("error-container").textContent += dataModels;
		}
    }
}

render()