class IncreasePolicyLength < ActiveRecord::Migration[5.2]
  def change
    change_column :rehearsals, :policy, :string, :limit => 16384
  end
end
