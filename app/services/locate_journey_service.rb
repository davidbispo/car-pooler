class LocateJourneyService
  def self.perform(waiting_group_id)
    mutex = Mutex.new
    mutex.lock
    waiting_group_in_queue = CarPoolingQueue.waiting_group_in_queue?(waiting_group_id)
    waiting_group_id = Journey.find_by_waiting_group_id(waiting_group_id)
    mutex.unlock

    return 'waiting' if waiting_group_in_queue

    if waiting_group_id
      return {
        id: waiting_group_id[:car_id],
        seats: waiting_group_id[:seats]
      }
    end
  end
end