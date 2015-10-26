class Rehearsal < ActiveRecord::Base
  has_many :attendance_records
  belongs_to :concert

  before_validation :update_slug
  validates :slug, presence: true, uniqueness: true
  validates :concert, presence: true
  validates :start_date, presence: true

  # TODO(nharper): add validations
  # - start_grace_period positive (if present)
  # - end_grace_period positive (if present)
  # - end_date greater than start_date
  # - end_date present
  # - weight present (if attendance is required or optional)

  enum attendance: {required: 0, optional: 1, mandatory: 2}

  def to_param
    return self.slug
  end

  def local_date
    return ActiveSupport::TimeZone['Pacific Time (US & Canada)'].utc_to_local(self.start_date)
  end

  def display_name
    display = local_date.strftime('%-m-%-d')
    if name
      display = "#{name} (#{display})"
    end
    return display
  end

  def registrations(section = nil)
    registrations = self.concert.registrations.where(:status => 'active').includes(:performer).order(:chorus_number)
    if section
      registrations = registrations.where(section: section)
    end
    return registrations
  end

 protected
  def update_slug
    self.slug = local_date.strftime('%Y-%m-%d')
    if name
      self.slug += '-' + name.gsub(/[^0-9A-Za-z]+/, '-').chomp('-')
    end
  end
end
