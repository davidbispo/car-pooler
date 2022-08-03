class Car
  @@cars = ::Concurrent::Array.new

  def self.create(id:, seats:)
    @@cars << { id:id, seats:seats }
  end

  def self.all
    @@cars
  end

  def self.reset_cars(cars:)
    persist = cars.map{ |car| car.transform_keys(&:to_sym) }
    destroy_all
    insert_all(persist)
  end

  def self.insert_all(cars)
    @@cars += cars
  end

  def self.count
    @@cars.length
  end

  def self.destroy_all
    @@cars = []
  end

  def self.find_by_seats(seats:)
    @@cars.find { |car| car[:seats] >= seats }
  end

  def self.find(id)
    @@cars.find { |car| car[:id] == id }
  end
end