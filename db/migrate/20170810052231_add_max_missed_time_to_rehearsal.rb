class AddMaxMissedTimeToRehearsal < ActiveRecord::Migration
  def change
    add_column :rehearsals, :max_missed_time, :integer
  end
end
