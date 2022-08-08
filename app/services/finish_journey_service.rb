class FinishJourneyService
  def self.perform(waiting_group_id:)
    mutex = Mutex.new
    mutex.lock
    journey = Journey.find_by_waiting_group_id(waiting_group_id)
    return 'not found' unless journey
    car = Car.find(journey[:car_id])
    car[:seats] += journey[:seats]
    Journey.delete(waiting_group_id)
    mutex.unlock
  end
end