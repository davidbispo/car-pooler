require 'sinatra/base'
require_relative './lib/application_helper'

module CarPooling
  class API < Sinatra::Base
    eval(File.read('./config/config.rb'))

    before { parse_json unless @request.content_type != 'application/json' }

    get '/status' do
      return { status: "ok" }.to_json
    end

    %w(get post patch delete).each do |method|
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
      return status 400 if !journey || !validate_journey(journey)

      CreateJourneyService.perform(
        waiting_group_id:journey['id'],
        seats:journey['people']
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
  end
end
