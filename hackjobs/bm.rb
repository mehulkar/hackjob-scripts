#!/usr/bin/env ruby

# This script is used to check endpoints of your API (or any other website)
# It fetches a URL `n` number of times and reports the average time

require 'uri'
require 'net/http'
require 'benchmark'

# This is the url you want to benchmark
MY_URL = ARGV[0]

# Pass in from command line or default to 5
NUM_OF_TIMES = ARGV[1] ? ARGV[1].to_i : 5

if !MY_URL
  puts "USAGE: Specify a url as the first argument"
  exit
end

def fetch(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)
end

# fetch the url
puts "Fetching '#{MY_URL}' #{NUM_OF_TIMES} times..."
time = Benchmark.realtime { NUM_OF_TIMES.times { fetch(MY_URL) } }

# Display the results
puts "Total: #{time}s.\nAverage: #{time/NUM_OF_TIMES}s"
