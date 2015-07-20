class Oauth2Provider < ActiveRecord::Base
  self.primary_key = 'slug'
  serialize :auth_params, JSON

  has_many :user_oauth2_accounts
end
