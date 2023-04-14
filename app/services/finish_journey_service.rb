class FinishJourneyService
  def self.perform(waiting_group_id:)
    mutex = Mutex.new
    mutex.lock
    journey = Journey.find_by_waiting_group_id(waiting_group_id)

    return 'not found' unless journey

    car = journey.car

    old_queue = CarQueue.get_by_seats(car.seats)
    old_queue.remove_car(car)

    car.seats += journey.people

    new_queue = CarQueue.get_by_seats(car.seats)
    new_queue.append(car)
    car.queue = new_queue

    Journey.delete(waiting_group_id)
    mutex.unlock
  end
end