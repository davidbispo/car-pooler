class CarReadyNotification
  @@notifications = Concurrent::Hash.new

  def self.get_all_notifications
    @@notifications
  end

  def self.notify(waiting_group_id:, car:)
    @@notifications[waiting_group_id] = car
  end

  def self.acknowledge_read(waiting_group_id:)
    @@notifications.delete(waiting_group_id)
  end

  def self.find_waiting_group_notification(waiting_group_id:)
    @@notifications[waiting_group_id]
  end
end