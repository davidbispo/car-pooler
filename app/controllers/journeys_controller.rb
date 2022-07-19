class JourneysController < ApplicationController
  def upsert
    # upsert_permitted
    head :ok
  end

  def finish
    # finish_permitted
    head :ok
  end

  def locate
    # locate_permitted
    head :ok
  end

  def upsert_permitted
    params.require(:id, :people)
  end

  def finish_permitted
    params.require(:ID)
  end

  def locate_permitted
    params.require(:ID)
  end
end
  