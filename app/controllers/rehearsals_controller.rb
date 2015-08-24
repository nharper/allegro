class RehearsalsController < ApplicationController
  def index
    @rehearsals = Rehearsal.where('date > ?', DateTime.now)
  end

  def show
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find_by_slug(params['id'])
  end

  def attendance
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find_by_slug(params['id'])
    @section = params[:section]

    # TODO(nharper): consider passing ActiveRecord objects to the view instead
    # of building this hash.
    @performers = []
    # TODO(nharper): need to restrict Registrations to concert for this rehearsal
    registrations = Registration.includes(:performer)
    # TODO(nharper): use real section object
    if params['section']
      registrations = registrations.where(:section => params['section'].upcase)
    end
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

  def update_attendance
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find_by_slug(params['id'])
    @section = params[:section]
    p params
    record_kind = params[:type]
    record_kind = RawAttendanceRecord.kinds[:unknown] unless record_kind

    params[:attendance].each do |performer_id, status|
      # TODO(nharper): Check that performer is not nil
      performer = Performer.find(performer_id)
      record = RawAttendanceRecord.where(:performer => performer, :rehearsal => @rehearsal, :kind => record_kind).first_or_initialize
      if status == 'present' || status == 'absent'
        record.present = (status == 'present')
        # TODO(nharper): Instead of throwing, present error in better way
        record.save!
      end
    end if params[:attendance]
    if @section
      redirect_to attendance_rehearsal_path(@rehearsal, section: @section)
    else
      redirect_to attendance_rehearsal_path(@rehearsal)
    end
  end

  def checkin
    @rehearsal = Rehearsal.find_by_slug(params[:id])
  end

  def update_checkin
    # TODO(nharper): This is pretty gross - still not checking that @rehearsal
    # is not nil; kind of record is hardcoded (as checkin); no consideration
    # around deduplication (although probably not needed for this type);
    # timestamp is in who knows what timezone (ditto for Rehearsal object
    # timestamps).
    @rehearsal = Rehearsal.find_by_slug(params[:id])
    params[:_json].each do |checkin|
      RawAttendanceRecord.create(
        :performer_id => checkin['performer'],
        :rehearsal => @rehearsal,
        :present => true,
        :kind => RawAttendanceRecord.kinds[:checkin],
        :timestamp => checkin['time'],
      )
    end
    head :ok, content_type: 'text/html'
  end
end
