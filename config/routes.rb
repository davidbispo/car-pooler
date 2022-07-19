Rails.application.routes.draw do
  get 'status' => 'status#index'
  
  put 'cars/:id' => 'cars#upsert'
  put 'cars/' => 'cars#upsert'

  put 'journey' => 'journeys#upsert'  
  post 'dropoff' => 'journeys#finish'
  post 'locate' => 'journeys#locate'  
end
