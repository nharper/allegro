class User < ActiveRecord::Base
  belongs_to :performer
  has_many :user_oauth2_accounts

  validates :performer_id, :presence => true
  validates :performer_id, :uniqueness => true

  def fill_login_token
    self.login_token = SecureRandom.base64(30)
  end

  def fill_login_token_and_save
    self.fill_login_token
    self.save
  end

  # TODO(nharper): Don't clear the token as part of this - create a separate
  # method to do that.
  def self.find_by_login_token(token)
    return nil unless token.length == 40
    user = User.where(:login_token => token).first
    if user
      user.login_token = nil
      user.save!
    end
    return user
  end
end
