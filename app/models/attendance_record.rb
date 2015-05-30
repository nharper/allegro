class AttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal

  enum type: {final: 0, checkin: 1, before_break: 2, after_break: 3}
end
