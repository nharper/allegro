class UserOauth2Account < ActiveRecord::Base
  belongs_to :oauth2_provider
  belongs_to :user

  validates :oauth2_provider_id, :presence => true
  validates :user_id, :presence => true
  validates :provider_id, :presence => true

  def update_access_token
    self.access_token = oauth2_provider.refresh_token(refresh_token)
    save
  end
end
