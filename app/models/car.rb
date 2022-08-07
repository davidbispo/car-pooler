require 'concurrent'

class Car
  @@cars = ::Concurrent::Array.new

  def self.create(id:, seats:)
    entity = { id:id, seats:seats }
    @@cars << entity
    entity
  end

  def self.all
    @@cars
  end

  def self.reset_cars(cars:nil)
    destroy_all
    insert_all(cars) if cars
  end

  def self.insert_all(cars)
    symbolyzed_cars = cars.map { |car| car.transform_keys(&:to_sym) }
    @@cars += symbolyzed_cars
  end

  def self.count
    @@cars.length
  end

  def self.destroy_all
    @@cars = ::Concurrent::Array.new
  end

  def self.exact_find_by_seats(seats:)
    @@cars.find { |car| car[:seats] == seats }
  end

  def self.find_by_seats(seats:)
    #TODO: This method calls for optimization. We should have cars sorted by seats(i..e.: indexed somehow, just like
    # we dould do with a database. Searches in a real DB could be much better and include conditions like finding
    # the car with the smallest Car.last_idle_at value in order to reduce driver idle time.)
    exact_find = exact_find_by_seats(seats:seats)
    return exact_find if exact_find
    @@cars.find { |car| car[:seats] > seats }
  end

  def self.find(id)
    @@cars.find { |car| car[:id] == id }
  end
end