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

  def self.find_by_seats(seats:)
    @@cars.find { |car| car[:seats] >= seats }
  end

  def self.find(id)
    @@cars.find { |car| car[:id] == id }
  end
end