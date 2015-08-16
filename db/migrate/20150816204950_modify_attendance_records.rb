class ModifyAttendanceRecords < ActiveRecord::Migration
  def change
    remove_column :attendance_records, :type, :integer
  end
end
