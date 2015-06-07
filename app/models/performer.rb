class Performer < ActiveRecord::Base
  ## example of how to override param in routes
  # def to_param
  #   return "#{name.parameterize}"
  # end
  has_many :attendance_records
  has_many :registrations

  # TODO(nharper): add validations

  def self.createWithRegistration(performer_hash, concert)
    # TODO(nharper): finish writing this method or delete it
  end
end
