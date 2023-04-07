require 'sinatra/base'
require_relative './lib/application_helper'
require 'elastic-apm'
require 'net/http'
$stdout.sync = true

module CarPooling
  class Proxy < Sinatra::Base
    BASE_API_URL = 'http://api:9092'.freeze

    @@waiting_trips = ::Concurrent::Hash.new
    @@next_journey_id = 0 if ENV['PERFORMANCE_TESTING'] == 'true'

    eval(File.read('./config/config.rb'))

    before { parse_json unless @request.content_type != 'application/json' }

    get '/status' do
      url = URI("#{BASE_API_URL}/status")

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      response = http.request(request)
      return response.body
    end

    %w(post patch delete).each do |method|
      send("#{method}", '/cars') { return status 400 }
    end

    put '/cars' do
      @request.body.rewind
      incoming_body = request.body.read
      url = URI("#{BASE_API_URL}/cars")

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Put.new(url)
      request["Content-Type"] = "application/json"
      request.body = incoming_body

      response = http.request(request)
      return status response.code.to_i
    end

    %w(get put patch delete).each do |method|
      send("#{method}", '/journey') { return status 400 }
    end

    post '/journey' do
      status = nil
      @request.body.rewind
      incoming_body = request.body.read

      if ENV['PERFORMANCE_TESTING'] == 'true'
        @@next_journey_id += 1
        incoming_body = incoming_body.gsub(/id\":\d/, ('id":' + @@next_journey_id.to_s))
      end

      incoming_id = incoming_body.scan(/id\":\d/).first.split(':')[1]
      @@waiting_trips[incoming_id] = true

      while status != "200"
        url = URI("#{BASE_API_URL}/journey")

        http = Net::HTTP.new(url.host, url.port)
        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request.body = incoming_body
        response = http.request(request)

        status = response.code
        sleep(2) if status != "200"
      end
      @@waiting_trips.delete(incoming_id)
      return status response.code.to_i
    end

    %w(get put patch delete).each do |method|
      send("#{method}", '/dropoff') { return status 400 }
    end

    post '/dropoff' do
      incoming_id = params['ID']
      url = URI("#{BASE_API_URL}/dropoff")

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request.body = "ID=#{incoming_id}"
      response = http.request(request)
      return status response.code.to_i
    end

    %w(get put patch delete).each do |method|
      send("#{method}", '/locate') { return status 400 }
    end

    post '/locate' do
      incoming_id = params['ID']
      return status 204 if @@waiting_trips[incoming_id]

      url = URI("#{BASE_API_URL}/locate")

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request.body = "ID=#{incoming_id}"
      response = http.request(request)
      return response.body
    end
  end
end
