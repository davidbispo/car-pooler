class CreateJourneyService
  def self.perform(waiting_group_id:, seats:)
    mutex = Mutex.new
    CarPoolingQueueProcess.add_to_queue(waiting_group_id: waiting_group_id, seats: seats)
    notified = false
    while not notified
      car_id = find_waiting_group_notification(waiting_group_id: waiting_group_id)
      notified = true if car_id
      sleep 0.1 unless car_id
    end

    mutex.lock
    CarReadyNotification.acknowledge_read(waiting_group_id:waiting_group_id)
    Journey.create(waiting_group_id:waiting_group_id, car_id:car_id, seats:seats)
    car = Car.find(car_id)
    car[:seats] -= seats
    mutex.unlock
    return car_id
  end

  def self.find_waiting_group_notification(waiting_group_id:)
    CarReadyNotification.find_waiting_group_notification(waiting_group_id: waiting_group_id)
  end
end
