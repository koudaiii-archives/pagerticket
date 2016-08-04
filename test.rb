#!/usr/bin/env ruby

require 'pp'
require 'httparty'
require 'hashie'
require 'dotenv'

# Class to GET or POST to the PagerDuty REST API
class PagerDuty
  include HTTParty
  format :json
  def initialize(api_token)
    @options = {
      headers: {
        'Authorization' => "Token token=#{api_token}",
        'Content-type' => 'application/json',
        'Accept' => 'application/vnd.pagerduty+json;version=2'
      },
      output: 'json'
    }
  end

  def get(req, opts = {})
    opts = opts.merge(@options)
    self.class.get("https://api.pagerduty.com/#{req}", opts)
  end
end

Dotenv.load
# This is a read-only API key:
webdemo = PagerDuty.new(ENV["PAGER_DUTY_API_KEY"])

# Get incidents:
ins = Hashie::Mash.new((webdemo.get('incidents',
                 query: {
                   limit: 100,
                   since: '2016-07-01',
                   until: '2016-08-03',
                   time_zone: 'Asia/Tokyo',
                 })))
ins.incidents.each do |incident|
  puts "id: #{incident.incident_number}"
  puts "created_at: #{incident.created_at}"
  puts "summary: #{incident.summary}"
  puts "url: #{incident.html_url}"
end
