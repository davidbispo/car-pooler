class CarQueues
  @@queues = ::Concurrent::Hash.new
  @@seat_list = ::Concurrent::Array.new

  attr_reader :seats

  def self.all_queues
    @@queues
  end

  def self.get_queue_by_seats(seats)
    return @@queues[seats] if @@queues[seats]
    @@queues[seats] = CarQueueLinkedList.new
  end

  def self.clear
    @@queues = ::Concurrent::Hash.new
  end

  def self.refresh_seat_list
    @@seat_list = @@queues.keys.sort
  end

  def self.find_and_shift_car(seats:)
    seat_numbers_eligible = @@seat_list
    seat_numbers_eligible.each do |nseats|
      next unless nseats >= seats
      queue_linked_list = get_queue_by_seats(nseats)
      car_node = queue_linked_list.shift
      if car_node
        return car_node
      end
    end
    return false
  end
end