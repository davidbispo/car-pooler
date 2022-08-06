class FinishJourneyService
  def self.perform(waiting_group_id:)
    mutex = Mutex.new
    mutex.lock
    car = Journey.find_by_waiting_group_id(waiting_group_id)
    return 'not found' unless car
    car = Car.find(car[:car_id])
    car[:seats] += 2
    Journey.delete(waiting_group_id)
    mutex.unlock
  end
end