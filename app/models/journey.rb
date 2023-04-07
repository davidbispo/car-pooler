class Journey
  @@journeys = Concurrent::Hash.new
  attr_accessor :waiting_group_id, :car, :people

  def initialize(waiting_group_id:, car:, people:)
    @waiting_group_id = waiting_group_id
    @car = car
    @people = people
  end

  class << self
    def all
      @@journeys
    end

    def create(waiting_group_id:, car:, people:)
      entity = new(waiting_group_id: waiting_group_id, car: car, people: people)
      @@journeys[waiting_group_id] = entity
      entity
    end

    def delete(waiting_group_id)
      @@journeys.delete(waiting_group_id)
    end

    def find_by_waiting_group_id(waiting_group_id)
      @@journeys[waiting_group_id]
    end

    def destroy_all
      @@journeys = {}
    end
  end
end