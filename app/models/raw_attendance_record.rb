class RawAttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal
  belongs_to :attendance_record

  enum kind: {unknown: 0, checkin: 1, pre_break: 2, post_break: 3, checkout: 4}

  validates_presence_of :performer
  validates_presence_of :rehearsal
  validates_presence_of :kind
  validates :present, :inclusion => {:in => [true, false]}
  validates_uniqueness_of :performer, :scope => [:rehearsal, :kind]
  validate :must_have_timestamp_for_checkin

  def to_s
    if self.present == true
      return "\u2713"
    elsif self.present == false
      return "\u2717"
    else
      return '?'
    end
  end

  def display_timestamp
    local_time = ActiveSupport::TimeZone['Pacific Time (US & Canada)'].utc_to_local(self.timestamp)
    return local_time.strftime('%H:%M')
  end

 private
  def must_have_timestamp_for_checkin
    if (self.kind == :checkin || self.kind == :checkout) && !self.timestamp
      errors.add(:timestamp, "Must have timestamp for #{self.kind}")
    end
  end
end
