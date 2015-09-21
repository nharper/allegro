require 'groupanizer_scraper'

namespace :performers do

  task :without_foreign_keys => :environment do
    performers = Performer.where(:foreign_key => nil).order('name')
    performers.each do |performer|
      puts performer.name
    end
  end

  task :add_foreign_keys => :environment do
    scraper = GroupanizerScraper.new
    members = {}
    scraper.roster.each do |k,v|
      members[k.downcase] = v
    end
    Performer.all.each do |performer|
      next unless members[performer.name.downcase]
      performer.foreign_key = members[performer.name.downcase]['foreign_key']
      performer.save
    end
  end

  task :update_roster => :environment do
    concert = Concert.current
    abort('No current concert for registrations; aborting') unless concert

    scraper = GroupanizerScraper.new
    performers = Performer.all.index_by(&:foreign_key)
    registrations = Registration.where(:concert => concert).index_by(&:performer_id)
    scraper.roster.each do |_, entry|
      performer = performers[entry['foreign_key']]
      if !performer
        performer = Performer.new
        performer.foreign_key = entry['foreign_key']
      end
      performer.name = entry['name']
      if performer.photo == nil
        img = Magick::Image.from_blob(scraper.scrape_path(entry['img'])).first
        img.format = 'PNG'
        performer.photo = img.to_blob
      end

      registration = registrations[performer.id]
      if registration == nil
        registration = Registration.new
      end
      voice_part_to_section = {
        'Upper Tenor 1' => 'T1U',
        'Lower Tenor 1' => 'T1L',
        'Upper Tenor 2' => 'T2U',
        'Lower Tenor 2' => 'T2L',
        'Upper Baritone' => 'B1U',
        'Lower Baritone' => 'B1L',
        'Upper Bass' => 'B2U',
        'Lower Bass' => 'B2L'
      }

      registration.section = voice_part_to_section[entry['voice_part']]
      next if !registration.section
      registration.chorus_number = entry['chorus_number']
      registration.status = entry['status']
      registration.performer = performer
      registration.concert = concert

      performer.save!
      if entry['status'] == :alumni
        registration.destroy!
      else
        if !registration.save
          puts "Can't save registration for #{performer.name}, new number #{registration.chorus_number}"
          registration.chorus_number = "RAND#{800 + SecureRandom.random_number(200)}"
          registration.save!
          p registration
          p performer
        end
      end

    end
  end
end
