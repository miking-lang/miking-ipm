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
    initView() {
        this.root.innerHTML=`
            <div>
                <span class="simulation-title">Change state:</span>
                <button id="previousButton" class="std-btn">Previous</button>
                <button id="nextButton" class="std-btn"></button>
            </div>
            <div id="transitions-container">
                <span></span>
                <span id="status-container"></span>
            </div>`;
    }

    /**
     * Updates the control panel view.
     * @param {function} graphCallback The callback function executed when the graphviz
     *                                 object has finished rendering.
     */
    update() {
        this.getNextButton().textContent = this.model.simulationIsFinished()
                                            ? `Restart simulation`
                                            : `Next`
        this.model.isAtStartState() 
            ? this.getPreviousButton().disabled = true
            : this.getPreviousButton().disabled = false
        this.getInfoContainer().innerHTML = 
            this.model.inputWasNotAccepted() ?
                `<span class="warning">Not accepted: The given input string was not accepted by the DFA.</span>`
            : this.model.transitionWasDenied() ?
                `<span class="warning">Not accepted: This transition is not supported at this state!</span>`
            : this.model.inputWasAccepted() ?
                `<span class="accepted">The input was accepted by the DFA</span>`
            : ``
        this.getTransitionsContainer().innerHTML = this.model.input.map((transition,idx) =>
            `<span class="transition ${this.model.isCurrentTranistionIndex(idx)
                                        ? + this.model.transitionWasDenied()
                                            ? "active-transition warning"
                                            : "active-transition"
                                        : ""}">
                ${transition}
            </span>`
        ).join("")
    }

    /*              GETTERS               */
    /**
     * Returns the container responsible for displaying statuses.
     */
    getInfoContainer() {
        return this.root.lastElementChild.lastElementChild
    }
    /**
     * Gets the next state button.
     */
    getNextButton() {
        return this.root.firstElementChild.lastElementChild
    }

    /**
     * Gets the previous state button.
     */
    getPreviousButton() {
        return this.root.firstElementChild.firstElementChild.nextElementSibling
    }

    /**
     * Gets the transition container.
     */
    getTransitionsContainer() {
        return this.root.lastElementChild.firstElementChild
    }
        
}