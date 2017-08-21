class AddPermissionsAndSubscriptionsToUser < ActiveRecord::Migration
  def change
    add_column :users, :permissions, :string
    add_column :users, :subscriptions, :string
  end
end
