class CarPoolingAssigner
  class << self
    def assign(waiting_group_id:, people:, car_node:)
      car = car_node.value
      Journey.create(waiting_group_id:waiting_group_id, car: car, people:people)
      car.seats -= people
      Car.append_to_car_index_by_seats(data=nil, car_node: car_node)
    end
  end
end