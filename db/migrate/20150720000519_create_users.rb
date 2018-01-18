class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.references :performer, index: true

      t.timestamps null: false
    end
    add_foreign_key :users, :performers
  end
end
