require_relative '../../../app/api'

RSpec.describe 'POST /dropoff: create journey' do
  def app
    AccountManager::API
  end

  describe 'dropoff' do
    before do
      put :finish, params: { ID:1 }
    end

    context 'and trip DOES NOT EXIST' do
      it 'expects a 404' do
        expect(response). to have_http_status(:not_found)
      end
    end

    context 'and trip exists' do
      let(:car) { Car.create(seats:4) }

      before do
        @new_journey = Journey.create(car_id: car.id, group_id: group_id)
        car.active_journey = new_journey.id
        post :finish, params: { ID: @new_journey.id }
      end

      after do
        Journey.all.destroy_all
        Car.all.destroy_all
      end

      it 'works' do
        expect(response).to have_http_status(:ok)
      end

      it 'expects car to be available again' do
        expect(car.active_journey).to eq(0)
      end
    end
  end
end
