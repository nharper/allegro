class AttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal

  # TODO(nharper): add validations
end
