class PerformersController < ApplicationController
  def index
    @performers = Performer.select('id, name, number, section')

    respond_to do |format|
      format.json { render :json => @performers }
    end
  end

  def photo
    @performer = Performer.find(params[:id])
    render :text => @performer.photo, :content_type => 'image/png'
  end
end
