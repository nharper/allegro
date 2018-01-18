class IncreaseScraperCredentialSize < ActiveRecord::Migration[4.2]
  def change
    change_column :scraper_credentials, :cookie_value, :string, :limit => 4096
  end
end
