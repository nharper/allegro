class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :card_id
      t.references :performer, index: true
      t.boolean :active
      t.datetime :expiration_date

      t.timestamps null: false
    end
    add_foreign_key :cards, :performers
  end
end
