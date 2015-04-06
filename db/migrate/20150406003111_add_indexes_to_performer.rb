class AddIndexesToPerformer < ActiveRecord::Migration
  def change
    add_index :performers, :number
    add_index :performers, :section
  end
end
