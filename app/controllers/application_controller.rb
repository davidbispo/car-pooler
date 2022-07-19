class ApplicationController < ActionController::API

  rescue_from ActionController::ParameterMissing do |exception|
    head 400
  end
end
