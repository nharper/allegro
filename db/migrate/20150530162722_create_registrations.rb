class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :section
      t.string :chorus_number
      t.string :status
      t.references :performer, index: true
      t.references :concert, index: true

      t.timestamps null: false
    end
    add_foreign_key :registrations, :performers
    add_foreign_key :registrations, :concerts
  end
end
