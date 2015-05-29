require 'scraper'

namespace :scrape do
	task :roster => :environment do
		scraper = MusettaScraper.new
		p scraper.roster
	end
end
