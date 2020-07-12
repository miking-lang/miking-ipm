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

        // Render the control panel view and add a model observer.
        this.update()
        model.addObserver(()=>this.update())
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
            </div>`
    }
    
    /**
     * Updates the control panel view.
     */
    update() {
        this.getNextButton().textContent = this.model.simulationIsFinished()
                                            ? `Restart simulation`
                                            : `Next`
        this.model.isAtStartState() 
            ? this.getPreviousButton().disabled = true
            : this.getPreviousButton().disabled = false
        let info = this.model.getInfoStatusAndText()
        this.getInfoContainer().innerHTML = info ? `<span class="${info.status}">${info.text}</span>` : ``
        this.getInputContainer().innerHTML = this.model.input.map((input,idx) =>
            `<span class="transition ${this.model.isCurrentInputIndex(idx) ? "active-transition" : ""}">
                ${input}
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
     * Gets the transition container.
     */
    getInputContainer() {
        return this.root.lastElementChild.firstElementChild
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
}
