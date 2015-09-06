class RehearsalsController < ApplicationController
  def index
    @breadcrumbs = ['Rehearsals']
    @rehearsals = Rehearsal.where('date > ?', DateTime.now)
  end

  def all
    @breadcrumbs = ['Rehearsals']
    @rehearsals = Rehearsal.all.order('date DESC')
    render :action => :index
  end

  def show
    # TODO(nharper): Check that @rehearsal is not nil
    @rehearsal = Rehearsal.find_by_slug(params['id'])

    @breadcrumbs = [
      ['Rehearsals', rehearsals_path],
      @rehearsal.display_name,
    ]
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

    @breadcrumbs = [
      ['Rehearsals', rehearsals_path],
      [@rehearsal.display_name, rehearsal_path(@rehearsal)],
      'Take Attendance'
    ]
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
    @path_params = {}
    @path_params['section'] = params[:section] if params[:section]

    # Load the registrations and performers who should be at this rehearsal
    @registrations = @rehearsal.registrations(params[:section]).includes(:performer)

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
    # Group the raw records by performer, and then by kind of raw record.
    RawAttendanceRecord.where(:rehearsal => @rehearsal).includes(:performer).each do |record|
      next unless @records[record.performer.id]
      @records[record.performer.id][record.kind] << record
    end

    # Calculate final records for each performer based on the raw records
    @records.each do |performer_id, record_groups|
      # TODO(nharper): Look up existing attendance records and use them instead.
      final_record = AttendanceRecord.where(:performer_id => performer_id, :rehearsal => @rehearsal).first_or_initialize
      final_record.performer_id = performer_id
      final_record.rehearsal = @rehearsal
      checkin = false
      pre_break = false
      post_break = false
      checkout = false
      record_groups.each do |type,records|
        records.each do |record|
          final_record.raw_attendance_records << record
          if record.kind == :checkin && record.timestamp < @rehearsal.date + 45.minutes
            checkin = true
          elsif record.kind == :checkout && record.timestamp > @rehearsal.end_date - 45.minutes
            checkout = true
          elsif record.kind == :pre_break
            pre_break = pre_break || record.present
          elsif record.kind == :post_break
            post_break = post_break || record.present
          end
        end
      end
      if final_record.present == nil
        final_record.present = (checkin || pre_break) && (checkout || post_break)
      end
      record_groups['final'] = final_record
    end

    @breadcrumbs = [
      ['Rehearsals', rehearsals_path],
      [@rehearsal.display_name, rehearsal_path(@rehearsal)],
      'View Attendance',
    ]
  end

  def reconcile
    @rehearsal = Rehearsal.find_by_slug(params['id'])
    @path_params = {}
    @path_params['section'] = params[:section] if params[:section]

    params[:performer].each do |performer_id, status|
      record = AttendanceRecord.where(:performer_id => performer_id, :rehearsal => @rehearsal).first_or_initialize
      if status == 'present' || status == 'absent'
        record.present = (status == 'present')
        record.save!
      end
    end
    redirect_to raw_attendance_rehearsal_path(@rehearsal, @path_params)
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
