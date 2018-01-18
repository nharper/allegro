class ChangePerformersPhotoSize < ActiveRecord::Migration[4.2]
  def change
    change_column :performers, :photo, :binary, :limit => 256.kilobyte
  end
end
