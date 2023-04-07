require 'sinatra/base'
require_relative './lib/application_helper'

module CarPooling
  class API < Sinatra::Base
    eval(File.read('./config/config.rb'))

    before { parse_json unless @request.content_type != 'application/json' }

    get '/status' do
      return { status: "ok" }.to_json
    end

    %w(post patch delete).each do |method|
      send("#{method}", '/cars') { return status 400 }
    end
    put '/cars' do
      return status 400 if invalid_json_header

      cars = @json_payload
      return status 400 if !cars || !validate_cars_for_bulk(cars)

      reset_application
      Car.insert_all(cars)
      status 200
    end

    %w(get put patch delete).each do |method|
      send("#{method}", '/journey') { return status 400 }
    end
    post '/journey' do
      return status 400 if invalid_json_header
      journey = @json_payload
      return status 400 if !journey || !validate_journey(journey) || Journey.find_by_waiting_group_id(journey['id'])

      CreateJourneyService.perform(
        waiting_group_id:journey['id'],
        people:journey['people']
      )
      status 200
    end

    %w(get put patch delete).each do |method|
      send("#{method}", '/dropoff') { return status 400 }
    end
    post '/dropoff' do
      return status 400 if invalid_www_form_header || !waiting_group_id_valid?

      waiting_group_id = get_argument_from_form(:ID)
      return status 400 if waiting_group_id.nil?

      result = FinishJourneyService.perform(waiting_group_id: waiting_group_id)
      return status 404 if result == 'not found'
      status 200
    end

    %w(get put patch delete).each do |method|
      send("#{method}", '/locate') { return status 400 }
    end
    post '/locate' do
      return status 400 if invalid_www_form_header || !waiting_group_id_valid?

      waiting_group_id = get_argument_from_form(:ID)
      return status 400 if waiting_group_id.nil? || !waiting_group_id_valid?

      journey = LocateJourneyService.perform(waiting_group_id)

      return status 204 if journey == 'waiting'
      return 404 if journey.nil?

      render_json(200, journey.to_json)
    end

    get '/cars' do
      return 404 unless Sinatra::Base.development?
      render_json(200, Car.all.map{|el| {id:el.id, seats:el.seats} }.to_json)
    end

    get '/journeys' do
      return 404 unless Sinatra::Base.development?
      response = Journey.all.each.map do |k,v|
        {
          waiting_group_id: v.waiting_group_id,
          people: v.people,
          car_id: v.car.id,
        }
      end

      render_json(200, response.to_json)
    end
  end
end
