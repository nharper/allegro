class Registration < ActiveRecord::Base
  belongs_to :performer
  belongs_to :concert

  validates_presence_of :performer
  validates_presence_of :concert
  validates_uniqueness_of :performer, :scope => :concert
  validates_uniqueness_of :chorus_number, :scope => :concert

  # TODO(nharper): consider adding an enum for status and replace
  # string statuses with ints

  SECTION_TO_FULL = {
    'T1U' => 'Upper Tenor 1',
    'T1L' => 'Lower Tenor 1',
    'T2U' => 'Upper Tenor 2',
    'T2L' => 'Lower Tenor 2',
    'B1U' => 'Upper Baritone',
    'B1L' => 'Lower Baritone',
    'B2U' => 'Upper Bass',
    'B2L' => 'Lower Bass',
  }
  FULL_TO_SECTION = {
    'Upper Tenor 1' => 'T1U',
    'Lower Tenor 1' => 'T1L',
    'Upper Tenor 2' => 'T2U',
    'Lower Tenor 2' => 'T2L',
    'Upper Baritone' => 'B1U',
    'Lower Baritone' => 'B1L',
    'Upper Bass' => 'B2U',
    'Lower Bass' => 'B2L',
  }

  def full_section
    return SECTION_TO_FULL[self.section]
  end

  def full_section=(section)
    self.section = FULL_TO_SECTION[section]
  end

  def self.current
    return Concert.current.registrations.where(:status => 'active').includes(:performer)
  end
end
