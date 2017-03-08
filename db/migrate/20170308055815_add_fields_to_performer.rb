class AddFieldsToPerformer < ActiveRecord::Migration
  def change
    add_column :performers, :email, :string
    add_column :performers, :photo_handle, :string
  end
end
