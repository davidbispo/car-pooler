require 'rails_helper'

describe StatusController do
  it 'works' do 
    get :index
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match({"status"=>"OK"})
  end
end
