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

  def to_s
    if self.present == true
      return '✓'
    elsif self.present == false
      return '✗'
    else
      return '?'
    end
  end
end
