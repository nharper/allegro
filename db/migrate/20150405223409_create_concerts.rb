class CreateConcerts < ActiveRecord::Migration[4.2]
  def change
    create_table :concerts do |t|
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
