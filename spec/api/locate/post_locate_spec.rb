require_relative '../../spec_helper'
require_relative '../../../app/api'
require_relative '../../../app/models/journey'
require_relative '../../../app/lib/car_pooling_queue'
require_relative '../../../app/services/locate_journey_service'

RSpec.describe 'POST /locate: Locate journey' do
  def app
    CarPooling::API
  end

  describe 'locate' do
    let(:new_cars) { [{ "id": 1, "seats": 4 }, { "id": 2, "seats": 6 }] }
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

      context 'and trip is waiting' do
        before do
          allow(CarPoolingQueue).to receive(:get_queue).and_return({1=>2})
          post('/locate', {ID: 1}, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
        end

        it 'expects a 404' do
          expect(last_response.status).to eq(204)
        end
      end

      context 'and trip exists' do
        before do
          Journey.destroy_all
          Car.reset_cars(cars: new_cars)
          Journey.create(car_id: 1, waiting_group_id: 1, seats: 2)
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
end
