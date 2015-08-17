class Card < ActiveRecord::Base
  belongs_to :performer

  validates :active, inclusion: [true, false]
  validates :card_id, presence: true
end
