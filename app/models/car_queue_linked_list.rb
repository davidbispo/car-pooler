class CarQueueLinkedList
  attr_accessor :tail, :head

  def initialize
    @head = nil
    @tail = nil
  end

  def is_empty?
    if @head == nil
      return true
    else
      return false
    end
  end

  def add_last(data)
    node = CarQueueLinkedListNode.new(data)
    if !@head
      @head = node
      @tail = node
      return
    end
    last_node = get_last()
    last_node.next_node = node
    @tail = node
  end

  #shift: remove the first node and return it
  def shift
    if self.is_empty?
      return nil
    else
      curr_head = @head
      new_head = @head.next_node
      @head.next_node = nil
      @head = new_head
    end
    curr_head
  end

  def unshift(data, car_node: nil)
    if self.is_empty?
      @head = CarQueueLinkedListNode.new(data)
    else
      if car_node
        new_head = car_node
      else
        new_head = CarQueueLinkedListNode.new(data)
      end
      new_head.next_node = @head
      @head = new_head
    end
  end

  def get_last
    return if !@head
    node = @head
    until node.next_node.nil?
      node = node.next_node
    end
    return node
  end
end
