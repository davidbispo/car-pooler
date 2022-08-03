require_relative '../../../app/api'

RSpec.describe 'POST /journeys: create journey' do
  def app
    AccountManager::API
  end

  describe 'locate' do
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

      it 'expects a 200 status' do
        expect(response).to have_http_status(:ok)
      end

      it 'expects a payload with the car' do
        expect(response).to match({ id:car.id, seats:car.seats })
      end
    end

    context 'payload is wrong' do
      it 'expects a 400' do
        expect(response). to have_http_status(:not_found)
      end
    end

    context 'and group is waiting to be assigned' do
      it 'expects a 204' do
        expect(response). to have_http_status(:no_content)
      end
    end
  end
end
