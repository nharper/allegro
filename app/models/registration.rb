class Registration < ActiveRecord::Base
  belongs_to :performer
  belongs_to :concert

  # TODO(nharper): add validations:
  # - it MUST have a performer and a concert
  # - there MUST be no more than one Registration for a Performer, Concert pair

  # TODO(nharper): consider adding an enum for status and replace
  # string statuses with ints
end
