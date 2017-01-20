class RegistrationsController < ApplicationController
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
end
