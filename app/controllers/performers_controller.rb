require 'base64'

class PerformersController < ApplicationController
  # TODO(nharper): Re-write or remove this - it's currently broken.
  def index
    if params['section']
      @performers = Performer.select('id, name, number, section').where(:section => params['section'].upcase)
    else
      @performers = Performer.select('id, name, number, section')
    end

    respond_to do |format|
      format.json { render :json => @performers }
    end
  end

  def photo
    @performer = Performer.find(params[:id])
    if @performer.photo
      render :text => @performer.photo, :content_type => 'image/png'
    else
      # TODO(nharper): consider changing to clear.gif
      # http://upload.wikimedia.org/wikipedia/en/d/d0/Clear.gif
      #
      # 1x1 transparent png; source: http://garethrees.org/2007/11/14/pngcrush/
      render :text => Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=='), :content_type => 'image/png'
    end
  end

  def newcard
    @card = Card.new(:performer => Performer.find(params[:id]))
  end
end
