namespace :cache do
  desc 'cleans up the tardis, i mean redis'
  task clear: :environment do
    Rails.cache.clear
    puts 'Cache cleared'
  end
end
