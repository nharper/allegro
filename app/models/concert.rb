class Concert < ActiveRecord::Base
  has_many :rehearsals
end
