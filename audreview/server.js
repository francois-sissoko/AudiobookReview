//Import the http module
//
//
var http = require('http')
//handle sending requests and returning respones 
//
function handleRequests(req, res) {
	res.end('Hello World')
}

//return string 
//
//create the server 

var server = http.createServer(handleRequests);


//Start server and listen on port x
server.listen(8080, function() {
	console.log('Listening on port 8080');
});
