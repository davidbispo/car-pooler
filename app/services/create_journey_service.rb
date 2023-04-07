class CreateJourneyService
  def self.perform(waiting_group_id:, people:)
    mutex = Mutex.new
    mutex.lock
    car_node = CarQueues.find_and_shift_car(seats:people)
    if car_node
      CarPoolingAssigner.assign(waiting_group_id: waiting_group_id, people: people, car_node: car_node)
      mutex.unlock
      return 1
    else
      mutex.unlock
      return 0
    end
  end
end
