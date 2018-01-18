class AddTokensToUserOauth2Account < ActiveRecord::Migration[4.2]
  def change
    add_column :user_oauth2_accounts, :access_token, :string
    add_column :user_oauth2_accounts, :refresh_token, :string
  end
end
