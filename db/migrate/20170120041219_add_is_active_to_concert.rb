class AddIsActiveToConcert < ActiveRecord::Migration[4.2]
  def change
    add_column :concerts, :is_active, :bool
  end
end
