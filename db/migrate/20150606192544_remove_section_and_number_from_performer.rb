class RemoveSectionAndNumberFromPerformer < ActiveRecord::Migration
  def change
    remove_column :performers, :section, :string
    remove_column :performers, :number, :string
  end
end
