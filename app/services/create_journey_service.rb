class CreateJourneyService
  @@mutex = Mutex.new

  def self.perform(waiting_group_id:, people:)
    @@mutex.lock
    car_node = CarQueues.find_and_shift_car(seats:people)
    if car_node
      CarPoolingAssigner.assign(waiting_group_id: waiting_group_id, people: people, car_node: car_node)
      @@mutex.unlock
      return true
    else
      @@mutex.unlock
      return false
    end
  end
end
