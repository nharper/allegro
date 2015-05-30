class CreateAttendanceRecords < ActiveRecord::Migration
  def change
    create_table :attendance_records do |t|
      t.references :performer, index: true
      t.references :rehearsal, index: true
      t.boolean :present
      t.integer :type
      t.string :notes

      t.timestamps null: false
    end
    add_foreign_key :attendance_records, :performers
    add_foreign_key :attendance_records, :rehearsals
  end
end
