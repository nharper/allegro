class Concert < ActiveRecord::Base
  has_many :rehearsals
  has_many :registrations

  # TODO(nharper): add validations
end
