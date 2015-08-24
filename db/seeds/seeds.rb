# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

zone = ActiveSupport::TimeZone['Pacific Time (US & Canada)']

holigays = Concert.create({
    name: 'HoliGays',
    start_date: Date.new(2015, 8, 24),
    end_date: Date.new(2015, 12, 24)
    });

Rehearsal.create([
  { date: zone.local_to_utc(DateTime.parse('2015-08-24 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-08-31 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-09-08 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-09-14 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-09-21 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-09-28 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-10-05 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-10-12 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-10-19 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-10-26 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-11-02 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-11-09 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-11-16 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-11-23 19:00')),
    attendance: :required,
    concert: holigays },
  { date: zone.local_to_utc(DateTime.parse('2015-11-30 19:00')),
    attendance: :required,
    concert: holigays },
  ]);

[
  { name: "Nick Harper",
    number: "185",
    section: "T1L"},
  { name: "Scott Mills",
    number: "175",
    section: "T1L"},
  { name: "Justin Taylor",
    number: "157",
    section: "T1L",
    status: "LOA"},
  { name: "Jeff Sinclair",
    number: "105",
    section: "T1L"},
  { name: "Steve Gallagher",
    number: "125",
    section: "T1L"},
].each do |performer|
  Performer.createWithRegistration(performer, holigays)
end
