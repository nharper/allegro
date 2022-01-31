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
      has_override = false
      timestamps = []
      record_groups.each do |record|
        final_record.raw_attendance_records << record
        if record.is_swipe_or_manual?
          timestamps << record.timestamp
        elsif record.is_override?
          final_record.present = record.present
          final_records << final_record
          has_override = true
          break
        end
      end
      next if has_override

      present = false
      timestamps.sort!
      rehearsal.policy.each do |policy|
        checkin = false
        checkout = false
        if !policy.start_date || !policy.start_grace_period ||
            timestamps.first < policy.start_date + policy.start_grace_period
          checkin = true
        end
        if !policy.end_date || !policy.end_grace_period ||
            timestamps.last > policy.end_date - policy.end_grace_period
          checkout = true
        end
        present = checkin && checkout
        if policy.max_missed_time && timestamps.size > 0
          missed_time = timestamps.first - policy.start_date
          missed_time += policy.end_date - timestamps.last
          if missed_time > policy.max_missed_time
            present = false
          end
        end
        break if present = true
      end
      final_record.present = present
      final_records << final_record
    end
    return final_records
  end
end
