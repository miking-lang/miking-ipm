var fs = require('fs');

//This is a hardcoded path to model that's gonna be visualized

const sourceFile = '../model/model.mc';

fs.watchFile(sourceFile, { interval: 1000 }, (curr, prev) => {
    console.log(`${sourceFile} file Changed`);
    //Re-extract the AST -> JSON from the MCore model to a JSON file and recompile the JS
});


//This is being displayed on the browser: use index.html for the moment
var bs = require('browser-sync').create();

bs.init({
    watch: true,
    port: 8080,
    notify: false,
    server: "."
});

bs.reload("*.html");



