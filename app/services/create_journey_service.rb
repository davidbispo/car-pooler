class CreateJourneyService
  def self.perform(waiting_group_id:, people:)
    mutex = Mutex.new
    CarPoolingQueueProcess.add_to_queue(waiting_group_id: waiting_group_id, people: people)
    notified = false
    while not notified
      car = find_waiting_group_notification(waiting_group_id: waiting_group_id)
      notified = true if car
      sleep 4 unless car
    end

    mutex.lock
    CarReadyNotification.acknowledge_read(waiting_group_id:waiting_group_id)
    journey = Journey.create(waiting_group_id:waiting_group_id, car:car, people:people)
    mutex.unlock
    journey
  end

  def self.find_waiting_group_notification(waiting_group_id:)
    CarReadyNotification.find_waiting_group_notification(waiting_group_id: waiting_group_id)
  end
end
