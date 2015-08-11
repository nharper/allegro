class Rehearsal < ActiveRecord::Base
  has_many :attendance_records
  belongs_to :concert

  # TODO(nharper): add validations

  enum attendance: {required: 0, optional: 1, mandatory: 2}
end
