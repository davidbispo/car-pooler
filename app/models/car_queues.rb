class CarQueues
  @@queues = ::Concurrent::Hash.new
  @@seat_list = (1..6).to_a.freeze

  attr_reader :seats

  def self.all_queues
    @@queues
  end

  def self.get_queue_by_seats(seats)
    return @@queues[seats] if @@queues[seats]
    @@queues[seats] = CarQueueLinkedList.new
    @@queues[seats]
  end

  def self.clear
    @@queues = ::Concurrent::Hash.new
  end

  def self.stats
    CarQueues.all_queues.map{ |k,v| { "#{k}" => v.size } }
  end

  def self.find_and_shift_car(seats:)
    (seats..6).each do |nseats|
      queue_linked_list = get_queue_by_seats(nseats)

      next if queue_linked_list.is_empty?
      car_node = queue_linked_list.shift
      if car_node
        return car_node
      end
    end
    return false
  end
end