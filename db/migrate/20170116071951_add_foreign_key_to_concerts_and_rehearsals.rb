class AddForeignKeyToConcertsAndRehearsals < ActiveRecord::Migration[4.2]
  def change
    add_column :concerts, :foreign_key, :string
    add_column :rehearsals, :foreign_key, :string
  end
end
