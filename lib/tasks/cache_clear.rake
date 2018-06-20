desc 'cleans up the tardis, i mean redis'
task cache_clear: :environment do
  Rails.cache.clear
  puts 'Cache cleared'
end
