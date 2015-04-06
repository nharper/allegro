class PerformersController < ApplicationController
  def index
    @performers = Performer.all

    respond_to do |format|
      format.json { render :json => @performers }
    end
  end
end
