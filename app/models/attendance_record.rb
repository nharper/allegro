class AttendanceRecord < ActiveRecord::Base
  belongs_to :performer
  belongs_to :rehearsal
  has_many :raw_attendance_records

  # TODO(nharper): add validations
  validates :performer, presence: true
  validates :rehearsal, presence: true
  validates :present, :inclusion => {:in => [true, false]}
  validates_uniqueness_of :performer, :scope => :rehearsal

  # Takes a set of RawAttendanceRecords |raw_records| and computes the
  # corresponding AttendanceRecords for them. Only AttendanceRecords for
  # |rehearsal| and Performers with id in |performer_ids| will be loaded or
  # created. The value of |AttendanceRecord.present| will be based solely on
  # the RawAttendanceRecords passed in - any value in an existing
  # AttendanceRecord will be ignored.
  #
  # This method does not save any changes to AttendanceRecords or create any
  # new records - it only provides the AttendanceRecord objects for the caller
  # to do with what they wish.
  def self.load_or_create_from_raw(raw_records, rehearsal, performer_ids)
    # Group raw records by performer and then kind of raw record:
    records = {}
    performer_ids.each do |id|
      records[id] = []
    end
    raw_records.each do |record|
      next unless records[record.performer_id] and record.rehearsal == rehearsal
      records[record.performer_id] << record
    end

    # Calculate final records
    final_records = []
    records.each do |performer_id, record_groups|
      final_record = AttendanceRecord.where(:performer_id => performer_id, :rehearsal => rehearsal).first_or_initialize
      final_record.performer_id = performer_id
      final_record.rehearsal = rehearsal
      checkin = false
      checkout = false
      has_override = false
      timestamps = []
      record_groups.each do |record|
        final_record.raw_attendance_records << record
        if record.is_swipe_or_manual?
            timestamps << record.timestamp
          if record.is_checkin_time_for(rehearsal)
            checkin = true
          end
          if record.is_checkout_time_for(rehearsal)
            checkout = true
          end
        elsif record.is_override?
          checkin = record.present
          checkout = record.present
          has_override = true
        end
      end
      if rehearsal.start_grace_period || rehearsal.end_grace_period
        if !rehearsal.start_grace_period
          checkin = true
        end
        if !rehearsal.end_grace_period
          checkout = true
        end
      end
      final_record.present = checkin && checkout
      if rehearsal.max_missed_time && timestamps.size > 0 && !has_override
        timestamps.sort!
        missed_time = timestamps.first - rehearsal.start_date
        missed_time += rehearsal.end_date - timestamps.last
        if missed_time > rehearsal.max_missed_time
          final_record.present = false
        end
      end
      final_records << final_record
    end
    return final_records
  end
end
