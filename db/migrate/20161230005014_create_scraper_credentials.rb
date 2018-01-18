class CreateScraperCredentials < ActiveRecord::Migration[4.2]
  def change
    create_table :scraper_credentials do |t|
      t.references :user, index: true, foreign_key: true
      t.string :cookie_name
      t.string :cookie_value

      t.timestamps null: false
    end
  end
end
