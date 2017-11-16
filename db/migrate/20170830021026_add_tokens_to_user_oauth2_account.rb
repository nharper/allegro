class AddTokensToUserOauth2Account < ActiveRecord::Migration
  def change
    add_column :user_oauth2_accounts, :access_token, :string
    add_column :user_oauth2_accounts, :refresh_token, :string
  end
end
