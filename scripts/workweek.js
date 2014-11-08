#!/usr/bin/env node

var fs = require('fs');
var exec = require('shelljs').exec;

var diffStats = [];

function workweek(dir, gitTimeFrame) {
  process.chdir(dir);
  // if this is not a git repo
  if (fs.existsSync('.git')) {

    // ask git for the first commit from gitTimeFrame ago
    var cmd           = 'git log --oneline --since="' + gitTimeFrame + '"';

    // count num of commits by piping the log output into unix `wc`
    // TODO use js to parse log output, but couldn't figure out how to
    // silence exec's stdout, so output is noisy
    var numOfCommits = exec(cmd + '| wc -l').output.trim();

    // This is the alternative to using wc
    /*
      var commits       = exec(cmd).output.split('\n');
      var numOfCommits  = commits.length - 1; // minus one because there is a newline char at the end so last element is not a commit
    */

    // get the shortstat of diffs from that commit to HEAD
    if (numOfCommits > 0) {
      var diffCmd = 'git diff HEAD~' + numOfCommits + ' --shortstat';
      var diffStat  = exec(cmd).output;
      diffStats.push(diffStat);
    }
  } else {
    // get a list of things in this dir
    // and call this function for each dir (recursion, woo!)
    var files = fs.readdirSync(dir);
    files.forEach(function(file) {
      if (fs.lstatSync(process.cwd() + '/' + file).isDirectory()) {
        workweek(file);
      }
    });
  }
}

/* MAIN FUNC */

// this is the argument git gets
// TODO pass this in as an argument
var dir          = process.argv[2];
var gitTimeFrame = process.argv[3] || '1 week ago';
workweek(dir, gitTimeFrame);

console.log(diffStats);
