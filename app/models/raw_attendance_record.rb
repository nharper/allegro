class RawAttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal
  belongs_to :attendance_record

  enum kind: {unknown: 0, checkin: 1, pre_break: 2, post_break: 3, checkout: 4}

  validates_presence_of :performer
  validates_presence_of :rehearsal
  validates_presence_of :kind
  validates :present, :inclusion => {:in => [true, false]}
  # TODO(nharper):
  # I still want to enforce uniqueness for pre/post break, but I don't want to
  # enforce uniqueness for checkin/out, so the following line is commented out
  # for now (until I write the proper validation).
  # validates_uniqueness_of :performer, :scope => [:rehearsal, :kind]
  validate :must_have_timestamp_for_checkin

  def is_override?
    return self.kind == 'pre_break' || self.kind == 'post_break'
  end

  def is_swipe_or_manual?
    return self.kind == 'checkin' || self.kind == 'checkout'
  end

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
    return local_time.strftime('%a %H:%M')
  end

 private
  def must_have_timestamp_for_checkin
    if (self.kind == :checkin || self.kind == :checkout) && !self.timestamp
      errors.add(:timestamp, "Must have timestamp for #{self.kind}")
    end
  end
end
