class CarsController < ApplicationController
  def upsert
    permitted = permitted_params
    return head 201
  end

  def permitted_params
    params.require(:_json).map do |param| 
      param.require(:id)
      param.require(:seats)
    end
  end
end