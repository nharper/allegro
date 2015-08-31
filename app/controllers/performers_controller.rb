require 'base64'

class PerformersController < ApplicationController
  def index
    # TODO(nharper): This is used by the checkins js
    # - possibly will want way to specify Concert (instead of always using
    #   the current one)
    # - This only includes performers who have a registration for this concert.
    #   The checkins js app probably wants all performers so it can create
    #   attendance records for performers even if they're missing a
    #   registration. (Do an outer join on performer table with registration
    #   table?)
    @concert = Concert.current
    @registrations = Registration.where(:concert => @concert).includes(:performer)

    @performers = []
    @registrations.each do |registration|
      performer = registration.performer
      @performers << {
        id: performer.id,
        name: performer.name,
        section: registration.section,
        chorus_number: registration.chorus_number,
        status: registration.status,
        photo_path: photo_performer_path(performer),
      }
    end
    respond_to do |format|
      format.json { render :json => @performers }
    end
  end

  def printcards
    @concert = Concert.current
    @registrations = Registration.where(:concert => @concert).includes(:performer).order('chorus_number')
    if params[:chorus_number]
      numbers = params[:chorus_number].split(',')
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
