# require_relative '../models/car'
#
# class CarPoolingQueue
#   QUEUE_STATUSES = %w(stopped, started)
#
#   @@queue = Concurrent::Hash.new
#   @@skipped = Concurrent::Hash.new
#
#   @@queue_status = 'stopped'
#
#   def add_to_queue(waiting_group_id:, people:)
#     @@queue[waiting_group_id] = people
#   end
#
#   def self.remove_from_queue(waiting_group_id:)
#     @@queue.delete(waiting_group_id)
#   end
#
#   def clear_queue
#     @@queue = Concurrent::Hash.new
#   end
#
#   def self.waiting_group_in_queue?(waiting_group_id)
#     get_queue.key?(waiting_group_id)
#   end
#
#   def self.get_queue
#     @@queue
#   end
#
#   def get_queue_status
#     @@queue_status
#   end
#
#   def start(execution_interval: 5)
#     set_queue_status(status: 'started')
#     timer_task_instance(execution_interval: execution_interval).execute
#   end
#
#   def stop
#     set_queue_status(status: 'stopped')
#     timer_task_instance.shutdown
#   end
#
#   private
#
#   def set_queue_status(status:)
#     @@queue_status = status
#   end
#
#   def timer_task_instance(execution_interval: 10)
#     @timer_task_instance ||= Concurrent::TimerTask.new(run_now: true, execution_interval: execution_interval) do
#       unless (get_scheduled_task && get_scheduled_task.state == 'pending')
#       set_scheduled_task
#       get_scheduled_task.execute
#       end
#     end
#   end
#
#   def get_scheduled_task
#     @scheduled_task
#   end
#
#   def set_scheduled_task
#     @scheduled_task = Concurrent::ScheduledTask.execute(0) { CarPoolingQueue.consume_queue }
#   end
#
#   def self.notify_car_found(waiting_group_id:, car:)
#     CarStatusNotification.notify(waiting_group_id:waiting_group_id, car:car, code: 1)
#   end
#
#   def self.notify_car_not_found(waiting_group_id:)
#     CarStatusNotification.notify(waiting_group_id:waiting_group_id, car:nil, code: 0)
#   end
#
#   def self.retry_skipped
#     mutex = Mutex.new
#     @@skipped.each do |waiting_group_id, payload|
#       payload['retries'] += 1
#       car = CarQueue.get_by_seats(payload['people']).find_and_shift_car
#       if car
#         mutex.lock
#         @@skipped.delete(waiting_group_id)
#         notify_car_found(waiting_group_id: waiting_group_id, car: car)
#         CarPoolingAssigner.assign(waiting_group_id:waiting_group_id, people:payload['people'], car:car)
#         mutex.unlock
#       end
#       if payload['retries'] > 2
#         notify_car_not_found(waiting_group_id:waiting_group_id)
#       end
#     end
#   end
#
#   def self.consume_queue
#     mutex = Mutex.new
#     retry_skipped unless @@skipped.empty?
#     return if @@queue.empty?
#
#     puts 'consuming queue'
#     @@queue.each do |waiting_group_id, people|
#       thread_count = Thread.list.select {|thread| thread.status == "run"}.count
#       puts "#{thread_count} Threads running"
#       mutex.lock
#       puts "Consuming #{waiting_group_id}"
#       car = CarQueue.get_by_seats(people).find_and_shift_car
#       if !car
#         @@skipped[waiting_group_id] = { 'people'=> people, 'retries'=> 0 }
#         @@queue.delete(waiting_group_id)
#         mutex.unlock
#         next
#       end
#       @@queue.delete(waiting_group_id)
#       CarPoolingAssigner.assign(waiting_group_id:waiting_group_id, people:people, car:car)
#       notify_car_found(waiting_group_id: waiting_group_id, car: car)
#       mutex.unlock
#     end
#     puts 'consuming queue DONE'
#   end
# end
#
# CarPoolingQueueProcess = CarPoolingQueue.new
# CarPoolingQueueProcess.start(execution_interval: 0.01) unless ENV['RACK_ENV'] == 'test'