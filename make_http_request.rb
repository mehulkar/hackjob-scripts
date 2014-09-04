#!/usr/bin/env ruby

require 'net/http'
require 'open-uri'

URL = ARGV[0]
response = open(URL).read
puts response
