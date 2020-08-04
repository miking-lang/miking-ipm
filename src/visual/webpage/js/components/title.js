/**
 * This function is responsible for visualizing the title.
 * Renders the title container.
 * @param {div} root The root element, defining where to render.
 * @param {string} className A string defining the css class of the title.
 * @param {string} title The title to visualize.
 */
function TitleRender(root, className, title) {
    root.innerHTML=`<h3 class="${className}">${title}</h3>`
}