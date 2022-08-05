require 'sinatra/base'
require_relative './lib/application_helper'

module CarPooling
  class API < Sinatra::Base

    include ApplicationHelper

    set :server, 'puma'
    require 'json'
    require "sinatra/config_file"

    register Sinatra::ConfigFile

    configure :development, :test do
      require "sinatra/reloader"
      require 'byebug'
      register Sinatra::Reloader
    end

    before do
      if @request.content_type == 'application/json'
        @request.body.rewind
        @request_payload = JSON.parse(request.body.read) rescue nil
      end
    end

    get '/status' do
      status 200
      return { status: "ok" }.to_json
    end

    get '/cars' do return status 400 end
    post '/cars' do return status 400 end
    patch '/cars' do return status 400 end
    delete '/cars' do return status 400 end
    put '/cars' do
      return status 400 if @request.content_type != 'application/json'
      @request.body.rewind
      @request_payload = JSON.parse(request.body.read) rescue nil

      return status 400 if !@request_payload
      return status 400 unless validate_cars_for_bulk(@request_payload)

      reset_application
      Car.insert_all(@request_payload)
      status 200
    end

    get '/journey' do return status 400 end
    put '/journey' do return status 400 end
    patch '/journey' do return status 400 end
    delete '/journey' do return status 400 end
    post '/journey' do
      return status 400 if @request.content_type != 'application/json'
      @request.body.rewind
      @request_payload = JSON.parse(request.body.read) rescue nil

      return status 400 if !@request_payload

      valid_journey = validate_journey(@request_payload)
      return status 400 unless valid_journey

      Journey.find_journey(
        waiting_group_id:@request_payload['id'],
        seats:@request_payload['people']
      )
      status 200
    end

    get '/dropoff' do return status 400 end
    put '/dropoff' do return status 400 end
    patch '/dropoff' do return status 400 end
    delete '/dropoff' do return status 400 end
    post '/dropoff' do
      return status 400 if @request.content_type != 'application/x-www-form-urlencoded'
      waiting_group_id_valid = validate_id(params[:ID]) rescue nil
      return status 400 if !waiting_group_id_valid

      waiting_group_id = params[:ID].to_i rescue nil
      return status 400 if waiting_group_id.nil?

      result = Journey.finish_journey(waiting_group_id: waiting_group_id)
      return status 404 if result == 'not found'
      status 200
    end

    get '/locate' do return status 400 end
    put '/locate' do return status 400 end
    patch '/locate' do return status 400 end
    delete '/locate' do return status 400 end
    post '/locate' do
      return status 400 if @request.content_type != 'application/x-www-form-urlencoded'
      waiting_group_id_valid = validate_id(params[:ID]) rescue nil
      return status 400 if !waiting_group_id_valid

      waiting_group_id = params[:ID].to_i rescue nil
      return status 400 if waiting_group_id.nil? || !waiting_group_id_valid

      journey = Journey.locate_journey(waiting_group_id)

      return status 204 if journey == 'waiting'
      return 404 if journey.nil?

      result = {
        id: journey[:car_id],
        seats: journey[:seats]
      }
      render_json(200, result.to_json)
    end

    private

    def validate_cars_for_bulk(cars)
      invalid_input = cars.any? do |car|
        car[:id].class != Integer || car[:seats].class != Integer
      end
      return invalid_input if invalid_input
      true
    end

    def validate_journey(journey)
      journey['id'].is_a?(Numeric) && journey['people'].is_a?(Numeric)
    end

    def validate_id(id)
      id.match?(/\d*/)
    end


    def is_integer(value)
      value.to_s.matches?(/\A[-+]?[0-9]+\z/)
    end

    def render_not_found
      return "Not Found"
      status 404
    end

    def render_json(status, json)
      content_type 'application/json'
      status(status)
      return json
    end
  end
end
