class Concert < ActiveRecord::Base
  has_many :rehearsals
  has_many :registrations

  # TODO(nharper): add validations

  # TODO(nharper): add indices on Concert table for this query
  def self.current
    return Concert.where('start_date <= ? AND end_date >= ?', DateTime.now, DateTime.now).first
  end
end
