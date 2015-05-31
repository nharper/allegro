class Registration < ActiveRecord::Base
  belongs_to :performer
  belongs_to :concert
end
