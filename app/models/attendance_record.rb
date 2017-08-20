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
      records[id] = {
        'unknown' => [],
        'checkin' => [],
        'pre_break' => [],
        'post_break' => [],
        'checkout' => [],
      }
    end
    raw_records.each do |record|
      next unless records[record.performer_id] and record.rehearsal == rehearsal
      records[record.performer_id][record.kind] << record
    end

    # Calculate final records
    final_records = []
    records.each do |performer_id, record_groups|
      final_record = AttendanceRecord.where(:performer_id => performer_id, :rehearsal => rehearsal).first_or_initialize
      final_record.performer_id = performer_id
      final_record.rehearsal = rehearsal
      checkin = false
      pre_break = false
      post_break = false
      checkout = false
      missed_time = 0
      record_groups.each do |type,records|
        records.each do |record|
          final_record.raw_attendance_records << record
          if record.kind == 'checkin' || record.kind == 'checkout'
            if rehearsal.start_grace_period && record.timestamp < rehearsal.start_date + rehearsal.start_grace_period
              checkin = true
              missed_time += record.timestamp - rehearsal.start_date
            end
            # TODO(nharper): If a rehearsal has an end_grace_period but no
            # end_date, this will fail by attempting to subtract from nil.
            if rehearsal.end_grace_period && record.timestamp > rehearsal.end_date - rehearsal.end_grace_period
              checkout = true
              missed_time += rehearsal.end_date - record.timestamp
            end
            # If the grace period is nil on both ends, then any timestamp will do
            if !rehearsal.start_grace_period && !rehearsal.end_grace_period
              checkin = true
              checkout = true
            end
          elsif record.kind == 'pre_break'
            pre_break = pre_break || record.present
          elsif record.kind == 'post_break'
            post_break = post_break || record.present
          end
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
      if rehearsal.max_missed_time && missed_time > rehearsal.max_missed_time
        checkout = false
      end
      final_record.present = (checkin || pre_break) && (checkout || post_break)
      final_records << final_record
    end
    puts "Returning final records:"
    p final_records
    return final_records
  end
end
