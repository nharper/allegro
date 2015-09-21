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
end
