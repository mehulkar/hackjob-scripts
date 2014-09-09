#!/usr/bin/env node
/*
 * This script demonstrates how to spawn
 * a ruby process and log the output to a file
 * The user can pass in an optional "stream"
 * argument on the CLI to redirect stdout
 * to a log file using node streams.
 *
 * Not really sure what I was experimenting with
 * here. I think the purpose was to figure out
 * how to start a Ruby server with a Node child process
 * and send stdout to a file in real time. By default
 * stdout doesn't get redirected until the childProcess
 * is killed or ends.
 *
 * @author: mehulkar
*/
var childProcess  = require('child_process'),
    fs            = require('fs');

var logFile = './log.log';

// arguments for command
var args = [
  "-e",
 "loop { $stdout.flush;  puts ['hello', 'no', 'yes'].sample; sleep 1 }"
];

// detach process from parent
var opts = { detached: true };

// Either create a writeStream or open a file for appending
if (process.argv[2] === 'stream') {
  var stream = fs.createWriteStream(logFile);
  opts.stdio = [stream, stream, stream];
} else {
  var writable  = fs.openSync(logFile, 'a');
  opts.stdio    = [writable, writable, writable];
}


var spawn = childProcess.spawn('ruby', args, opts); // spawn the process

console.log('Starting on PID: ' + spawn.pid);       // log the PID

// allow parent to quit without waiting for child to quit
// (not sure why this is needed in addition to detached: true option above)
spawn.unref();
