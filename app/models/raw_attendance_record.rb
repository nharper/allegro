class RawAttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal
  belongs_to :attendance_record

  enum kind: {unknown: 0, checkin: 1, before_break: 2, after_break: 3, checkout: 4}
end
