class RemoveSectionAndNumberFromPerformer < ActiveRecord::Migration[4.2]
  def change
    remove_column :performers, :section, :string
    remove_column :performers, :number, :string
  end
end
