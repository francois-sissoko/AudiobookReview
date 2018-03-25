//Import the http module
//
//
var http = require('http')
//handle sending requests and returning respones 
//
var data = '';
var wsp = require('./wordsfile')
function handleRequests(req, res) {
	req.on('data',function(chunk) {
		data += chunk;
	})
	req.on('end',function() {
		console.log('POST data: %s', data);
	})
	req.on('data',onData);
	res.end('Hello World');
}

//return string 
//
//create the server 

var server = http.createServer(handleRequests);


//Start server and listen on port x
server.listen(8080, function() {
	console.log('Listening on port 8080');
});

//Using EventEmitters
//Observer pattern where object represents the source of 
//several kids of events you specific event by calling the
//'on()' function, name of the event, callback closure as patameters 
//

//var data = '';
//req.on('data', function(chunk) {
//	data += chunk;
//})
//req.on('end', function() {
//	console.log('POST data: %s', data);
//})

//You can remove event listeners by using the removeListener function
//Please note that the argument to this function is a reference to callback
//you are trying to remove, not the name of the event 
//

var onData = function(chunk) {
	console.log(chunk);
	req.removeListener(onData);
}
//req.on('data',onData);





