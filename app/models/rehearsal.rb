class Rehearsal < ActiveRecord::Base
  has_many :attendance_records
  belongs_to :concert

  # TODO(nharper): add validations

  enum attendance: {required: 0, optional: 1, mandatory: 2}

  def self.current
    return Concert.where('start_date <= ? AND end_date >= ?', DateTime.now, DateTime.now).first
  end
end
