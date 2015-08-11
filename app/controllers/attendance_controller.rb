class AttendanceController < ApplicationController
  # TODO(nharper): implement index and show methods

  def show
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find(params['rehearsal'])
  end

  def index
    # TODO(nharper): Check that @rehearsals is not nil
    @rehearsals = Rehearsal.where(concert: Concert.current)
  end

  def section
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find(params['rehearsal'])
    # TODO(nharper): use real section object
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
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find(params[:rehearsal])
    # TODO(nharper): refactor this to be more efficient
    params[:attendance].each do |performer_id, status|
      # TODO(nharper): check that performer is not nil
      performer = Performer.find(performer_id)
      record = AttendanceRecord.where(:performer => performer, :rehearsal => @rehearsal).first_or_initialize
      if status == 'present' || status == 'absent'
        record.present = (status == 'present')
        record.save
      end
      # TODO(nharper): If AttendanceRecord already exists in db and status == ''
      # then we should change 'present' field in record to nil.
      puts "Performer id: #{performer_id}, status: #{status}"
    end
    redirect_to section_attendance_url(params['rehearsal'], params['section'])
  end

  def checkin
  end
end
