require 'concurrent'

class Car
  @@cars = ::Concurrent::Array.new
  @@car_queues = ::Concurrent::Hash.new
  attr_accessor :id, :seats

  def initialize(id:, seats:)
    @id = id
    @seats = seats
  end

  class << self
    def create(id:, seats:)
      entity = new(id:id, seats:seats)
      @@cars << entity

      get_car_queue_by_seats(seats).append(entity)
      entity
    end

    def all
      @@cars
    end

    def reset_cars(cars:nil)
      destroy_all
      insert_all(cars) if cars
    end

    def insert_all(cars)
      cars.each do |car|
        create(id: car['id'], seats: car['seats'])
      end
    end

    def count
      @@cars.length
    end

    def destroy_all
      CarQueue.clear
      @@cars = ::Concurrent::Array.new
    end

    def append_to_car_index_by_seats(car:)
      get_car_queue_by_seats(car.seats).append(car)
    end

    def get_car_queue_by_seats(seats)
      CarQueue.get_by_seats(seats)
    end
  end
end