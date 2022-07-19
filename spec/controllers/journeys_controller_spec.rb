require 'rails_helper'

describe JourneysController do
  describe 'upsert' do 
    it 'works' do 
      get :upsert
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'finish' do 
    it 'works' do 
      get :finish
      expect(response).to have_http_status(:ok)
    end
  end

  it 'locate' do 
    get :finish
    expect(response).to have_http_status(:ok)
  end
end
