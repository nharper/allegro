# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

elton = Concert.create({
    name: 'Elton John',
    start_date: Date.new(2015, 4, 6),
    end_date: Date.new(2015, 6, 27)
    });

Rehearsal.create([
  { date: DateTime.new(2015, 4, 6, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 4, 13, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 4, 20, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 4, 27, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 5, 4, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 5, 11, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 5, 18, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 5, 25, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 6, 1, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 6, 8, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 6, 15, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton },
  { date: DateTime.new(2015, 6, 22, 19, 0, 0, '-7'),
    attendance: :required,
    concert: elton }
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
    section: "T1L"}
].each do |performer|
  Performer.createWithRegistration(performer, elton)
end
