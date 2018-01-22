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
end
