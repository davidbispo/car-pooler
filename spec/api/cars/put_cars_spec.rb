require_relative '../../spec_helper'
require_relative "../../../app/api"
require_relative '../../../app/models/journey'
require_relative '../../../app/models/car'
require_relative '../../../app/models/car_queue'
require_relative '../../../app/lib/car_pooling_queue'

RSpec.describe 'POST /cars: create cars' do
  def app
    CarPooling::API
  end

  context 'params are valid' do
    let(:payload) { [{ :id => 1, :seats => 4 }, { :id => 2, :seats => 6 }] }

    context 'when no cars exist' do
      before do
        Journey.destroy_all
        Car.destroy_all
        put("/cars", payload.to_json, { 'CONTENT_TYPE' => 'application/json' })
      end

      it 'returns a 200 with empty_body' do
        expect(last_response.status).to eq(200)
        expect(last_response.body).to be_empty
      end

      it 'expects cars to be on the DB' do
        expect(Car.all).to match(payload)
      end

      it '2 cars to have been created' do
        expect(Car.count).to eq(2)
      end
    end

    context 'when cars exist' do
      before do
        Car.destroy_all
        @existing_car = Car.create(id: 3, seats: 5)
        put("/cars", payload.to_json, { 'CONTENT_TYPE' => 'application/json' })
      end

      it 'returns a 200' do
        expect(last_response.status).to eq(200)
        expect(last_response.body).to be_empty
      end

      it 'expects cars to be on the DB' do
        expect(Car.all).to match(payload)
      end

      it '2 cars to have been created' do
        expect(Car.count).to eq(2)
      end
    end
  end

  context 'params are not valid' do
    let(:payload) { [{ :name => 'joseph', :last_name => 'charles' }, { :name => 'luiz', :last_name => 'silva' }].to_json }

    context 'body has unnaccepted keys' do
      it 'returns a 403' do
        put '/cars', body: payload, as: :json
        expect(last_response.status).to eq(400)
        expect(last_response.body).to be_empty
      end
    end

    context 'body has unnacceptable values' do
      let(:payload) { [{ :id => 'popo', :seats => 'charles' }, { :id => '2', :seats => 'silva' }].to_json }
      it 'returns a 403' do
        put '/cars', body: payload, as: :json
        expect(last_response.status).to eq(400)
        expect(last_response.body).to be_empty
      end
    end

    context 'no json header' do
      it 'returns a 200 with empty_body' do
        put '/cars', body: payload
        expect(last_response.status).to eq(400)
        expect(last_response.body).to be_empty
      end
    end
  end
end
