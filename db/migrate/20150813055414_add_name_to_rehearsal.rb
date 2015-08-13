class AddNameToRehearsal < ActiveRecord::Migration
  def change
    add_column :rehearsals, :name, :string
    add_column :rehearsals, :slug, :string
    add_index :rehearsals, :slug
  end
end
