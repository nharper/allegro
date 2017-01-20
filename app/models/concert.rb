class Concert < ActiveRecord::Base
  has_many :rehearsals
  has_many :registrations
  has_many :performers, :through => :registrations

  # TODO(nharper): add validations

  # TODO(nharper): add indices on Concert table for this query
  def self.current
    return Concert.where('start_date <= ? AND end_date >= ?', DateTime.now, DateTime.now).first
  end

  # TODO(nharper): Add index on Concert table for is_active. Also consider some
  # sort of sort order.
  def self.active
    return Concert.where(:is_active => true)
  end
end
