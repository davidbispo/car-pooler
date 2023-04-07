class LocateJourneyService
  def self.perform(waiting_group_id)
    mutex = Mutex.new
    mutex.lock

    waiting_group_in_queue = CarPoolingQueue.waiting_group_in_queue?(waiting_group_id)
    return 'waiting' if waiting_group_in_queue

    journey = Journey.find_by_waiting_group_id(waiting_group_id)
    mutex.unlock

    if journey
      return {
        id: journey.car.id,
        seats: journey.people
      }
    end
  end
end