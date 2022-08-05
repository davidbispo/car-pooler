require_relative '../../spec_helper'
require_relative '../../../app/api'
require_relative '../../../app/models/journey'
require_relative '../../../app/lib/car_pooling_queue'
require_relative '../../../app/models/car_ready_notification'

RSpec.describe 'POST /journeys: Create journey' do
  def app
    CarPooling::API
  end

  let(:new_cars) { [{ "id": 1, "seats": 4 }, { "id": 2, "seats": 6 }] }

  before(:all) do
    @pooler_queue_instance = CarPoolingQueue.new
    @pooler_queue_instance.start(execution_interval: 1.3)
  end

  after(:all) do
    @pooler_queue_instance.stop
  end

  describe 'create' do
    context 'and payload is ok' do
      let(:payload) { { "id": 1, "people": 4 } }
      context 'and there are available cars' do
        before do
          Car.reset_cars(cars: new_cars)
          post("/journey", payload.to_json, { 'CONTENT_TYPE' => 'application/json' })
        end

        it 'expects a success status' do
          expect(last_response.status).to eq(200)
        end

        it 'expects a that a journey has been successfully registered' do
          expect(Journey.locate_journey(payload[:id])).to eq({ :car_id => 1, :seats => 4 })
        end
      end
    end

    context 'and payload is faulty' do
      context 'and parameters have invalid format' do
        let(:payload) { { "id": 1, "people": "xalalala" } }
        before do
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
end
