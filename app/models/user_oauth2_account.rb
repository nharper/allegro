class UserOauth2Account < ActiveRecord::Base
  belongs_to :oauth2_provider
  belongs_to :user

  validates :oauth2_provider_id, :presence => true
  validates :user_id, :presence => true
  validates :provider_id, :presence => true
end
