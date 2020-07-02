var fs = require('fs');

//Get the file that is being edited
var myArgs = process.argv.slice(2);
console.log('myArgs: ', myArgs);
if(myArgs.length > 1 || myArgs.length == 0){
    throw Error ('One file needs to be specified');
}
var sourceFile = myArgs[0];


//Create a folder in which the webpage is created and watched

var dir = './webpage';

if (!fs.existsSync(dir)){
    fs.mkdirSync(dir);
}

//Temporary: Create a html file to display

fs.writeFile('webpage/index.html', '<!DOCTYPE html><html><body><h1>Miking</h1></body></html>', function (err) {
  if (err) throw err;
});  


fs.watchFile(sourceFile, { interval: 1000 }, (curr, prev) => {
    console.log(`${sourceFile} file changed...`);
    //Re-extract the AST -> JSON from the MCore model to a JSON file and recompile the JS
});


//This is being displayed on the browser: use index.html for the moment
var bs = require('browser-sync').create();

bs.init({
    open: false,
    watch: true,
    notify: false,
    server: "./webpage"
});

bs.reload("*.html");



