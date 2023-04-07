class CarStatusNotification
  STATUS_CODES = {
    "Found" => 1,
    "Not_found" => 0
  }

  @@notifications = Concurrent::Hash.new

  def self.get_all_notifications
    @@notifications
  end

  def self.notify(waiting_group_id:, car:, code:)
    mutex = Mutex.new
    mutex.lock
    payload = Concurrent::Hash.new(0)
    payload.merge!({ "car" => car, "code" => code })
    @@notifications[waiting_group_id] = payload
  end

  def self.acknowledge_read(waiting_group_id:)
    @@notifications.delete(waiting_group_id)
  end

  def self.find_waiting_group_notification(waiting_group_id:)
    @@notifications[waiting_group_id]
  end
end