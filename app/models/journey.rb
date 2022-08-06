class Journey
  @@journeys = Concurrent::Hash.new

  def self.all
    @@journeys
  end

  def self.create(waiting_group_id:, car_id:, seats:)
    entity = { car_id: car_id, seats:seats }
    @@journeys[waiting_group_id] = entity
    entity
  end

  def self.delete(waiting_group_id)
    @@journeys.delete(waiting_group_id)
  end

  def self.find_by_waiting_group_id(waiting_group_id)
    @@journeys[waiting_group_id]
  end

  def self.destroy_all
    @@journeys = {}
  end
end