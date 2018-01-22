class RehearsalsController < ApplicationController
  def index
    @breadcrumbs = ['Rehearsals']
    @rehearsals = Rehearsal.where('start_date > ?', DateTime.now).order('start_date ASC')
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
    performer_ids = @registrations.map { |reg| reg.performer_id }
    raw_records = RawAttendanceRecord.where(:rehearsal => @rehearsal)

    # Compute what should be the final records
    final_records = AttendanceRecord.load_or_create_from_raw(raw_records, @rehearsal, performer_ids)

    # Re-arrange data to have raw records grouped by performer_id, and then by
    # type. First, set up the categories for all performers we care about.
    @records = {}
    @registrations.each do |registration|
      @records[registration.performer_id] = []
    end
    # Now, add the raw records.
    raw_records.each do |record|
      next unless @records[record.performer_id]
      @records[record.performer_id] << record
    end

    # Add the computed final records
    @final_records = {}
    final_records.each do |final_record|
      @final_records[final_record.performer_id] = final_record
    end

    # Override computed final records with stored final records if they exist
    AttendanceRecord.where(:performer_id => performer_ids, :rehearsal => @rehearsal).each do |final_record|
      @final_records[final_record.performer_id] = final_record
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

    AttendanceRecord.transaction do
      params[:performer].each do |performer_id, status|
        record = AttendanceRecord.where(:performer_id => performer_id, :rehearsal => @rehearsal).first_or_initialize
        if status == 'present' || status == 'absent'
          record.present = (status == 'present')
          record.save!
        end
      end
    end
    redirect_to raw_attendance_rehearsal_path(@rehearsal, @path_params)
  end

  def force_records
    @rehearsal = Rehearsal.find_by_slug(params['id'])

    # Load the registrations and performers who should be at this rehearsal
    registrations = @rehearsal.registrations(params[:section])
    performer_ids = registrations.map { |reg| reg.performer_id }
    raw_records = RawAttendanceRecord.where(:rehearsal => @rehearsal)

    final_records = AttendanceRecord.load_or_create_from_raw(raw_records, @rehearsal, performer_ids)

    new_records = final_records.select do |record|
      record.id == nil
    end

    # Only save new records
    new_records.each do |record|
      record.save
    end

    redirect_to rehearsal_path(@rehearsal)
  end

  # TODO: This really belongs in ConcertsController instead of here.
  def send_summaries
    @rehearsal = Rehearsal.find_by_slug(params['id'])
    user = User.find(session[:user_id])
    if !user.permissions || !user.permissions['sends_mail_as']
      flash[:error] = "Currently logged in user cannot send emails"
      redirect_to rehearsal_path(@rehearsal) and return
    end
    sender = UserOauth2Account.find(user.permissions['sends_mail_as'])

    performers = {}
    Registration.where(:concert => @rehearsal.concert, :status => 'active').includes(:performer).each do |registration|
      performer = {}
      performer['id'] = registration.performer_id
      performer['name'] = registration.performer.name
      performer['email'] = registration.performer.email
      performer['chorus_number'] = registration.chorus_number
      performer['section'] = registration.section
      performer['records'] = []
      performer['missed'] = 0
      performers[registration.performer_id] = performer
    end

    AttendanceRecord.where(:rehearsal => @rehearsal.concert.rehearsals).includes(:rehearsal).each do |record|
      performers[record.performer_id]['records'] << record
      if !record.present
        performers[record.performer_id]['missed'] += 1
      end
    end

    User.all.each do |user|
      next if user.subscriptions == nil
      filtered_performers = performers.select do |_, performer|
        user.subscriptions.include?(performer['section'])
      end
      next if filtered_performers.empty?
      message = UserMailer.summary_email(user.performer.email, filtered_performers).encoded
      if !send_email(message, sender)
        flash[:error] = 'Failed to send email'
        redirect_to rehearsal_path(@rehearsal) and return
      else
        flash[:error] = 'Sent email'
      end
    end

    redirect_to rehearsal_path(@rehearsal)
  end

  def checkin
    @rehearsal = Rehearsal.find_by_slug(params[:id])
    @manifest_path = checkin_manifest_rehearsal_path(@rehearsal)
    render :layout => 'offline'
  end

  def checkin_manifest
    # TODO(nharper): consider reducing scope here?
    @performers = Performer.all
    # Try to make sure that the client doesn't cache the manifest. This may be
    # overkill, but it works for now.
    expires_now
    render :layout => false, :content_type => 'text/cache-manifest'
  end

  def update_checkin
    # TODO(nharper): This is pretty gross - still not checking that @rehearsal
    # is not nil; no consideration
    # around deduplication (although probably not needed for this type);
    # timestamp is in who knows what timezone (ditto for Rehearsal object
    # timestamps).
    @rehearsal = Rehearsal.find_by_slug(params[:id])
    params[:_json].each do |checkin|
      RawAttendanceRecord.create(
        :performer_id => checkin['performer'],
        :rehearsal => @rehearsal,
        :present => true,
        :kind => RawAttendanceRecord.kinds[checkin['type']],
        :timestamp => Time.at(checkin['time'].to_i / 1000).to_datetime,
      )
    end
    head :ok, content_type: 'text/html'
  end

 private
  def send_email(message, sender)
    send_message_uri = URI("https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?uploadType=media")
    mailer_conn = Net::HTTP.new(send_message_uri.host, 443)
    mailer_conn.use_ssl = true

    headers = {
      'Authorization' => "Bearer #{sender.access_token}",
      'Content-Type' => 'message/rfc822',
    }
    mail_resp = mailer_conn.post(send_message_uri.path, message, headers)
    if mail_resp.code != '200'
      sender.update_access_token
    end
    headers = {
      'Authorization' => "Bearer #{sender.access_token}",
      'Content-Type' => 'message/rfc822',
    }
    mail_resp = mailer_conn.post(send_message_uri.path, message, headers)
    if mail_resp.code != '200'
      flash[:error_details] = mail_resp.body
      return false
    end
    return true
  end
end
