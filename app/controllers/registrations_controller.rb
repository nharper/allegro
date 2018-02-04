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

  def show
    # TODO: Keep this logic in sync with UserMailer.detailed_email
    @registration = Registration.find(params[:performer_id])
    @performer = @registration.performer

    @concert = @registration.concert
    @rehearsals = {}
    @concert.rehearsals.each do |rehearsal|
      @rehearsals[rehearsal.id] = {
        :name => rehearsal.display_name,
        :present => nil,
        :override => nil,
        :raw_records => [],
      }
    end

    RawAttendanceRecord.where(:performer => @performer, :rehearsal_id => @rehearsals.keys).each do |raw_record|
      if raw_record.timestamp
        @rehearsals[raw_record.rehearsal_id][:raw_records] << raw_record
      elsif raw_record.is_override?
        @rehearsals[raw_record.rehearsal_id][:override] = raw_record.present
      end
    end
    AttendanceRecord.where(:performer => @performer, :rehearsal_id => @rehearsals.keys).each do |final_record|
      @rehearsals[final_record.rehearsal_id][:present] = final_record.present
    end

    @rehearsals.each do |id, rehearsal|
      rehearsal[:raw_records].sort! do |a, b|
        a.timestamp <=> b.timestamp
      end
    end

    @date = ActiveSupport::TimeZone['Pacific Time (US & Canada)'].utc_to_local(DateTime.now)
  end

  def send_details
    @registration = Registration.find(params[:performer_id])
    if !user_can_send_emails
      flash[:error] = "Currently logged in user cannot send emails"
      redirect_to performer_details_concerts_path(@registration) and return
    end
    sender = UserOauth2Account.find(current_user.permissions['sends_mail_as'])

    message = UserMailer.detailed_email(current_user.performer.email, @registration).encoded
    if !send_email(message, sender)
      flash[:error] = 'Failed to send email'
    else
      flash[:error] = 'Sent email'
    end
    redirect_to performer_details_concerts_path(@registration)
  end
end
