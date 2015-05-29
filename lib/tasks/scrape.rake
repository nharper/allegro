require 'scraper'

namespace :scrape do
  task :roster => :environment do
    scraper = MusettaScraper.new
    r = scraper.roster
    p r
    r.each do |entry|
      img = Magick::Image.from_blob(scraper.scrape_path(entry['img'])).first
      p img
      img.format = 'PNG'
      p img
      p img.to_blob[0,80]
    end
  end
end
