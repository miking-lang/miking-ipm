class ControlPanelController {
    /**
     * Controller class for the control panel view.
     * 
     * @param {ApplicationModel} model
     * @param {<div>} root
     */
    constructor(model, root){
        this.controlPanelView = new ControlPanelView(model, root)
        
        // Render the control panel view and add a model observer.
        this.controlPanelView.update()
        model.addObserver(()=>this.controlPanelView.update())

        // Add event listeners
        this.controlPanelView.getNextButton().addEventListener("click", () => model.getNextState())
        this.controlPanelView.getActiveColorSelection().addEventListener("change", e => 
            model.setActiveNodeColor(e.target.value)
        )
    }
}