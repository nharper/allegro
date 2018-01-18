class AddForeignKeyToPerformer < ActiveRecord::Migration[4.2]
  def change
    add_column :performers, :foreign_key, :string
  end
end
