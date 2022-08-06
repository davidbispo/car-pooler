module ApplicationHelper
  def reset_application
    Journey.destroy_all
    Car.destroy_all
    CarPoolingQueueProcess.clear_queue
  end

  #validate parameter inputs
  def validate_cars_for_bulk(cars)
    cars.all? do |car|
      car["id"].class == Integer || car["seats"].class == Integer
    end
  end

  def validate_journey(journey)
    journey['id'].is_a?(Numeric) && journey['people'].is_a?(Numeric)
  end

  def validate_id(id)
    id.match?(/\d*/)
  end

  def is_integer(value)
    value.to_s.matches?(/\A[-+]?[0-9]+\z/)
  end

  def waiting_group_id_valid?
    @waiting_group_id_valid||=validate_id(params[:ID]) rescue nil
  end

  #header_validations
  def invalid_json_header
    @request.content_type != 'application/json'
  end

  def invalid_www_form_header
    @request.content_type != 'application/x-www-form-urlencoded'
  end

  #parser
  def parse_json
    @request.body.rewind
    @json_payload = JSON.parse(request.body.read) rescue nil
  end

  #renders
  def render_not_found
    return "Not Found"
    status 404
  end

  def render_json(status, json)
    content_type 'application/json'
    status(status)
    return json
  end

  def get_argument_from_form(arg)
    params[arg].to_i rescue nil
  end
end