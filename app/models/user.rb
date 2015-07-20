class User < ActiveRecord::Base
  belongs_to :performer
  has_many :user_oauth2_accounts

  validates :performer_id, :presence => true
  validates :performer_id, :uniqueness => true
end
