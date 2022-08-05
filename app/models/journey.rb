class Journey
  @@journeys = Concurrent::Hash.new

  def self.all
    @@journeys
  end

  def self.create(waiting_group_id:, car_id:, seats:)
    entity = { car_id: car_id, seats:seats }
    @@journeys[waiting_group_id] = entity
    entity
  end

  def self.find_by_waiting_group_id(waiting_group_id)
    @@journeys[waiting_group_id]
  end

  def self.destroy_all
    @@journeys = {}
  end

  def self.find_journey(waiting_group_id:, seats:)
    mutex = Mutex.new
    CarPoolingQueueProcess.add_to_queue(waiting_group_id: waiting_group_id, seats: seats)
    notified = false
    while not notified
      car_id = find_waiting_group_notification(waiting_group_id: waiting_group_id)
      notified = true if car_id
      sleep 0.1 unless car_id
    end

    mutex.lock
    CarPoolingQueueProcess.remove_from_queue(waiting_group_id:waiting_group_id)
    Journey.create(waiting_group_id:waiting_group_id, car_id:car_id, seats:seats)
    car = Car.find(car_id)
    car[:seats] -= seats
    mutex.unlock
    return car_id
  end

  def self.locate_journey(waiting_group_id)
    mutex = Mutex.new
    mutex.lock
    waiting_group_in_queue = CarPoolingQueue.waiting_group_in_queue?(waiting_group_id)
    waiting_group_id = @@journeys[waiting_group_id]
    mutex.unlock

    return 'waiting' if waiting_group_in_queue
    return waiting_group_id if waiting_group_id
  end

  def self.finish_journey(waiting_group_id:)
    mutex = Mutex.new
    mutex.lock
    car = Journey.find_by_waiting_group_id(waiting_group_id)
    return 'not found' unless car
    car = Car.find(car[:car_id])
    car[:seats] += 2
    @@journeys.delete(waiting_group_id)
    mutex.unlock
  end

  def self.find_waiting_group_notification(waiting_group_id:)
    CarReadyNotification.find_waiting_group_notification(waiting_group_id: waiting_group_id)
  end
end