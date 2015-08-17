class Performer < ActiveRecord::Base
  ## example of how to override param in routes
  # def to_param
  #   return "#{name.parameterize}"
  # end
  has_many :attendance_records
  has_many :raw_attendance_records
  has_many :cards
  has_many :registrations
  has_one :user

  # TODO(nharper): add validations

  def self.createWithRegistration(performer_hash, concert)
    performer = Performer.new({name: performer_hash[:name]})
    Registration.create({
      section: performer_hash[:section],
      chorus_number: performer_hash[:number],
      status: performer_hash[:status] ? performer_hash[:status] : 'Active',
      concert: concert,
      performer: performer
    })
  end
end
