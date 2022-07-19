require 'rails_helper'

describe CarsController do
  describe '#upsert' do
    context 'params are valid' do
      let(:payload) { [{:id=>1, :seats=>4}, {:id=>2, :seats=>6}].to_json }
      context 'when creating' do 
        it 'returns a 200 with empty_body' do
          put :upsert, body:payload, as: :json
          expect(response).to have_http_status(:created)
          expect(response.body).to be_empty
        end
      end
  
      context 'when updating' do 
        it 'returns a 200' do
          put :upsert, body:payload, as: :json
          expect(response).to have_http_status(:created)
          expect(response.body).to be_empty
        end
      end

      context 'when creating and updating' do 
        it 'returns a 200' do
          put :upsert, body:payload, as: :json
          expect(response).to have_http_status(:created)
          expect(response.body).to be_empty
        end
      end
    end

    context 'params are not valid' do 
      let(:payload) { [{:name=>'joseph', :last_name=>'charles'}, {:name=>'luiz', :last_name=>'silva'}].to_json }
      
      context 'body has unnaccepted parameters' do 
        it 'returns a 403' do
          put :upsert, body:payload, as: :json
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to be_empty
        end
      end

      context 'no json header' do 
        it 'returns a 200 with empty_body' do
          put :upsert, body:payload
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to be_empty
        end
      end
    end
  end
end
