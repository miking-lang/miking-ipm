class ControlPanelView {
    /**
     * This class is responsible for displaying the control panel view.
     * Includes render methods, and getters for elements in the DOM tree.
     * 
     * @param {ApplicationModel} model 
     * @param {<div>} root 
     */
    constructor(model, root){
        this.root=root
        this.model=model
        this.initView()
    }
    
    /**
     * Renders the DOM tree of the control panel view.
     */
    initView = () =>
        this.root.innerHTML=`
            <div>
                <span class="std-option-title">Active color:</span>
                <select name="nodeColors" id="nodeColors" class="std-btn">
                    ${this.model.getAvailableColors().map(color =>
                        `<option value="${color.value}">${color.label}</option>`
                    )}
                </select>
                <button id="nextButton" class="std-btn"></button>
            </div>
            <div id="transitionsContainer">
            </div>`;

    /**
     * Updates the control panel view.
     * @param {function} graphCallback The callback function executed when the graphviz
     *                                 object has finished rendering.
     */
    update = () => {
        this.getNextButton().textContent = this.model.simulationIsFinished()
                                            ? "Restart simulation" 
                                            : "Next"
        this.getTransitionsContainer().innerHTML = this.model.input.map((transition,idx) =>
            `<span class="transition ${this.model.isCurrentTranistionIndex(idx)?"activeTransition":""}">
                ${transition}
            </span>`
        ).join("")
    }

    /*              GETTERS               */
    /**
     * Gets the active color selection.
     */
    getActiveColorSelection = () =>  
        this.root.firstElementChild.firstElementChild.nextSibling.nextSibling

    /**
     * Gets the next state button.
     */
    getNextButton = () => 
        this.root.firstElementChild.lastElementChild

    /**
     * Gets the transition container.
     */
    getTransitionsContainer = () =>
        this.root.lastElementChild
        
}