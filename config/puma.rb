if Rails.env.production?
  workers Integer(ENV['WEB_CONCURRENCY'] || 3)
  min_threads = Integer(ENV['RAILS_MIN_THREADS'] || ENV['RAILS_MAX_THREADS'] || 5)
  max_threads = Integer(ENV['RAILS_MAX_THREADS'] || 5)

  threads min_threads, max_threads
else
  # much easier debugging in develop with just one thread
  workers Integer(ENV['WEB_CONCURRENCY'] || 0)
  threads (ENV['RAILS_MIN_THREADS'] || 1), (ENV['RAILS_MAX_THREADS'] || 1)
end

wait_for_less_busy_worker
preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
