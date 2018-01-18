class ModifyAttendanceRecords < ActiveRecord::Migration[4.2]
  def change
    remove_column :attendance_records, :type, :integer
  end
end
