require 'scraper'

namespace :scrape do
  task :print_roster do
    scraper = MusettaScraper.new
    r = scraper.roster
    p r
  end

  task :update_roster => :environment do
    concert = Concert.current

    performers = {}
    Performer.all.each do |performer|
      performers[performer.name] = performer
    end

    scraper = MusettaScraper.new
    scraper.roster.each do |entry|
      performer = performers[entry['name']]
      if performer == nil
        performer = Performer.new(name: entry['name'])
      end
      if performer.photo == nil
        img = Magick::Image.from_blob(scraper.scrape_path(entry['img'])).first
        img.format = 'PNG'
        performer.photo = img.to_blob
      end
      performer.save!

      # TODO(nharper): figure out how to pre-load these to avoid N+1 problem
      registration = Registration.where(concert: concert, performer: performer).first
      if registration == nil
        registration = Registration.new
      end
      registration.section = entry['section']
      registration.chorus_number = entry['cn']
      registration.status = entry['Status'] ? entry['Status'] : 'Active'
      registration.performer = performer
      registration.concert = concert
      registration.save!
    end
  end
end
