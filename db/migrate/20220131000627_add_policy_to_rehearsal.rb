class AddPolicyToRehearsal < ActiveRecord::Migration[5.2]
  def change
    add_column :rehearsals, :policy, :string
  end
end
