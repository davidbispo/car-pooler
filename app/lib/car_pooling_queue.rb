require_relative '../models/car'

class CarPoolingQueue
  QUEUE_STATUSES = %w(stopped, started)

  @@queue = Concurrent::Hash.new
  @@queue_status = 'stopped'

  def add_to_queue(waiting_group_id:, seats:)
    @@queue[waiting_group_id] = seats
  end

  def remove_from_queue(waiting_group_id:)
    @@queue.delete(waiting_group_id)
  end

  def clear_queue
    @@queue = Concurrent::Hash.new
  end

  def self.waiting_group_in_queue?(waiting_group_id)
    get_queue.key?(waiting_group_id)
  end

  def self.get_queue
    @@queue
  end

  def get_queue_status
    @@queue_status
  end

  def start(execution_interval: 5)
    set_queue_status(status: 'started')
    timer_task_instance(execution_interval: execution_interval).execute
  end

  def stop
    set_queue_status(status: 'stopped')
    timer_task_instance.shutdown
  end

  private

  def set_queue_status(status:)
    @@queue_status = status
  end

  def timer_task_instance(execution_interval: 0.1)
    @timer_task_instance ||= Concurrent::TimerTask.new(run_now: true, execution_interval: execution_interval) do
      CarPoolingQueue.consume_queue
    end
  end

  def self.notify_car_found(waiting_group_id:, car_id:)
    CarReadyNotification.notify(waiting_group_id:waiting_group_id, car_id:car_id)
  end

  def self.consume_queue
    puts "consuming"
    mutex = Mutex.new
    @@queue.each do |waiting_group_id, people|
      mutex.lock
      car = Car.find_by_seats(seats: people)
      next unless car
      notify_car_found(waiting_group_id: waiting_group_id, car_id: car[:id])
      mutex.unlock
    end
  end
end

CarPoolingQueueProcess = CarPoolingQueue.new
CarPoolingQueueProcess.start(execution_interval: 0.1) unless ENV['RACK_ENV'] == 'test'