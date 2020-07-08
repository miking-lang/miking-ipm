let topComment = 
`/**
* Initializes the DFA object. 
* This file was automatically generated from src/visual/boot.js.
*/\n`;

const { exec } = require('child_process');



var fs = require('fs');
//Get the file that is being edited
var myArgs = process.argv.slice(2);
console.log('myArgs: ', myArgs);
if(myArgs.length > 1 || myArgs.length == 0){
    throw Error ('One file needs to be specified');
}
var sourceFile = myArgs[0];

//Specify the path to the miking executable in this variable:


//Compile the code first time
exec("mi " + sourceFile + ' > ' + __dirname +'/webpage/js/data-source.js', (error, stdout, stderr) => {
    if (error) {
        console.log(`error: ${error.message}`);
        return;
    }
    if (stderr) {
        console.log(`stderr: ${stderr}`);
        return;
    }
});

/** ::::TEMPORARY CHANGE MADE HERE:::: */
//Temporary: Create a JS source file displaying the JS object
const updateJS = graph =>
    fs.writeFile('webpage/js/data-source.js', topComment+graph, function (err) {
        if (err) throw err;
    });

// Inital render of graph
//updateJS(graph);

fs.watchFile(sourceFile, { interval: 1000 }, (curr, prev) => {
    console.log(`${sourceFile} file Changed`);
    //Re-extract the AST -> JSON from the MCore model to a JSON file and recompile the JS

    exec("mi " + sourceFile + ' > ' + __dirname +'/webpage/js/data-source.js', (error, stdout, stderr) => {
    if (error) {
        console.log(`error: ${error.message}`);
        return;
    }
    if (stderr) {
        console.log(`stderr: ${stderr}`);
        return;
    }
});
    
});
/** ::::TEMPORARY CHANGE MADE HERE:::: */


//This is being displayed on the browser: use index.html for the moment
var bs = require('browser-sync').create();


bs.init({
    watch: true,
    port: 3000,
    notify: false,
    server: __dirname + '/webpage'
});

bs.reload();











