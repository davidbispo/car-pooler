require 'concurrent'

class Car
  @@cars = ::Concurrent::Array.new
  @@car_queues = ::Concurrent::Hash.new
  attr_accessor :id, :seats, :current_node

  def initialize(id:, seats:)
    @id = id
    @seats = seats
  end

  class << self
    def create(id:, seats:)
      car = new(id:id, seats:seats)
      @@cars << car

      unshift_to_car_index_by_seats(car:car)
      car
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
      CarQueues.clear
      @@cars = ::Concurrent::Array.new
    end

    def unshift_to_car_index_by_seats(car:nil , car_node:nil)
      seats = car_node ? car_node.value.seats : car.seats
      get_car_queue_by_seats(seats).unshift(car:car, car_node:car_node)
    end

    def get_car_queue_by_seats(seats)
      CarQueues.get_queue_by_seats(seats)
    end
  end
end