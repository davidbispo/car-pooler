require_relative '../../spec_helper'
require_relative '../../../app/api'
require_relative '../../../app/models/journey'
require_relative '../../../app/models/car'
require_relative '../../../app/models/car_queues'
require_relative '../../../app/models/car_queue_linked_list_node'
require_relative '../../../app/models/car_queue_linked_list'
require_relative '../../../app/services/locate_journey_service'
require_relative '../../../app/services/create_journey_service'
require_relative '../../../app/lib/car_pooling_assigner'

RSpec.describe 'POST /locate: Locate journey' do
  def app
    CarPooling::API
  end

  describe 'locate' do
    let(:new_cars) { [{ "id" => 1, "seats" => 4 }, { "id" => 2, "seats" => 6 }] }
    context 'and payload is correct' do
      context 'and trip DOES NOT EXIST' do
        before do
          Journey.destroy_all
          post('/locate', {ID: 1}, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
        end

        it 'expects a 404' do
          expect(last_response.status).to eq(404)
        end
      end

      context 'and trip exists' do
        let(:trip) { { id: 1, people: 2 } }
        before do
          reset_application(new_cars)
          CreateJourneyService.perform(waiting_group_id: trip[:id], people: trip[:people])
          post('/locate', {ID: 1}, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
        end

        it 'expects a 200 status' do
          expect(last_response.status).to eq(200)
        end

        it 'expects a payload with the car' do
          expect(JSON.parse(last_response.body)).to match({ "id" => 1, "seats" => 2 })
        end
      end
    end

    context 'payload is wrong' do
      context 'and parameter type is incorrect' do
        let(:payload) { 'Random text here' }
        before do
          post("/locate", payload, { 'CONTENT_TYPE' => 'text/plain' })
        end

        it 'expects a 400' do
          expect(last_response.status).to eq(400)
        end
      end

      context 'and params do not contain ID param' do
        before do
          post("/locate", { "students": 1 }, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
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
