require 'sinatra/base'

module CarPooling
  class API < Sinatra::Base
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

    get '/cars' do
      render_json(200, Car.all.to_json)
    end

    put '/cars' do
      return status 400 if !@request.content_type == 'application/json'
      @request.body.rewind
      @request_payload = JSON.parse(request.body.read) rescue nil

      return status 400 if !@request_payload
      return status 400 unless validate_cars_for_bulk(@request_payload)

      Journey.destroy_all
      Car.reset_cars(cars:@request_payload)
      status 200
    end

    post '/journey' do
      return status 400 if !@request.content_type == 'application/json'
      @request.body.rewind
      @request_payload = JSON.parse(request.body.read) rescue nil

      return status 400 if !@request_payload

      Journey.create_journey(
        waiting_group_id:@request_payload['id'],
        seats:@request_payload['people']
      )
      status 200
      # render_json(200, { car_id: result }.to_json)
    end

    post '/dropoff' do
      return status 400 if !@request.content_type == 'application/x-www-form-urlencoded'
      waiting_group_id = params[:ID].to_i rescue nil
      return status 400 if waiting_group_id.nil?

      result = Journey.finish_journey(waiting_group_id: waiting_group_id)
      return status 404 if result != 'not found'
      status 200
    end

    post '/locate' do
      return status 400 if !@request.content_type == 'application/x-www-form-urlencoded'
      waiting_group_id = params[:ID].to_i rescue nil
      return status 400 if  waiting_group_id.nil?

      journey = Journey.locate_journey(waiting_group_id)

      return status 204 if journey == 'waiting'
      return 404 if journey.nil?

      result = {
        id: journey[:car_id],
        seats: journey[:seats]
      }
      render_json(200, result.to_json)
    end

    get '/journeys' do
      render_json(200, Journey.all.to_json)
    end

    private

    def validate_cars_for_bulk(cars)
      invalid_input = cars.any? do |car|
        car[:id].class != Integer || car[:seats].class != Integer
      end
      return invalid_input if invalid_input
      true
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
