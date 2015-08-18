class Rehearsal < ActiveRecord::Base
  has_many :attendance_records
  belongs_to :concert

  before_validation :update_slug
  validates :slug, presence: true, uniqueness: true
  validates :concert, presence: true
  validates :date, presence: true

  # TODO(nharper): add validations

  enum attendance: {required: 0, optional: 1, mandatory: 2}

  def to_param
    return self.slug
  end

  def display_name
    display = date.strftime('%-m-%-d')
    if name
      display = "#{name} (#{display})"
    end
    return display
  end

 protected
  def update_slug
    self.slug = date.strftime('%Y-%m-%d')
    if name
      self.slug += '-' + name.gsub(/[^0-9A-Za-z]+/, '-').chomp('-')
    end
  end
end
