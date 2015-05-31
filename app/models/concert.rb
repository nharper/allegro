class Concert < ActiveRecord::Base
  has_many :rehearsals
  has_many :registrations
end
