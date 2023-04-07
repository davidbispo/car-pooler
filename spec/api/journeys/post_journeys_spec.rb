require_relative '../../spec_helper'
require_relative '../../../app/api'
require_relative '../../../app/models/journey'
require_relative '../../../app/models/car'
require_relative '../../../app/models/car_queues'
require_relative '../../../app/services/create_journey_service'
require_relative '../../../app/services/locate_journey_service'
require_relative '../../../app/models/car_queue_linked_list'
require_relative '../../../app/models/car_queue_linked_list_node'
require_relative '../../../app/lib/car_pooling_assigner'

RSpec.describe 'POST /journeys: Create journey' do
  def app
    CarPooling::API
  end

  let(:new_cars) { [{ 'id' => 1, 'seats' => 4 }, { 'id' => 2, 'seats' => 6 }] }

  describe 'create' do
    context 'and payload is correct' do
      context 'and there are available cars' do
        let(:payload) { { id: 1, people: 4 } }

        before do
          reset_application(new_cars)
          post("/journey", payload.to_json, { 'CONTENT_TYPE' => 'application/json' })
        end

        it 'expects a success status' do
          expect(last_response.status).to eq(200)
        end

        it 'expects a that a journey has been successfully registered' do
          expect(LocateJourneyService.perform(payload[:id])).to eq({ :id => 1, :seats => 4 })
        end
      end

      context 'and there are available cars and multiple trips waiting' do
        let(:payload1) { { "id": 1, "people": 6 } }
        let(:payload2) { { "id": 2, "people": 2 } }
        let(:payload3) { { "id": 3, "people": 2 } }

        before do
          reset_application(new_cars)
        end

        it 'expects the first trip to be assigned to the first car in the queue -> 6 seats' do
          post("/journey", payload1.to_json, { 'CONTENT_TYPE' => 'application/json' })
          expect(last_response.status).to eq(200)
          expect(LocateJourneyService.perform(payload1[:id])).to eq({ :id => 2, :seats => 6 })
        end

        it 'expects a second trip to be asigned to the most fit car -> 2 seats' do
          post("/journey", payload2.to_json, { 'CONTENT_TYPE' => 'application/json' })
          expect(last_response.status).to eq(200)
          expect(LocateJourneyService.perform(payload2[:id])).to eq({ :id => 1, :seats => 2 })
        end

        it 'expects a third trip to be asigned to the most fit car -> 2 seats' do
          post("/journey", payload3.to_json, { 'CONTENT_TYPE' => 'application/json' })
          expect(last_response.status).to eq(200)
          expect(LocateJourneyService.perform(payload3[:id])).to eq({ :id => 1, :seats => 2 })
        end
      end
    end

    context 'and payload is faulty' do
      context 'and parameters have invalid format' do
        let(:payload) { { "id": 1, "people": "xalalala" } }
        before do
          reset_application(new_cars)
          post("/journey", payload.to_json, { 'CONTENT_TYPE' => 'application/json' })
        end

        it 'expects a 400' do
          expect(last_response.status).to eq(400)
        end
      end

      context 'and parameter is invalid json - cannot be unmarshalled' do
        let(:payload) { 'Random text here' }
        before do
          post("/journey", payload.to_json, { 'CONTENT_TYPE' => 'application/json' })
        end

        it 'expects a 400' do
          expect(last_response.status).to eq(400)
        end
      end

      context 'and header type is not application/json' do
        let(:payload) { { "id": 1, "people": "xalalala" } }
        before do
          post("/journey", payload.to_json, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
        end

        it 'expects a 400' do
          expect(last_response.status).to eq(400)
        end
      end
    end
  end

  def reset_application(new_cars)
    Journey.destroy_all
    Car.reset_cars(cars: new_cars)
  end
end
