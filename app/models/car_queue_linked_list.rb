class CarQueueLinkedList
  attr_accessor :head

  def initialize
    @head = nil
  end

  def remove_node_from_list(current_node)
    if current_node == @head
      return shift
    elsif current_node.next_node == nil
      current_node.previous_node.next_node = nil
      return current_node
    end
    current_node.previous_node.next_node = current_node.next_node
    current_node.next_node = nil
    current_node.previous_node = nil
  end

  def is_empty?
    if @head == nil
      return true
    else
      return false
    end
  end

  def shift
    if self.is_empty?
      return nil
    else
      curr_head = @head
      new_head = curr_head.next_node
      @head = new_head

      curr_head.next_node = nil
      curr_head.previous_node = nil
    end
    curr_head
  end

  def unshift(car: nil, car_node: nil)
    if self.is_empty?
      if car_node
        @head = car_node
        @head.value.current_node = car_node
        return
      end
      car_node = CarQueueLinkedListNode.new(car)
      car.current_node = car_node
      @head = car_node
    else
      if car_node
        new_head = car_node
      else
        new_head = CarQueueLinkedListNode.new(car)
      end
      @head.previous_node = new_head
      new_head.next_node = @head
      new_head.value.current_node = new_head
      @head = new_head
    end
  end

  def size
    if self.is_empty?
      count = 0
    else
      count = 1
      current_node = @head
      while current_node.next_node != nil
        current_node = current_node.next_node
        count += 1
      end
    end
    count
  end
end
