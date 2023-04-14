class CreateJourneyService
  def self.perform(waiting_group_id:, people:)
    mutex = Mutex.new
    CarPoolingQueueProcess.add_to_queue(waiting_group_id: waiting_group_id, people: people)
    puts "added to queue for waiting group #{waiting_group_id}"
    wg_notification = false

    while not wg_notification
      wg_notification = find_waiting_group_notification(waiting_group_id: waiting_group_id)
      sleep 0.1
      next
    end

    return 'not_found' if wg_notification['code'] == 0
    puts "Found car for #{waiting_group_id}"

    mutex.lock
    CarStatusNotification.acknowledge_read(waiting_group_id: waiting_group_id)
    journey = Journey.create(waiting_group_id: waiting_group_id, car: wg_notification['car'], people: people)
    puts "Created Journey for #{waiting_group_id}"
    puts "Journeys Size is #{Journey}"
    mutex.unlock
    return 'ok'
  end

  def self.find_waiting_group_notification(waiting_group_id:)
    puts "looking up notification for waiting_group_id #{waiting_group_id}"
    CarStatusNotification.find_waiting_group_notification(waiting_group_id: waiting_group_id)
  end
end
