class AddIndexesToPerformer < ActiveRecord::Migration[4.2]
  def change
    add_index :performers, :number
    add_index :performers, :section
  end
end
