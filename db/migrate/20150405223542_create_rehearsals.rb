class CreateRehearsals < ActiveRecord::Migration[4.2]
  def change
    create_table :rehearsals do |t|
      t.datetime :date
      t.integer :attendance
      t.references :concert, index: true

      t.timestamps
    end
  end
end
