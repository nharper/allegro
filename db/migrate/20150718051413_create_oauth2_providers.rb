class CreateOauth2Providers < ActiveRecord::Migration[4.2]
  def change
    create_table :oauth2_providers do |t|
      t.string :name
      t.string :slug
      t.string :auth_url
      t.string :token_url
      t.string :id_url
      t.string :client_id
      t.string :client_secret
      t.text :auth_params

      t.timestamps null: false
    end
    add_index :oauth2_providers, :slug, unique: true
  end
end
