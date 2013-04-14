#!/usr/bin/env ruby
require 'net/http'

# this job can track the total number of checkins and count of persons that
# checked in in a foursquare venue without using the foursquare api.

# Config
# ------
# the id of the venue you want to track, get it by navigating to the venue’s
# detail page and paste the part of the url after the "/v/"
foursquare_venue_id = ENV['FOURSQUARE_VENUE_ID'] || 'raithby-house/4cc37945306e224b085e976c'

SCHEDULER.every '30s', :first_in => 0 do |job|
  http = Net::HTTP.new("foursquare.com", Net::HTTP.https_default_port())
  http.use_ssl = true
  response = http.request(Net::HTTP::Get.new("/v/#{foursquare_venue_id}"))
  if response.code != "200"
    puts "foursquare communication error (status-code: #{response.code})\n#{response.body}"
  else

    # get the numbers by regexp them out of the html source
    # checkins_total = /Total.+Check-ins.+statsnot6digits">([\d.,]+)/
    #   .match(response.body)[1].delete('.').to_i
    checkins_people = /people.+statsnot6digits">([\d.,]+)/
      .match(response.body)[1].delete('.').to_i
    mayorname = /Mayor.+">.+">([\w \w.]+)/
      .match(response.body)[1]
    mayorimg = /mayorImage.+src="([\w:\/\/.]+)/
      .match(response.body)[1]
    
    mayor = { name: mayorname, body: "", avatar: mayorimg }

    # send_event('foursquare_checkins_total', current: checkins_total)
    send_event('foursquare_checkins_people', current: checkins_people)
    send_event('foursquare_mayor', comments: mayor)
  end
end