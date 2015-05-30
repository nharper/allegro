class Rehearsal < ActiveRecord::Base
  has_many :attendance_records
  belongs_to :concert

  enum attendance: {required: 0, optional: 1, mandatory: 2}
end
