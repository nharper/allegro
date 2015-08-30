class RehearsalsController < ApplicationController
  def index
    @rehearsals = Rehearsal.where('date > ?', DateTime.now)
  end

  def all
    @rehearsals = Rehearsal.all.order('date DESC')
    render :action => :index
  end

  def show
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find_by_slug(params['id'])
  end

  def attendance
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find_by_slug(params['id'])
    @path_params = {}
    @path_params['section'] = params[:section] if params[:section]
    @path_params['type'] = params[:type] if params[:type]

    # TODO(nharper): consider passing ActiveRecord objects to the view instead
    # of building this hash.
    @performers = []
    registrations = @rehearsal.registrations(params[:section])
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
    record_kind = params[:type].to_i
    record_kind = RawAttendanceRecord.kinds[:unknown] unless record_kind
    @path_params = {}
    @path_params['section'] = params[:section] if params[:section]
    @path_params['type'] = record_kind

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
    redirect_to attendance_rehearsal_path(@rehearsal, @path_params)
  end

  def raw_attendance
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find_by_slug(params['id'])

    @registrations = @rehearsal.registrations(params[:section])
    @records = {}
    @registrations.each do |registration|
      @records[registration.performer.id] = {
        'unknown' => [],
        'checkin' => [],
        'pre_break' => [],
        'post_break' => [],
        'checkout' => [],
      }
    end
    RawAttendanceRecord.where(:rehearsal => @rehearsal).includes(:performer).each do |record|
      next unless @records[record.performer.id]
      @records[record.performer.id][record.kind] << record
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
