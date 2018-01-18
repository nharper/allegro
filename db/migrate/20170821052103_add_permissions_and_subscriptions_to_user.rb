class AddPermissionsAndSubscriptionsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :permissions, :string
    add_column :users, :subscriptions, :string
  end
end
