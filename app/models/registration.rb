class Registration < ActiveRecord::Base
  belongs_to :performer
  belongs_to :concert

  # TODO(nharper): add validations

  # TODO(nharper): consider adding an enum for status and replace
  # string statuses with ints
end
