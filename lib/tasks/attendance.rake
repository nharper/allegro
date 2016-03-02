namespace :attendance do
  task :remove_duplicates => :environment do
    dupes = AttendanceRecord.find_by_sql('SELECT c, performer_id, rehearsal_id FROM (SELECT count(*) as c, performer_id, rehearsal_id FROM attendance_records GROUP BY performer_id, rehearsal_id) AS t WHERE c > 1')
    dupes.each do |dupe|
      records = AttendanceRecord.where(:performer_id => dupe.performer_id, :rehearsal_id => dupe.rehearsal_id)
      present = true
      records.each do |record|
        present = present && record.present
      end
      first = records.first
      first.present = present

      records.drop(1).each do |record|
        record.delete
      end

      first.save!
    end
  end
end
