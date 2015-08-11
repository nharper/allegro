class AttendanceController < ApplicationController
  # TODO(nharper): implement index and show methods

  def show
    @rehearsal = Rehearsal.find(params['rehearsal'])
  end

  def index
    @rehearsals = Rehearsal.where(concert: Concert.current)
  end

  def section
    # TODO(nharper): use real rehearsal, section objects
    @rehearsal = params['rehearsal']
    @section = params['section'].upcase

    # TODO(nharper): consider passing ActiveRecord objects to the view instead
    # of building this hash.
    @performers = []
    registrations = Registration.where(:section => @section).includes(:performer)
    registrations.each do |registration|
      performer = registration.performer
      @performers << {
        id: performer.id,
        name: performer.name,
        chorus_number: registration.chorus_number,
        status: registration.status
      }
    end

    @performers.sort! { |a,b| a[:chorus_number] <=> b[:chorus_number] }
  end

  def update
    # TODO(nharper): Implement update
    redirect_to section_attendance_url(params['rehearsal'], params['section'])
  end

  def checkin
  end
end
