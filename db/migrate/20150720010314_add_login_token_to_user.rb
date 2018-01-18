class AddLoginTokenToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :login_token, :string
    add_index :users, :login_token
  end
end
