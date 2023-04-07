class FinishJourneyService
  def self.perform(waiting_group_id:)
    mutex = Mutex.new
    mutex.lock
    journey = Journey.find_by_waiting_group_id(waiting_group_id)

    return 'not found' unless journey

    car = journey.car
    remove_car_from_old_queue!(car)

    car.seats += journey.people
    Car.unshift_to_car_index_by_seats(car: car)
    Journey.delete(waiting_group_id)
    mutex.unlock
  end

  def self.remove_car_from_old_queue!(car)
    old_queue = CarQueues.get_queue_by_seats(car.seats)
    old_queue.remove_node_from_list(car.current_node)
  end
end