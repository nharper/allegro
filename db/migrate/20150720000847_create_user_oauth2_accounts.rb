class CreateUserOauth2Accounts < ActiveRecord::Migration
  def change
    create_table :user_oauth2_accounts do |t|
      t.references :oauth2_provider, index: true
      t.string :provider_id
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :user_oauth2_accounts, :oauth2_providers
    add_foreign_key :user_oauth2_accounts, :users
  end
end
