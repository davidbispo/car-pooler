require_relative '../../spec_helper'
require_relative '../../../app/api'
require_relative '../../../app/models/car'
require_relative '../../../app/models/journey'
require_relative '../../../app/lib/application_helper'
require_relative '../../../app/services/finish_journey_service'
require_relative '../../../app/models/car_queues'
require_relative '../../../app/models/car_queue_linked_list'
require_relative '../../../app/models/car_queue_linked_list_node'
require_relative '../../../app/services/create_journey_service'
require_relative '../../../app/lib/car_pooling_assigner'

RSpec.describe 'POST /dropoff: finish journey' do
  def app
    CarPooling::API
  end

  describe 'dropoff' do
    let(:new_cars) { [{ 'id' => 1, 'seats' => 4 }, { 'id' => 2, 'seats' => 6 }] }
    let(:car1) { get_car_by_id(1) }
    let(:car2) { get_car_by_id(2) }
    context 'and payload is correct' do
      context 'and trip DOES NOT EXIST' do
        it 'expects a 404' do
          Car.reset_cars(cars: new_cars)
          post('/dropoff', { ID: 1 }, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
          expect(last_response.status).to eq(404)
        end
      end

      context 'and trip exists - assigned to Car with id = 2' do
        let(:trip) { { id: 1, people: 4 } }
        before do
          Journey.destroy_all
          Car.reset_cars(cars: new_cars)
          CreateJourneyService.perform(waiting_group_id: trip[:id], people: trip[:people])
          post('/dropoff', { ID: 1 }, { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' })
        end

        it 'expects a 200' do
          expect(last_response.status).to eq(200)
        end

        it 'expects car seats to be available again' do
          expect(get_car_by_id(2).seats).to eq(6)
        end

        it 'expects journey to be removed from journeys' do
          expect(Journey.find_by_waiting_group_id(1)).to be_nil
        end

        it 'expects car 2 to be back to the 6 seats car queue' do
          expect(CarQueues.get_queue_by_seats(6).head.value.id).to eq(2)
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

  def get_car_by_id(id)
    Car.all.find { |el| el.id == id }
  end
end