class UserMailer < ApplicationMailer

  def summary_email(email_addr, performers)
    @date = ActiveSupport::TimeZone['Pacific Time (US & Canada)'].utc_to_local(DateTime.now)
    @performers = performers.sort do |a, b|
      a = a[1]
      b = b[1]
      if a['missed'] == b['missed']
        a['chorus_number'] <=> b['chorus_number']
      else
        -(a['missed'] <=> b['missed'])
      end
    end.map {|x| x[1]}
    mail(to: email_addr, subject: "SFGMC Attendance for #{@date.strftime('%Y-%m-%d')}")
  end

  def detailed_email(email_addr, registration)
    # TODO: Keep this logic in sync with RegistrationsController.show
    @registration = registration
    @performer = registration.performer

    @concert = registration.concert
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

    mail(to: email_addr, subject: "Detailed SFGMC attendance report for #{@performer.name}")
  end
end
