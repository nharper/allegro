class Oauth2Provider < ActiveRecord::Base
  self.primary_key = 'slug'
  serialize :auth_params, JSON
end
