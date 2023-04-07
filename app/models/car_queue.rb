class CarQueue
  @@queues = ::Concurrent::Hash.new

  attr_reader :seats, :queue

  def initialize(seats:)
    @seats = seats
    @queue = []
    @@queues[seats] = self
    @queue
  end

  def self.all_queues
    @@queues
  end

  def self.get_by_seats(seats)
    all_queues[seats] || new(seats:seats)
  end

  def self.clear
    @@queues = Hash.new
  end

  def shift
    queue.shift
  end

  def append(val)
    queue.append(val)
  end

  def remove_car(car)
    queue.delete_if { |el| el.eql?(car) }
  end

  def find_and_shift_car
    seat_numbers_eligible = @@queues.keys.sort.select
    seat_numbers_eligible.each do |nseats|
      next unless nseats >= seats
      car_found = queue.shift
      return car_found if car_found
      false
    end
  end
end