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
      parse_json unless @request.content_type != 'application/json'
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
      return status 400 if invalid_json_header
      cars = @json_payload

      return status 400 if !cars
      return status 400 unless validate_cars_for_bulk(cars)

      reset_application
      Car.insert_all(cars)
      status 200
    end

    get '/journey' do return status 400 end
    put '/journey' do return status 400 end
    patch '/journey' do return status 400 end
    delete '/journey' do return status 400 end
    post '/journey' do
      return status 400 if invalid_json_header
      journey = @json_payload
      return status 400 if !journey

      valid_journey = validate_journey(journey)
      return status 400 unless valid_journey

      Journey.find_journey(
        waiting_group_id:journey['id'],
        seats:journey['people']
      )
      status 200
    end

    get '/dropoff' do return status 400 end
    put '/dropoff' do return status 400 end
    patch '/dropoff' do return status 400 end
    delete '/dropoff' do return status 400 end
    post '/dropoff' do
      return status 400 if invalid_www_form_header
      return status 400 if !waiting_group_id_valid?

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
      return status 400 if invalid_www_form_header
      return status 400 if !waiting_group_id_valid?

      waiting_group_id = params[:ID].to_i rescue nil
      return status 400 if waiting_group_id.nil? || !waiting_group_id_valid?

      journey = Journey.locate_journey(waiting_group_id)

      return status 204 if journey == 'waiting'
      return 404 if journey.nil?

      result = {
        id: journey[:car_id],
        seats: journey[:seats]
      }
      render_json(200, result.to_json)
    end
  end
end
