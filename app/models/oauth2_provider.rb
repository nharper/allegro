class Oauth2Provider < ActiveRecord::Base
  def to_param
    return self.slug
  end

  serialize :auth_params, JSON

  has_many :user_oauth2_accounts
end
