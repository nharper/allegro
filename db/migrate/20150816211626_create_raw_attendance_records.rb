class CreateRawAttendanceRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :raw_attendance_records do |t|
      t.references :performer, index: true
      t.references :rehearsal, index: true
      t.integer :kind
      t.boolean :present
      t.datetime :timestamp
      t.references :attendance_record, index: true

      t.timestamps null: false
    end
    add_foreign_key :raw_attendance_records, :performers
    add_foreign_key :raw_attendance_records, :rehearsals
    add_foreign_key :raw_attendance_records, :attendance_records
  end
end
