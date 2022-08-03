class Journey
  @@journeys = { }

  def self.all
    @@journeys
  end

  def self.find_car_id(waiting_group_id:)
    @@journeys[waiting_group_id]
  end

  def self.create_journey(waiting_group_id:, seats:)
    CarPoolingQueue.add_to_queue(waiting_group_id: waiting_group_id, seats: seats)
    notified = false
    while not notified
      car_id = find_waiting_group_notification(waiting_group_id: waiting_group_id)
      notified = true if car_id
      sleep 0.5 unless car_id
    end

    @@journeys[waiting_group_id] = { car_id: car_id, seats:seats }
    car = Car.find(car_id)
    car[:seats] -= seats
    return car_id
  end

  def self.locate_journey(waiting_group_id)
    return 'waiting' if CarPoolingQueue.waiting_group_in_queue?(waiting_group_id)
    return @@journeys[waiting_group_id] if @@journeys[waiting_group_id]
  end

  def self.finish_journey(waiting_group_id:)
    car = Journey.find_car_id(waiting_group_id: waiting_group_id)
    return 'not found' unless car
    car = Car.find(car[:car_id])
    car[:seats] += 2
    @@journeys.delete(waiting_group_id)
  end

  def self.destroy_all
    @@journeys = {}
  end

  def self.find_waiting_group_notification(waiting_group_id:)
    CarReadyNotification.find_waiting_group_notification(waiting_group_id: waiting_group_id)
  end
end