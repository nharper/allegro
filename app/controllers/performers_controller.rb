require 'base64'

class PerformersController < ApplicationController
  def index
    @performers = Performer.all.includes(:registrations)
  end

  def printcards
    @concert = Concert.current
    @registrations = Registration.where(:concert => @concert).includes(:performer).order('chorus_number')
    if params[:chorus_number]
      numbers = params[:chorus_number].split(',').map do |number|
        parts = number.split('-')
        if parts.length == 2
          Range.new(*parts)
        else
          number
        end
      end

      @registrations = @registrations.where(:chorus_number => numbers)
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
