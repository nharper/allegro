class ChangeOauthTokenSizes < ActiveRecord::Migration[7.0]
  def change
    change_column :user_oauth2_accounts, :access_token, :text
    change_column :user_oauth2_accounts, :refresh_token, :text
  end
end
