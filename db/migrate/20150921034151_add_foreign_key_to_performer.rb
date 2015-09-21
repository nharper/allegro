class AddForeignKeyToPerformer < ActiveRecord::Migration
  def change
    add_column :performers, :foreign_key, :string
  end
end
