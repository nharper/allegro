class AttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal
  has_many :attendance_records

  # TODO(nharper): add validations
end
