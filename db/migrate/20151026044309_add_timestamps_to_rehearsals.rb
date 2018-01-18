class AddTimestampsToRehearsals < ActiveRecord::Migration[4.2]
  def change
    add_column :rehearsals, :end_date, :datetime
    add_column :rehearsals, :weight, :integer
    add_column :rehearsals, :start_grace_period, :integer
    add_column :rehearsals, :end_grace_period, :integer
    rename_column :rehearsals, :date, :start_date
  end

  def migrate(direction)
    super

    if direction == :up
      Rehearsal.all.each do |rehearsal|
        rehearsal.end_date = rehearsal.start_date + 3.hours
        rehearsal.weight = 1
        rehearsal.save
      end
    end
  end
end
