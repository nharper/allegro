class AttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal
  has_many :raw_attendance_records

  # TODO(nharper): add validations
  validates :performer, presence: true
  validates :rehearsal, presence: true
  validates :present, :inclusion => {:in => [true, false]}
  validates_uniqueness_of :performer, :scope => :rehearsal
end
