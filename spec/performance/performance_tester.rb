require 'byebug'
require "uri"
require "json"
require "net/http"
require 'byebug'

PORT = 9091

def add_cars(number_of_cars)
  cars = []

  (1..number_of_cars).each do |id|
    cars << { "id": id, "seats": rand(1..6) }
    id += 1
  end

  url = URI("http://localhost:#{PORT}/cars")

  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Put.new(url)
  request["Content-Type"] = "application/json"
  request.body = JSON.dump(cars)

  response = http.request(request)
  puts "Cars successfully added" if response.code == "200"
end

add_cars(1_000)

def create_journeys(njourneys)
  journeys = []
  (1..njourneys).each do |id|
    journeys << {
      "id": id,
      "people": rand(1..6)
    }
    id += 1
  end
  journeys
end

def call_journeys(njourneys)
  journeys = create_journeys(njourneys)

  start_time = Time.now
  iter = 1
  puts "Running..."
  journeys.each do |journey|
    url = URI("http://localhost:#{PORT}/journey")

    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request.body = JSON.dump(journey)

    response = http.request(request)
    iter += 1
  end

  end_time = Time.now
  total_time = end_time - start_time
  puts "Took #{total_time} seconds"
  puts "Processed #{ iter } trips"
  puts "Processed #{ iter / (total_time / 60) } trips per minute"
end

call_journeys(200)

def call_journeys_concurrent(njourneys)
  start = Time.now
  threads = njourneys.times.map do
    Thread.new do
      url = URI("http://localhost:#{PORT}/journey")

      http = Net::HTTP.new(url.host, url.port);
      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/json"
      request.body = JSON.dump({
       "id": rand(1..10000),
       "people": rand(1..6)
      })
      response = http.request(request)
      puts response.code if response.code == '200'
      puts 'failed' if response.code != '200'
    end
  end
  threads.map(&:join)
  stop = Time.now
  total_time = stop - start
  puts "Did #{njourneys} in #{total_time} seconds"
  puts "Concurrrently we can get #{ njourneys / (total_time / 60) } trips per minute"
end

call_journeys_concurrent(200)