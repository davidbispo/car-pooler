class CarPoolingAssigner
  class << self
    def assign(waiting_group_id:, people:, car:)
      car.seats -= people
      Car.append_to_car_index_by_seats(car:car)
      CarPoolingQueue.notify_car_found(waiting_group_id: waiting_group_id, car: car)
      CarPoolingQueue.remove_from_queue(waiting_group_id:waiting_group_id)
    end
  end
end