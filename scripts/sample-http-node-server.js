var http = require('http');

http.createServer(function(req, res) {
  for (var key in req) {
    res.write(key + '\n');
  }
  res.write(req.statusCode + '\n');
  res.end('Done');
}).listen(3000);

console.log("Listening on porrt 3000");
