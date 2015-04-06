# run with rails runner

ARGV.each do |arg|
  File.open(arg, 'rb') do |f|
    filename = File.basename(arg)
    performer_result = Performer.where(:number => filename.split('.')[0])
    next unless performer_result.length == 1
    performer = performer_result[0]
    performer.photo = f.read
    p performer
    unless performer.save
      puts "Failed to save image for #{performer}"
    end
  end
end
