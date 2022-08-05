module ApplicationHelper
  def reset_application
    Journey.destroy_all
    Car.destroy_all
    CarPoolingQueue.clear_queue
  end
end