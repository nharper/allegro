class ChangePerformersPhotoSize < ActiveRecord::Migration
  def change
    change_column :performers, :photo, :binary, :limit => 256.kilobyte
  end
end
