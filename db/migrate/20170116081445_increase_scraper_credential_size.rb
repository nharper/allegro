class IncreaseScraperCredentialSize < ActiveRecord::Migration
  def change
    change_column :scraper_credentials, :cookie_value, :string, :limit => 4096
  end
end
