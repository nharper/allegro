namespace :users do
  task :list_missing_users => :environment do
    performers = Performer.all
    performers.each do |performer|
      next if performer.user
      puts "ID: #{performer.id}; Name: #{performer.name}"
    end
  end

  task :create_users => :environment do
    performers = Performer.all
    performers.each do |performer|
      next if performer.user
      performer.user = User.new
      performer.user.fill_login_token_and_save
    end
  end
end
