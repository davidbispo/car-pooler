require_relative '../../spec_helper'
require_relative '../../../app/api'
require_relative '../../../app/models/car'
require_relative '../../../app/models/journey'
require_relative '../../../app/models/car_ready_notification'
require_relative '../../../app/lib/car_pooling_queue'
require_relative '../../../app/lib/application_helper'
require_relative '../../../app/services/finish_journey_service'

RSpec.describe 'POST /dropoff: finish journey' do
  def app
    CarPooling::API
  end

  describe 'dropoff' do
    let(:new_cars) { [{ "id": 1, "seats": 4 }, { "id": 2, "seats": 6 }] }
    context 'and payload is correct' do
      context 'and trip DOES NOT EXIST' do
        it 'expects a 404' do
          Car.reset_cars(cars: new_cars)
          post('/dropoff', {ID: 1}, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
          expect(last_response.status).to eq(404)
        end
      end

      context 'and trip exists' do
        before do
          Journey.destroy_all
          Car.reset_cars(cars: new_cars)
          Journey.create(car_id: 1, waiting_group_id: 1, seats: 2)
          post('/dropoff', {ID: 1}, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
        end

        it 'expects a 200' do
          expect(last_response.status).to eq(200)
        end

        it 'expects car seats to be available again' do
          expect(Car.find(1)[:seats]).to eq(6)
        end

        it 'expects journey to be removed from journeys' do
          expect(Journey.find_by_waiting_group_id(1)).to be_nil
        end
      end
    end

    context 'and payload is invalid' do
      context 'and parameter type is incorrect' do
        let(:payload) { 'Random text here' }
        before do
          post("/dropoff", payload, { 'CONTENT_TYPE' => 'text/plain' })
        end

        it 'expects a 400' do
          expect(last_response.status).to eq(400)
        end
      end

      context 'and params do not contain ID param' do
        before do
          post("/journey", { "students": 1 }, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
        end

        it 'expects a 400' do
          expect(last_response.status).to eq(400)
        end
      end
    end
  end
end