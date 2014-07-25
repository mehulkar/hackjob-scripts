#!/usr/bin/env ruby
#
# This is a hackjob script that lets you get
# the average salaries for certain job types from Angelist API
# At the point of writing, the Angelist API doesn't support
# searching by type of job. Getting all the jobs would take
# forever, so I get a random sample of pages, grab all the jobs
# of the type you want, average the min/max range and then average
# all the averages. Oh, I also throw away the ones with nil salaries
# (those are probably equity positions).
# Like I said: hackjob
#
# Usage: ./angelist.rb [ROLE_TYPE] [SAMPLE_SIZE]
# ROLE_TYPE is a string like "Marketing". You can browse angel.co for other types. Default is Marketing
# SAMPLE_SIZE determines number of pages. Each page has 50 jobs. Only a fraction will be of the ROLE_TYPE you specify. Default is 5


require 'httparty'

ROLE_TYPE               = ARGV[0] || "Marketing"
NUM_OF_PAGES_TO_SAMPLE  = ARGV[1] ? ARGV[1].to_i : 5 # don't want to convert nil to a string, that would be bad
URL                     = "https://api.angel.co/1/jobs"

puts "Fetching the average salary for #{ROLE_TYPE} jobs using #{NUM_OF_PAGES_TO_SAMPLE} random pages of results"

class Tag
  attr_reader :tag
  def initialize(tag)
    @tag = tag
  end

  def is_role_type?(type)
    @tag['display_name'] == type
  end
end

ALL_JOBS = []

def get_page(page_num)
  puts "Requesting page #{page_num}"
  response = HTTParty.get("#{URL}?page=#{page_num}")
  ALL_JOBS << response['jobs']
  response
end

# first request to figure out how many responses we have
first_response = get_page(1)
total_jobs     = first_response['total']
per_page       = first_response['per_page']

# how many total pages do we have?
# we'll use this to fetch our sample pages
num_of_pages = total_jobs / per_page

sample_pages = (1..num_of_pages).to_a.sample(NUM_OF_PAGES_TO_SAMPLE - 1)

# get results from each page and push it into ALL_JOBS
sample_pages.each { |page_number| get_page(page_number) }

puts 'Done getting all pages. Flattening results'
ALL_JOBS.flatten!

puts "Ok, going to map over their tags and select the #{ROLE_TYPE} ones"

# organize by role tag
jobs_we_care_about = ALL_JOBS.select do |job|
  # create tag object
  tags = job['tags'].map {|tag| Tag.new(tag) }
  should_return = false
  tags.each do |tag|
    should_return = tag.is_role_type?(ROLE_TYPE)
  end
  # return job from this map if job is a job we care about
  job if should_return
end

# get the salary info
puts "Got the jobs. Going to map over the average salaries for #{jobs_we_care_about.length} #{ROLE_TYPE} jobs"
avg_salaries = jobs_we_care_about.map do |job|
  min = job['salary_min']
  max = job['salary_max']
  if min && max
    (min + max) / 2
  end
end

puts "Removing nil salaries. Don't care about equity positions"
avg_salaries.compact!

grand_average = avg_salaries.inject(:+).to_f / avg_salaries.size

formatted_average = "$" +  grand_average.round(2).to_s

puts "============"
puts "The grand average for  #{ROLE_TYPE} JOBS IS #{formatted_average}"
puts "==========="
