/**
 * This function is responsible for visualizing the control panel.
 * Renders the DOM tree of the control panel. 
 * @param {div} root The root element, defining where to render.
 * @param {boolean} disablePrevious Whether to disable the previous button.
 * @param {boolean} simulationIsFinished Whether the simulation is finished
 * @param {function} nextButtonAction The action performed when next button is clicked.
 * @param {function} previousButtonAction The action performed when previous button is clicked.
 */
function ControlPanelRender(root, title, disablePrevious, simulationIsFinished, nextButtonAction, previousAction) {
    root.innerHTML=`
        <span class="simulation-title">${title}</span>
        <button class="previousButton std-btn" ${disablePrevious?"disabled=true":""}>Previous</button>
        <button class="nextButton std-btn">${simulationIsFinished?`Restart simulation`:`Next`}</button>
        `
    root.firstElementChild.nextElementSibling.onclick = () => previousAction()
    root.lastElementChild.onclick = () => nextButtonAction()
}