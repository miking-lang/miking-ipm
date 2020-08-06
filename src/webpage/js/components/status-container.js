
/**
 * This function is responsible for visualizing the status container.
 * Renders the status container.
 * @param {div} root The root element, defining where to render.
 * @param {object} info An object with two attributes, status and text.
 * @param {[string]} input An array of strings representing the input of the model.
 * @param {function} isCurrentInputIndex Checks whether a given input is the current input index or not.
 */
function StatusContainerRender(root, info, input, isCurrentInputIndex) {
    root.innerHTML = 
        `<span>
            ${input.map((input,idx) =>
                `<span class="transition ${isCurrentInputIndex(idx) ? "active-transition" : ""}">
                    ${input}
                </span>`
            ).join("")}
        </span>
        ${info?`<span class="${info.status}">${info.text}</span>`:``}`
}