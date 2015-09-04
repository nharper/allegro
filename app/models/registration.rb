class Registration < ActiveRecord::Base
  belongs_to :performer
  belongs_to :concert

  validates_presence_of :performer
  validates_presence_of :concert
  validates_uniqueness_of :performer, :scope => :concert
  validates_uniqueness_of :chorus_number, :scope => :concert

  # TODO(nharper): consider adding an enum for status and replace
  # string statuses with ints

  def self.current
    return Concert.current.registrations.includes(:performer)
  end
end
