class AddIsActiveToConcert < ActiveRecord::Migration
  def change
    add_column :concerts, :is_active, :bool
  end
end
